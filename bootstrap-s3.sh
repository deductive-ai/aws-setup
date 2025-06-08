#!/bin/bash

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Default values
BUCKET="deductive-ai-iac"
REGION="us-east-2"
AWS_PROFILE=""

usage() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -p, --profile PROFILE      AWS profile to use"
    echo "  -r, --region REGION        AWS region (default: us-east-2)"
    echo "  -b, --bucket BUCKET        S3 bucket name (default: deductive-ai-iac)"
    echo "  -h, --help                 Show this help message"
    echo ""
    echo "This script will:"
    echo "  1. Create the S3 bucket if it doesn't exist"
    echo "  2. Enable versioning on the bucket"
    echo "  3. Initialize Terraform backend"
    echo ""
    echo "Example:"
    echo "  $0 -p my-aws-profile"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--profile)
            AWS_PROFILE="$2"
            shift 2
            ;;
        -r|--region)
            REGION="$2"
            shift 2
            ;;
        -b|--bucket)
            BUCKET="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

if [[ -z "$AWS_PROFILE" ]]; then
    echo -e "${RED}Error: AWS profile (-p) is required${NC}"
    usage
    exit 1
fi

# Build AWS CLI command with profile
AWS_CMD="aws --profile ${AWS_PROFILE} --region ${REGION}"

echo -e "${BLUE}Bootstrapping S3 backend for Terraform...${NC}"
echo -e "${BLUE}Bucket: ${BUCKET}${NC}"
echo -e "${BLUE}Region: ${REGION}${NC}"
echo -e "${BLUE}Profile: ${AWS_PROFILE}${NC}"

# Check if bucket exists
echo -e "${YELLOW}Checking if S3 bucket exists...${NC}"
if $AWS_CMD s3api head-bucket --bucket "$BUCKET" 2>/dev/null; then
    echo -e "${GREEN}✓ S3 bucket '$BUCKET' already exists${NC}"
else
    echo -e "${YELLOW}S3 bucket '$BUCKET' does not exist. Creating...${NC}"
    
    # Create the bucket
    if [[ "$REGION" == "us-east-1" ]]; then
        # us-east-1 doesn't need LocationConstraint
        $AWS_CMD s3api create-bucket --bucket "$BUCKET"
    else
        # Other regions need LocationConstraint
        $AWS_CMD s3api create-bucket \
            --bucket "$BUCKET" \
            --create-bucket-configuration LocationConstraint="$REGION"
    fi
    
    echo -e "${GREEN}✓ S3 bucket '$BUCKET' created successfully${NC}"
fi

# Add tags to the bucket
echo -e "${YELLOW}Adding tags to S3 bucket...${NC}"
cat > /tmp/s3-tags.json << EOF
{
    "TagSet": [
        {
            "Key": "creator",
            "Value": "deductive-ai"
        }
    ]
}
EOF

$AWS_CMD s3api put-bucket-tagging \
    --bucket "$BUCKET" \
    --tagging file:///tmp/s3-tags.json

# Clean up temp file
rm -f /tmp/s3-tags.json

echo -e "${GREEN}✓ Tags added to S3 bucket${NC}"

# Enable versioning on the bucket (recommended for Terraform state)
echo -e "${YELLOW}Enabling versioning on S3 bucket...${NC}"
$AWS_CMD s3api put-bucket-versioning \
    --bucket "$BUCKET" \
    --versioning-configuration Status=Enabled

echo -e "${GREEN}✓ Versioning enabled on S3 bucket${NC}"

# Enable server-side encryption
echo -e "${YELLOW}Enabling server-side encryption on S3 bucket...${NC}"
$AWS_CMD s3api put-bucket-encryption \
    --bucket "$BUCKET" \
    --server-side-encryption-configuration '{
        "Rules": [
            {
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }
        ]
    }'

echo -e "${GREEN}✓ Server-side encryption enabled${NC}"

# Now initialize Terraform
echo -e "${YELLOW}Initializing Terraform backend...${NC}"

# Check if there are existing state files that would cause migration issues
if [[ -f "terraform.tfstate" ]] || [[ -f "terraform.tfstate.backup" ]]; then
    echo -e "${YELLOW}Existing local state files detected. Using -reconfigure to start fresh with S3 backend...${NC}"
    terraform init -reconfigure
else
    terraform init
fi

echo -e "${GREEN}🎉 Bootstrap completed successfully!${NC}"
echo -e "${BLUE}Your Terraform state will be stored at: s3://${BUCKET}/<workspace>/terraform.tfstate${NC}"
echo -e "${BLUE}Next steps:${NC}"
echo -e "${BLUE}  1. terraform workspace new <tenant>${NC}"
echo -e "${BLUE}  2. terraform apply -var=\"external_id=<xxx>\" -var=\"tenant=<tenant>\" -var=\"aws_profile=${AWS_PROFILE}\"${NC}" 