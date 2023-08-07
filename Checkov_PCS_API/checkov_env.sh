# The script extract Prisma Cloud Credential from AWS Secret manager, and use checkov to integrate with Prisma Cloud for scanning

#!/bin/bash

REGION="ap-southeast-1"
SECRET_ID="PrismaCloud_CED"

SECRET_BLOB=$(aws secretsmanager get-secret-value --region="$REGION" --output=text --query SecretString --secret-id "$SECRET_ID")

PCS_USERNAME=$(awk -F "{|}|,|:" '{print $3}' <<< $SECRET_BLOB | tr -d '"')
PCS_PASSWORD=$(awk -F "{|}|,|:" '{print $5}' <<< $SECRET_BLOB | tr -d '"')

export PRISMA_API_URL=https://api.prismacloud.io

echo "start scaning..."
checkov -f  ./ec2.tf  --bc-api-key $PCS_USERNAME::$PCS_PASSWORD
