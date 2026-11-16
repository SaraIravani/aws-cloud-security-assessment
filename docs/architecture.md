
# AWS Cloud Security Assessment Architecture

## 1. Project Overview

This project simulates a cloud security assessment for a company
named CloudNova.

The objective is to review selected AWS security configurations,
identify potential security gaps, and collect technical evidence
to support an internal security and compliance review.

## 2. Architecture Scope

The assessment focuses on three AWS services:

- IAM: Identity and access management.
- S3: Storage security and data protection.
- CloudTrail: AWS API activity logging.

The project uses a single AWS test account.

## 3. IAM Assessment

The IAM review covers:

- Users, roles, and policies.
- Least privilege permissions.
- MFA configuration for human users.
- Role trust policies.

## 4. S3 Security Assessment

The S3 review covers:

- Block Public Access.
- Server-side encryption.
- Bucket policies.
- Access permissions.

## 5. CloudTrail Assessment

The CloudTrail review covers:

- Trail configuration.
- Management event logging.
- Event history.
- Evidence of AWS resource changes.

## 6. Evidence Collection

Assessment results will be collected using AWS CLI
and documented in the project repository.

Evidence will include timestamps, resource context,
assessment results, and identified security findings.

## 7. Expected Deliverables

- AWS infrastructure configuration using Terraform.
- Security assessment scripts.
- Evidence collection outputs.
- Security findings and remediation tracker.
- Final assessment report.

## 8. Project Limitations

This is an independent portfolio project using a test AWS environment.
It is not a formal SOC 2 audit or certification.

