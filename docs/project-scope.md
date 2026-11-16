
# Project Scope

## Project Name
AWS Cloud Security Assessment & Evidence Collection

## Business Scenario
CloudNova is a fictional software company using AWS
to host and manage its cloud resources.

The security team requested an assessment of selected
AWS configurations to identify security gaps and
prepare technical evidence for an internal review.

## Assessment Scope

### In Scope
- AWS IAM users, roles, and policies
- IAM MFA configuration
- Amazon S3 bucket security
- S3 public access and encryption
- AWS CloudTrail logging configuration

### Out of Scope
- Amazon EKS and Kubernetes
- Amazon RDS
- Active Directory
- Penetration testing
- Formal SOC 2 certification
- Multi-account AWS environments

## Project Objectives
1. Review AWS identity and access controls.
2. Assess S3 storage security.
3. Verify AWS activity logging.
4. Identify security misconfigurations.
5. Collect technical evidence.
6. Document findings and remediation recommendations.

## Deliverables
- AWS security assessment scripts
- Technical evidence files
- Security findings report
- Remediation tracker
- Final assessment report

## Environment
A single AWS test account will be used.
Infrastructure will be provisioned using Terraform
where applicable.

