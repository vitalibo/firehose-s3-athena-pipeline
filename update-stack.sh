#!/usr/bin/env bash
set -e

if [[ $# -ne 2 ]] && [[ $# -ne 3 ]]; then
  echo "Usage: $0 [name] [bucket] [profile]"
  echo ''
  echo 'Options:'
  echo '  name      Service name that will be prefixed to resource names'
  echo '  bucket    S3 buckets with source codes'
  echo '  profile   Use a specific AWS profile from your credential file'
  exit 1
fi

NAME=$1; BUCKET=$2; PROFILE=$([[ $# -eq 3 ]] && echo $3 || echo 'default')

aws cloudformation package --template src/stack.yaml --s3-bucket $BUCKET --s3-prefix $NAME \
  --profile $PROFILE >packaged-stack.yaml

aws cloudformation deploy --template-file packaged-stack.yaml --stack-name "$NAME-glue-partitioner" \
  --parameter-overrides Name=$NAME --capabilities 'CAPABILITY_NAMED_IAM' --profile $PROFILE

rm packaged-stack.yaml
