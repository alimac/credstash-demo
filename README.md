# Credstash demo

This demo uses Ansible to install credstash on your computer, and to launch an AWS EC2 instance that will run a small Ruby application and use Credstash to get secrets.

I designed this demo to run in a fresh AWS account, but you can override parts of the setup (see the Variables section.

## Before you start

There is a cost for launching resources on AWS. Please read carefully to estimate the cost of testing credstash-demo:

- [EC2 Pricing](https://aws.amazon.com/ec2/pricing/on-demand/)
- [DynamoDB Pricing](https://aws.amazon.com/dynamodb/pricing/)
- [KMS Pricing](https://aws.amazon.com/kms/pricing/)

## What do I need

To run credstash-demo, you will need the following:

1. [Amazon Web Services](https://aws.amazon.com) account.
1. [Ansible](http://docs.ansible.com/ansible/intro_installation.html) should be installed on your computer
1. You should have [AWS CLI](http://docs.aws.amazon.com/cli/latest/userguide/installing.html) tool installed
1. Your AWS credentials (AWS secret key ID and secret access key) should be configured in `~/.aws/credentials`. Run `aws configure` if needed.
1. AWS region and profile environment variables, that correspond to the profile and region you want to use:
  * `export AWS_DEFAULT_PROFILE=<profile>`
  * `export AWS_DEFAULT_REGION=<region>`

Your AWS credentials should have access to AWS DynamoDB and KMS.

## What it does

The demo consists of a playbook (`credstash-demo.yml`) and two Ansible roles (`credstash-setup` and `demo-app`).

### About credstash-setup role

This role performs the following tasks:

1. creates an EC2 SSH key pair - the public key is uploaded to AWS, and the private key is saved to your `~/.ssh/` directory
1. creates an encryption key using AWS Key Management Service (KMS)
1. creates an IAM role and instance profile that allows an EC2 instance to use the encryption key to decrypt items
1. installs `credstash` on your localhost and runs `credstash setup` to create the DynamoDB table where secrets will be stored
1. uploads sample secrets to our Credstash DynamoDB table
1. provisions an EC2 instance which will be used by the `demo-app` role

### About demo-app role

This role installs a small Ruby app (`demo-app.rb`) that will demonstrate the usage of Credstash secrets.

The app uses two secrets, and outputs their values to `/var/log/syslog`.

The first secret is fetched from an environment variable that gets set by Ansible. If we update its value in Credstash DynamoDB table, we will have to run the Ansible playbook again to update the value on our EC2 instance.

The second secret is fetched directly from Credstash. If we update its value in Credstash DynamoDB table, the application will automatically fetch its updated value.

## How do I run it

In your terminal:

```
git clone git@github.com:alimac/credstash-demo.git
cd credstash-demo/
ansible-playbook credstash-demo.yml
```

If you want to get more insight into the tasks that Ansible is running, add the `-v` flag to increase verbosity (up to `-vvvv`).

## Variables

- `ec2_keypair` - Name of EC2 public key you want to use for the instance. You must have the private key in your SSH agent. By default, Ansible will create and save a private key named `credstash-demo.pem`
- `ec2_instance_type` - Set to *t2.nano* (smallest, cheapest instance) by default. If your AWS account is eligible for the free tier, set this to *t2.micro*.

You can pass the variables via command line:

```
ansible-playbook credstash-demo.yml -e ec2_keypair=myKey -e ec2_instance_type=t2.micro
```

Or edit the `vars:` section of `credstash-demo.yml` playbook.
