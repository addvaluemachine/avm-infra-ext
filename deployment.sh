#!/bin/bash

# Function to check and exit on error
check_error() {
    local exit_code=$1
    local error_message=$2

    if [ $exit_code -ne 0 ]; then
        echo "Error: $error_message"
        exit $exit_code
    fi
}

# Check if .env file exists
if [ -f .env ]; then
    echo "Sourcing environment variables from .env file"
    source "$(pwd)/.env"
else
    echo "Error: .env file not found. Please create one with the necessary environment variables."
    exit 1
fi

#Creating Bucket for the terraform backend
account_id=$(aws sts get-caller-identity --query Account | tr -d '"')
check_error $? "No AWS Creds or Role found"

if [ -z "$AWS_REGION" ]; then
    # Assign default value if empty or null
    AWS_REGION="us-east-1"
fi

BUCKET_NAME="avm-$account_id-$AWS_REGION-terraform-backend"

echo "Resources will be created in the $AWS_REGION region"

export TF_VAR_region="$AWS_REGION"

aws s3 ls "s3://$BUCKET_NAME" --region "$AWS_REGION" 2>/dev/null

if [ $? -eq 0 ]; then
    echo "Bucket $BUCKET_NAME already exists. Using for terraform state store"
else
    aws s3 mb "s3://$BUCKET_NAME" --region "$AWS_REGION"
    echo "Bucket $BUCKET_NAME created successfully. Using for terraform state store"
    check_error $? "Bucket creation failed"
fi

sed -i '' -e "s/tfstate_bucket_name/$BUCKET_NAME/g" versions.tf

sed -i '' -e "s/bucket_region/$AWS_REGION/g" versions.tf

#Check for GuardDuty Enable
guard_duty=$(aws guardduty list-detectors --region "$AWS_REGION" --query "length(DetectorIds)" --output text)

if [ "$guard_duty" -gt 0 ]; then
    echo "GuardDuty is enabled. Skipping Guardduty creation"
    export TF_VAR_guard_duty="Yes"
else
    echo "GuardDuty is not enabled. Enabling Guardduty."
    export TF_VAR_guard_duty="no"
fi

#Check for Security Hub Enable
securityhub_enabled=$(aws securityhub describe-hub --region "$AWS_REGION" 2>/dev/null)

if [ $? -eq 0 ]; then
    echo "Security Hub is enabled. Skipping Security Hub creation"
    export TF_VAR_Security_Hub="Yes"
else
    echo "Security Hub is not enabled. Enabling Security Hub."
    export TF_VAR_Security_Hub="no"
fi

# Terraform initialization
echo "Initializing Terraform..."
terraform init
check_error $? "Terraform initialization failed."

# Check if workspace exists
existing_workspace=$(terraform workspace list | grep -w "$workspace_name")

if [ -n "$existing_workspace" ]; then
    echo "Workspace '$workspace_name' already exists. Selecting..."
    terraform workspace select "$workspace_name"
else
    # Create Terraform workspace
    echo "Creating Terraform workspace..."
    terraform workspace new "$workspace_name"
    check_error $? "Terraform workspace creation failed."

    # Select Terraform workspace
    echo "Selecting Terraform workspace..."
    terraform workspace select "$workspace_name"
    check_error $? "Terraform workspace selection failed."
fi

# Apply Terraform changes
echo "Applying Terraform changes..."
terraform apply --auto-approve
check_error $? "Terraform apply failed."