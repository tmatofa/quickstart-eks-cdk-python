# Manual Installation

As an alternative to CodeBuild, you can deploy from any machine (your laptop, a bastion EC2 instance, etc.).

There are some prerequisites you likely will need to install on the machine doing your environment bootstrapping including Node, Python, the AWS CLI, the CDK, fluxctl and Helm

## Pre-requisites - Ubuntu 20.04 LTS (including via Windows 10's WSL)

Run `sudo ./ubuntu-prereqs.sh`

## Pre-requisites - Mac

1. Install Homebrew (https://brew.sh/)
1. Run `./mac-prereqs.sh`

## Deploy from CDK locally

1. Make sure that you have your AWS CLI configured with administrative access to the AWS account in question (e.g. an `aws s3 ls` works)
    1. This can be via setting your access key and secret in your .aws folder via `aws configure` or in your environment variables by copy and pasting from AWS SSO etc.
1. Run `cd quickstart-eks-cdk-python/cluster-bootstrap`
2. Run `npm install` to install the exact version of the CDK this has been tested with (locally in the node_modules folder)
3. Run `pip3 install --user --upgrade -r requirements.txt` to install the required Python bits of the CDK (locked to the same exact CDK version)
4. Run `export CDK_DEPLOY_REGION=ap-southeast-2` replacing ap-southeast-2 with your region of choice
5. Run `export CDK_DEPLOY_ACCOUNT=123456789123` replacing 123456789123 with your AWS account number
6. (Optional) If you want to make an existing IAM User or Role the cluster admin rather than creating a new one then edit `cluster-bootstrap/cdk.json` and comment out the current cluster_admin_role and uncomment the one beneath it and fill in the ARN of the User/Role you'd like there.
7. (Only required the first time you use the CDK in this account) Run `cdk bootstrap` to create the S3 bucket where it puts the CDK puts its artifacts
8. (Only required the first time OpenSearch in VPC mode is used in this account) Run `aws iam create-service-linked-role --aws-service-name es.amazonaws.com`
9. Run `npx cdk deploy --require-approval never`