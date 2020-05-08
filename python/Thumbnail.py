import boto3
import os
import sys
import uuid
import base64
import json
from urllib.parse import unquote_plus
from PIL import Image
from botocore.exceptions import ClientError
import PIL.Image

#
# fetch our wasabi credentials from secrets manager
#
def get_secret(secret_name, aws_region):
    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=aws_region
    )

    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
    except ClientError as e:
        if e.response['Error']['Code'] == 'DecryptionFailureException':
            print("Secrets Manager can't decrypt the protected secret text using the provided KMS key")
            raise e
        elif e.response['Error']['Code'] == 'InternalServiceErrorException':
            print("An error occurred on the server side.")
            raise e
        elif e.response['Error']['Code'] == 'InvalidParameterException':
            print("You provided an invalid value for a parameter.")
            raise e
        elif e.response['Error']['Code'] == 'InvalidRequestException':
            print("You provided a parameter value that is not valid for the current state of the resource.")
            raise e
        elif e.response['Error']['Code'] == 'ResourceNotFoundException':
            print("We can't find the resource that you asked for.")
            raise e
    else:
        secret = json.loads(get_secret_value_response['SecretString'])

    return secret

#
# make the client used to send to wasabi
#
def make_wasabi_client(region, secret_name, secret_region):
    secret = get_secret(secret_name, secret_region)

    wasabi_session = boto3.Session(
        aws_access_key_id=secret['WASABI_ACCESS'],
        aws_secret_access_key=secret['WASABI_SECRET']
    )
    wasabi_client = wasabi_session.client(
        's3',
        region_name=region,
        endpoint_url='https://s3.{}.wasabisys.com'.format(region)
    )
    return wasabi_client

#
# resize the image, using a fixed scaling factor
#
def resize_image(image_path, resized_path):
    with Image.open(image_path) as image:
        image.thumbnail(tuple(x / 8 for x in image.size))
        image.save(resized_path)


s3_client = boto3.client('s3')
wasabi_client = make_wasabi_client(os.environ['WASABI_REGION'], os.environ['WASABI_SECRET'], os.environ['REGION'])

#
# our entry point, which for each record in the "created a file" event: retrieves the file and resizes it
# then sends the resized image to the thumbnail bucket, the original file to wasabi, and deletes the file
# from the dropbox bucket
#
def lambda_handler(event, context):
    for record in event['Records']:
        dropbox = record['s3']['bucket']['name']
        key = unquote_plus(record['s3']['object']['key'])
        tmpkey = key.replace('/', '')
        download_path = '/tmp/{}{}'.format(uuid.uuid4(), tmpkey)
        upload_path = '/tmp/resized-{}'.format(tmpkey)
        s3_client.download_file(dropbox, key, download_path)
        resize_image(download_path, upload_path)
        wasabi_client.upload_file(download_path, os.environ['WASABI_BUCKET'], key)
        s3_client.upload_file(upload_path, os.environ['THUMBNAIL_BUCKET'], key)
        s3_client.delete_object(Bucket=dropbox, Key=key)
        print("processed {}".format(key))
