#!/bin/bash

cd `dirname $0`

usage() {
  echo "Usage: $0 -p <profile> -r <region> -b <bucket>" 1>&2
  exit 1
}

while getopts ":p:r:b:" o; do
    case "${o}" in
        p) PROFILE=${OPTARG}
            ;;
        r) REGION=${OPTARG}
            ;;
        b) NAME=${OPTARG}
            ;;
        *) usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${PROFILE}" ] || [ -z "${REGION}" ] || [ -z "${NAME}" ]
then
    usage
fi

unset AWS_REGION AWS_PROFILE AWS_ACCOUNT

#
# see https://jmespath.org/tutorial.html for information on query syntax
#
COUNT=$(aws --profile ${PROFILE} --endpoint-url=https://s3.${REGION}.wasabisys.com --output json \
  s3api list-buckets \
  --query "length(Buckets[?Name=='"${NAME}"'])"
  )

if [[ $COUNT -eq 0 ]]
then
  echo "===> creating ${NAME}"
  aws --profile ${PROFILE} --endpoint-url=https://s3.${REGION}.wasabisys.com \
      s3api create-bucket --region ${REGION} --bucket ${NAME} --acl private
fi
