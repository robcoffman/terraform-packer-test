#!/bin/bash

EXPECTED_ARGS=2
E_BADARGS=20

if [ $# -ne ${EXPECTED_ARGS} ]
then
  echo "Usage: KEYID SECRET"
  exit ${E_BADARGS}
fi

mkdir ~/.aws
echo "[default]" > ~/.aws/credentials
echo "aws_access_key_id = $1" >> ~/.aws/credentials
echo "aws_secret_access_key = $2" >> ~/.aws/credentials
echo "region = us-west-1" >> ~/.aws/credentials
