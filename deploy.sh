#!/bin/bash

. .env

hugo
AWS_PROFILE=unimeg_meggie aws s3 sync public/ s3://$MEGGIEL_BUCKET_NAME
