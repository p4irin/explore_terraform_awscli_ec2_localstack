# Explore Terraform, awscli, EC2 instance on LocalStack

Create an AWS EC2 instance using the AWS CLI and Terraform on LocalStack

## Pre-requisites

* [LocalStack installed with a LOCALSTACK_AUTH_TOKEN](https://docs.localstack.cloud/getting-started/)
* [AWS CLI installed](https://docs.localstack.cloud/user-guide/integrations/aws-cli/)
* [An AMI (Amazone Machine Image)](https://docs.localstack.cloud/user-guide/aws/ec2/#:~:text=not%20be%20persisted.-,AMIs,-LocalStack%20utilizes%20a)
* [Terraform installed](https://developer.hashicorp.com/terraform/install)

### AMI

LocalStack emulates EC2 instances using Docker containers. The images used for these containers are downloaded when installing LocalStack. The images are tagged with an AMI. Use the Ubuntu 22.04 image. Use following command to get the AMI of the Ubuntu image

```bash
$ docker images|grep localstack-ec2
localstack-ec2/ubuntu-22.04-jammy-jellyfish  ami-df5de72bdb3b ...
localstack-ec2/amazonlinux-2023              ami-024f768332f0 ...
$
```
The AMI to use in this case is `ami-df5de72bdb3b`.

### AWS CLI configuration

Touch these files
* `~/.aws/config`
* `~/.aws/credentials`

Add the following to `~/.aws/config`

```bash
[profile localstack]
region=us-east-1
output=json
endpoint_url=http://localhost:4566
```

Add the following to `~/.aws/credentials`

```bash
[localstack]
aws_access_key_id=test
aws_secret_access_key=test
```

With above configuration you can use the `--profile` option with each `aws` command to run against LocalStack.

E.g.:

```bash
$ aws --profile localstack ec2 run-instances ...
```

## General steps

1. Run `$ localstack start`
1. Create a key pair or import your existing public key
1. Run the EC2 instance on LocalStack
1. Run `$ localstack stop`

_Note: By default access to port 22 is allowed so it's not necessary to add inbound rules_

## AWS CLI

Start LocalStack

```bash
$ localstack start
```

### Create a key pair or import your existing public key

Create a key pair

```bash
aws --profile localstack ec2 create-key-pair \
    --key-name my-key \
    --query 'KeyMaterial' \
    --output text | tee key.pem
```

EC2 will output the private key to `key.pem`. The public key it will use for SSH public key authentication.

If you already have a key pair in `~/.ssh` you can just import the public key. Usually this is in the file `~/.ssh/id_rsa.pub`

```bash
$ aws --profile localstack ec2 import-key-pair \
    --key-name my-key\
    --public-key-material file://~/.ssh/id_rsa.pub

```

### Run the EC2 instance

```bash
$ aws --profile localstack ec2 run-instances \
  --image-id ami-df5de72bdb3b \
  --count 1 \
  --instance-type t3.nano\
  --key-name my-key
```

### Verify: connect to the instance using SSH

If you created a key pair as above connect with

```bash
$ ssh -i key.pem root@localhost
```

If you imported your existing public key

```bash
$ ssh root@localhost
```

##

Stop LocalStack

```bash
$ localstack stop
```

## Terraform

Refer to the `*.tf` files

Start LocalStack

```bash
$ localstack start
```

Initialize the configuration

```bash
$ terraform init
```

This takes a while. The provider plugins are downloaded and installed. When done initializing, you'll find a `.terraform` directory and a `.terraform.lock.hcl` lock file.

See what Terraform will do

```bash
$ terraform plan
```

Deploy to LocalStack

```bash
$ terraform apply
```
This is when the state file is created.

Verify deployment by connecting to the EC2 instance using SSH. The configuration uses an existing public key. So, you can connect with

```bash
$ ssh root@localhost
```

Discard the resources managed by your configuration

```bash
$ terraform destroy
```

Stop LocalStack

```bash
$ localstack stop
```

## References

* [EC2](https://docs.localstack.cloud/user-guide/aws/ec2/)
* [Terraform LocalStack integration](https://docs.localstack.cloud/user-guide/integrations/terraform/)
* [Terraform resource: aws_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance)