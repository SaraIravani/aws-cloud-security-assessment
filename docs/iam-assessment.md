# IAM Security Assessment

## 1. Overview

The IAM Security Assessment is the first assessment module of the CloudNova AWS Cloud Security Assessment project.

Its purpose is to collect information about AWS Identity and Access Management (IAM) configurations and identify potential access-control security gaps.

The assessment uses AWS CLI read-only API operations. It does not create, modify, or delete AWS resources.

## 2. Assessment Scope

The current script performs the following checks:

| Check | AWS CLI operation | Purpose |
|---|---|---|
| Account identity | `aws sts get-caller-identity` | Identify the AWS account and the active caller |
| Password policy | `aws iam get-account-password-policy` | Retrieve the IAM account password policy |
| IAM users | `aws iam list-users` | Enumerate IAM users |
| IAM roles | `aws iam list-roles` | Enumerate IAM roles |
| Account summary | `aws iam get-account-summary` | Retrieve account-level IAM security indicators |

## 3. Architecture and Execution Flow

```text
        AWS Account
             |
             v
     IAM Assessment Script
     scripts/iam-assessment.sh
             |
             v
      AWS CLI Read-only Calls
             |
             v
      Assessment Results
             |
             v
        evidence/iam/
```

## 4. Running the Assessment

Run the script from the repository root:

```bash
bash scripts/iam-assessment.sh
```

Check the script syntax:

```bash
bash -n scripts/iam-assessment.sh
```

The script requires:
- AWS CLI installed and available in PATH.
- Valid AWS credentials or an authenticated AWS profile.
- Sufficient IAM read permissions for the requested API operations.

## 5. Evidence Collection

The script stores assessment outputs in:

```text
evidence/
└── iam/
```

Evidence files are kept locally and excluded from Git commits to avoid accidentally publishing AWS account information or other sensitive data.

The repository contains an `evidence/.gitkeep` file to preserve the evidence directory structure.

## 6. Error Handling and Assessment Limitations

The script reports the status of individual checks and distinguishes successful operations, failed operations, and checks that are not applicable.

Important considerations:

- An access-denied error does not prove that a security control is misconfigured.
- A missing IAM password policy should be investigated as a potential finding, not treated as a successful check.
- IAM account password policies apply to IAM users. They do not govern authentication for users signing in through AWS IAM Identity Center.
- Listing IAM users and roles does not provide a complete assessment of their effective permissions.
- Further analysis of attached policies, inline policies, access keys, and role trust relationships may be required.

## 7. Security and Cost Considerations

- The current IAM assessment is designed around read-only AWS API operations.
- It does not deploy or modify AWS infrastructure.
- No Terraform apply operation is required to run this assessment.
- AWS API usage and any associated costs depend on the services and account configuration.

## 8. Current Status and Next Steps

**Completed in the current implementation:**
- Initial IAM assessment script.
- Basic AWS account and IAM information collection.
- Local evidence directory structure.
- Terraform foundation for the broader project.

**Planned improvements:**
- Deeper IAM policy and access-key analysis.
- Review of collected evidence.
- Security findings and remediation recommendations.

**Next assessment module:** S3 Security Assessment, covering bucket-level security configurations such as public access restrictions, encryption, versioning, and ownership controls.

---

*This is an independent portfolio project using a simulated CloudNova assessment scenario. It is not a representation of an actual client engagement or a formal SOC 2 audit.*
