
#!/usr/bin/env bash

set -uo pipefail

OUTPUT_DIR="evidence/s3/$(date -u +%Y%m%dT%H%M%SZ)"

mkdir -p "$OUTPUT_DIR"

PASS_COUNT=0
FINDING_COUNT=0
INFO_COUNT=0
ERROR_COUNT=0

echo "======================================"
echo "     S3 Security Assessment"
echo "======================================"

# Check required tools
for tool in aws jq; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "ERROR: Required tool '$tool' is not installed."
        exit 1
    fi
done

# Verify AWS identity
echo
echo "[1/2] Checking AWS identity..."

if ! aws sts get-caller-identity \
    --output json \
    > "$OUTPUT_DIR/account-identity.json" \
    2> "$OUTPUT_DIR/account-identity-error.txt"; then

    echo "ERROR: Unable to identify AWS caller."
    echo "Check AWS credentials and permissions."
    exit 1
fi

rm -f "$OUTPUT_DIR/account-identity-error.txt"
echo "PASS: AWS identity retrieved."

# Retrieve S3 bucket list
echo
echo "[2/2] Retrieving S3 buckets..."

if ! aws s3api list-buckets \
    --output json \
    > "$OUTPUT_DIR/buckets.json" \
    2> "$OUTPUT_DIR/buckets-error.txt"; then

    echo "ERROR: Unable to retrieve S3 buckets."
    exit 1
fi

rm -f "$OUTPUT_DIR/buckets-error.txt"

mapfile -t BUCKETS < <(
    jq -r '.Buckets[]?.Name' "$OUTPUT_DIR/buckets.json"
)

echo "Discovered ${#BUCKETS[@]} bucket(s)."

# Run an individual bucket security check
run_check() {
    local label="$1"
    local output_file="$2"
    local missing_code="$3"
    local missing_status="$4"
    shift 4

    local error_file="${output_file%.json}-error.txt"

    if "$@" --output json > "$output_file" 2> "$error_file"; then
        rm -f "$error_file"
        echo "PASS: $label"
        ((PASS_COUNT+=1))
        return
    fi

    if grep -Fq "$missing_code" "$error_file"; then
        echo "$missing_status: $label"
        ((FINDING_COUNT+=1))
    elif grep -Eqi 'AccessDenied|AccessDeniedException|UnauthorizedOperation' "$error_file"; then
        echo "ERROR: $label - Access denied"
        ((ERROR_COUNT+=1))
    else
        echo "ERROR: $label - API request failed"
        ((ERROR_COUNT+=1))
    fi
}

# Assess each bucket
for bucket in "${BUCKETS[@]}"; do

    echo
    echo "--------------------------------------"
    echo "Bucket: $bucket"
    echo "--------------------------------------"

    BUCKET_DIR="$OUTPUT_DIR/$bucket"
    mkdir -p "$BUCKET_DIR"

    # 1. Public Access Block
    run_check \
        "Bucket Public Access Block" \
        "$BUCKET_DIR/public-access-block.json" \
        "NoSuchPublicAccessBlockConfiguration" \
        "FINDING" \
        aws s3api get-public-access-block --bucket "$bucket"

    # 2. Server-side Encryption
    run_check \
        "Bucket Encryption" \
        "$BUCKET_DIR/encryption.json" \
        "ServerSideEncryptionConfigurationNotFoundError" \
        "FINDING" \
        aws s3api get-bucket-encryption --bucket "$bucket"

    # 3. Versioning
    VERSIONING_FILE="$BUCKET_DIR/versioning.json"

    if aws s3api get-bucket-versioning \
        --bucket "$bucket" \
        --output json \
        > "$VERSIONING_FILE" \
        2> "$BUCKET_DIR/versioning-error.txt"; then

        rm -f "$BUCKET_DIR/versioning-error.txt"

        VERSIONING_STATUS=$(jq -r '.Status // "NotEnabled"' "$VERSIONING_FILE")

        case "$VERSIONING_STATUS" in
            Enabled)
                echo "PASS: Bucket Versioning"
                ((PASS_COUNT+=1))
                ;;
            Suspended)
                echo "FINDING: Bucket Versioning is suspended"
                ((FINDING_COUNT+=1))
                ;;
            *)
                echo "FINDING: Bucket Versioning is not enabled"
                ((FINDING_COUNT+=1))
                ;;
        esac
    else
        echo "ERROR: Bucket Versioning - API request failed"
        ((ERROR_COUNT+=1))
    fi

    # 4. Bucket Policy Public Status
    run_check \
        "Bucket Policy Status" \
        "$BUCKET_DIR/policy-status.json" \
        "NoSuchBucketPolicy" \
        "INFO" \
        aws s3api get-bucket-policy-status --bucket "$bucket"

    if [[ -f "$BUCKET_DIR/policy-status.json" ]]; then
        if jq -e '.PolicyStatus.IsPublic == true' \
            "$BUCKET_DIR/policy-status.json" >/dev/null; then
            echo "FINDING: Bucket policy allows public access"
            ((FINDING_COUNT+=1))
        elif jq -e '.PolicyStatus.IsPublic == false' \
            "$BUCKET_DIR/policy-status.json" >/dev/null; then
            echo "PASS: Bucket policy is not classified as public"
            ((PASS_COUNT+=1))
        fi
    fi

    # 5. Object Ownership Controls
    run_check \
        "Bucket Ownership Controls" \
        "$BUCKET_DIR/ownership-controls.json" \
        "NoSuchOwnershipControls" \
        "FINDING" \
        aws s3api get-bucket-ownership-controls --bucket "$bucket"

done

# Final summary
echo
echo "======================================"
echo "       S3 Assessment Summary"
echo "======================================"
echo "Buckets discovered: ${#BUCKETS[@]}"
echo "Passed checks:      $PASS_COUNT"
echo "Potential findings: $FINDING_COUNT"
echo "Informational:      $INFO_COUNT"
echo "Errors:             $ERROR_COUNT"
echo
echo "Evidence directory: $OUTPUT_DIR"
echo "Assessment completed."

