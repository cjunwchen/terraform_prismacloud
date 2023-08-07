#!/bin/bash

terraform output -json | jq -r '.prismacloud_policy | .value[] | .children[] | .criteria ' | yq -P