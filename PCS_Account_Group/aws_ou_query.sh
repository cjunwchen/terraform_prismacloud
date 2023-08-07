#!/bin/bash

ACC_ID=$1
#ACC_ID="032273940486"

#OU_BLOB=$(aws organizations list-accounts | jq ".Accounts[] | select(.Id ==\"$ACC_ID\") 
#OU_ID=$(jq -r '.Arn' <<< $OU_BLOB | awk -F "/" '{print $2}')
#ACC_NAME=$(jq -r '.Name' <<< $OU_BLOB )

ACC_NAME=$(aws organizations list-accounts | jq ".Accounts[] | select(.Id ==\"$ACC_ID\") | .Name" | tr -d \") 
OU_Parent_ID=$(aws organizations list-parents --child-id $ACC_ID | jq -r '.Parents[] | .Id')
OU_Parent_Name=$(aws organizations describe-organizational-unit --organizational-unit-id $OU_Parent_ID | jq -r '.OrganizationalUnit | .Name')

echo -n "{\"ou_name\":\"${OU_Parent_Name}\",\"acc_name\":\"${ACC_NAME}\"}"

