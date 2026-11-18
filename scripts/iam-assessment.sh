
#!/usr/bin/env bash

set -Eeuo pipefail

OUTPUT_DIR="evidence/iam"
mkdir -p "$OUTPUT_DIR"

SUCCESS=0
FAILED=0
NOT_APPLICABLE=0

echo "======================================"
echo " CloudNova IAM Security Assessment"
echo "======================================"

run_check() {
    local check_name="$1"
    local output_file="$2"
    shift 2

    echo "[CHECK] $check_name"

    if "$@" > "$OUTPUT_DIR/$output_file" 2>&1; then
        echo "PASS: $check_name"
        ((SUCCESS+=1))
    else
        local exit_code=$?

        echo "FAIL: $check_name (exit code: $exit_code)"
        ((FAILED+=1))
    fi
}

run_check \
    "AWS Account Identity" \
    "account-identity.json" \
    aws sts get-caller-identity

run_check \
    "IAM Users" \
    "users.json" \
    aws iam list-users

run_check \
    "IAM Roles" \
    "roles.json" \
    aws iam list-roles

run_check \
    "IAM Account Summary" \
    "account-summary.json" \
    aws iam get-account-summary

echo "[CHECK] Account Password Policy"

if aws iam get-account-password-policy \
    > "$OUTPUT_DIR/password-policy.json" 2>&1; then
    echo "PASS: Password policy retrieved"
    ((SUCCESS+=1))
else
    if grep -q "NoSuchEntity" "$OUTPUT_DIR/password-policy.json"; then
        echo "NOT APPLICABLE: No account password policy configured"
        ((NOT_APPLICABLE+=1))
    else
        echo "FAIL: Could not retrieve password policy"
        ((FAILED+=1))
    fi
fi

echo
echo "======================================"
echo " Assessment Summary"
echo "======================================"
echo "Successful checks: $SUCCESS"
echo "Failed checks:     $FAILED"
echo "Not applicable:    $NOT_APPLICABLE"
echo "Evidence directory: $OUTPUT_DIR"
