# Credstash demo

This demo uses Ansible to install credstash on your computer, and to launch an AWS EC2 instance that will run a small Ruby application and use Credstash to get secrets.

I designed this demo to run in a fresh AWS account. Check the Variables section for things you can override.

## What do I need

To run this demo, you will need the following:

1. Ansible should be installed on your computer
1. your AWS credentials (AWS secret key ID and secret access key) should be configured in `~/.aws/credentials`
1. AWS region and profile environment variables that correspond to the profile and region you want to use:
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

This role installs a Ruby app (`demo-app.rb`) that will demonstrate the usage of Credstash secrets.

The app uses two secrets, and outputs their values to `/var/log/syslog`.

The first secret is fetched from an environment variable set by Ansible. If we update its value in Credstash DynamoDB table, we will have to run the Ansible playbook to update the value on our EC2 instance.

The second secret is fetched directly from Credstash. If we update its value in Credstash DynamoDB table, the application will automatically fetch its updated value.
