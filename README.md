# Wasabi
This project contains materials used for a demonstration of co-operation of AWS S3 and [Wasabi](https://wasabi.com/), using
Infrastructure-as-code principles.

The project creates a simplified system for creating thumbnails of photos and archiving the originals. It builds a "dropbox"
bucket and "thumbnail" bucket on AWS, and an "archive" bucket on Wasabi. When image files are added to the right place in the
dropbox bucket, [AWS Lambda](https://aws.amazon.com/lambda/) code is invoked to create the thumbnail, and move the original image to the archive bucket on Wasabi.

Parts of this project are derived from <https://docs.aws.amazon.com/lambda/latest/dg/with-s3-example.html>

Please note this is just a sketch, and several key pieces of work remain undone:

  - the permissions model for the buckets is rudimentary
    - loading files to the dropbox requires administration access
    - reading files from the thumbnail or archive bucket require administration access
    - there's no protection against the administrator deleting files accidentally
  - assembling the ZIP file containing the Lambda code is manual (see below)
  - the thumbnail is currently a simple scaling down, but it would be better to be a (configurable) fixed size
  - the Python code is quite rudimentary and should be accompanied by tests and proper error handling.

## Prerequisites
This project assumes that:

  - you are running on a Linux or MacOS device (it was developed and tested on MacOS 10.15.4)
  - [Terraform](https://www.terraform.io/) v0.12.8 or later is installed and in the path
  - the [AWS CLI tool](https://docs.aws.amazon.com/cli/index.html) version 2.0.12 or later is installed and in the path
  - you have an [AWS](https://aws.amazon.com/) account, and a [Wasabi](https://wasabi.com/) account
  - you have access credentials for both accounts providing a fairly high level of access
    - full admininstration rights may be needed
  - your [access credentials](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html) are available as profiles

## Usage
In order to create the infrastructure, you first must create the Lambda ZIP file, and create an `env.rc` file from the template
`env.rc.template` file. You must also add the Wasabi access credentials to [AWS SecretsManager](https://aws.amazon.com/secrets-manager/)

### Create the Python ZIP
The image manipulation library used to create the thumbnail is quite fussy about where it is installed, and it turns out in order
to use it from AWS Lambda we need to assemble the ZIP file on an Amazon Linux 2 EC2 instance.

Please see <  https://docs.aws.amazon.com/lambda/latest/dg/with-s3-example-deployment-pkg.html#with-s3-example-deployment-pkg-python> for more information on this.

Here is how I proceeded:

First I created an Amazon Linux 2 EC2 instance, choosing a tiny instance with minimal storage, configured to allow SSH from my desktop. I connected with SSH, then setup a python project there (note that we need Python 3.7 installed on the instance):

```
$ sudo amazon-linux-extras install python3
$ sudo yum update
$ python3 -m venv s3-python
$ cd s3-python
$ source bin/activate
$ pip install Pillow boto3
```

next, using the SSH key, I copied the `Thumbnail.py` from my desktop to the project:

```
$ scp -i ~/.ssh/training.pem python/Thumbnail.py ec2-user@ec2-3-8-124-35.eu-west-2.compute.amazonaws.com:s3-python/Thumbnail.py>
```

returning to the EC2 instance I bundled everything up as a ZIP file:

```
$ cd lib/python3.7/site-packages/
$ zip -r9 ~/s3-python/Thumbnail.zip .
$ cd ~/s3-python
$ zip -g Thumbnail.zip Thumbnail.py
$ deactivate
```

and finished by copying the ZIP back to my desktop:

```
$ scp -i ~/.ssh/training.pem ec2-user@ec2-3-8-124-35.eu-west-2.compute.amazonaws.com:s3-python/Thumbnail.zip python/Thumbnail.zip>
```

### Create env.rc
Copy the `env.rc.template` to `env.rc` in the top directory of the project, and update the values appropriately, e.g.

```
export AWS_REGION=eu-west-1
export AWS_PROFILE=myawsprofile
export AWS_ACCOUNT=422363075215
export WASABI_REGION=eu-central-1
export WASABI_PROFILE=mywasabiprofile
export WASABI_BUCKET=photoarchive
```

| value          | description                                                     |
| -------------- | --------------------------------------------------------------- |
| AWS_REGION     | AWS region to create buckets and Lambda in                      |
| AWS_PROFILE    | profile used for access to AWS                                  |
| AWS_ACCOUNT    | AWS account ID that the assets are created in                   |
| WASABI_REGION  | Wasabi region (us-east-1, us-east-2, us-west-1 or eu-central-1) |
| WASABI_PROFILE | profile used for access to Wasabi                               |
| WASABI_BUCKET  | name of the archive bucket to create in Wasabi                  |


### Create Secrets

You will need to add your Wasabi access_key / secret_key pair to AWS Secrets Manager so that the Lambda can send files to Wasabi:

  1. login to the AWS console and navigate to Secrets Manager
  2. select "Store a new secret"
  3. specify "other types of secrets"
  4. add two key/value pairs, with keys `WASABI_ACCESS` and `WASABI_SECRET`
  5. use default encryption and other default configuration options
  6. name the secret `demo/wasabi/access`

Note that if you want to name the secret differently, you will need to update `lambda/variables.tf` to record the different name.

### Create Assets

To create the assets, simply execute `setup.sh` from the top directory of the project:

```
$ ./setup.sh
```

All being well, you should see the final stages report the AWS bucket names, e.g.:

```
dropbox = photos20200510113118950300000002
thumbnails = photos20200510113118949300000001
```

You should also be able to see that the buckets and lambda have been created in AWS, and the bucket created in Wasabi. To
see the service in action, copy an image to the "dropbox" button:

```
$ aws --profile myawsprofile s3 cp IMG_1013.jpeg s3://photos20200510113118950300000002/photos/IMG_1013.jpeg
```

After a short delay, the resized image should be in the "thumbnail" bucket, and the original image in the Wasabi "archive" bucket.

Note that occasionally I saw the first invocation of the lamba code after creation fail - if this happens, just load another image.

### Destroy Assets
To destroy the assets, you should empty the buckets, then execute `teardown.sh` from the top directory of the project:

```
$ ./teardown.sh
```

If there are any errors - which may happen if AWS is slow to remove assets - simply execute the teardown script again.

## License
Copyright 2020 Leap Beyond ApS

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
