#!/bin/bash

. .env

if [ -d public ]
then
  echo "Warning: public dir already exists."
  exit 1
fi

hugo

#AWS_PROFILE=unimeg_meggie aws s3 sync s3://$MEGGIEL_BUCKET_NAME s3://$MEGGIEL_BACKUP_BUCKET_NAME --delete
#AWS_PROFILE=unimeg_meggie aws s3 sync public/ s3://$MEGGIEL_BUCKET_NAME --delete
#aws s3 cp --recursive public/ s3://<bucket name>

rm -rf public/
