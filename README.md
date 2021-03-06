# Credstash demo

This demo uses Ansible to install [Credstash](https://github.com/fugue/credstash) on your computer, and to launch an AWS EC2 instance that will run a small Ruby application and use Credstash to get secrets.

I designed this demo to run in a fresh AWS account, but you can override parts of the setup (see the Variables section for list of variables that can be overridden).

## Before you start

There is a cost for launching resources on AWS. Please read carefully to estimate the cost of testing credstash-demo:

- [EC2 Pricing](https://aws.amazon.com/ec2/pricing/on-demand/)
- [DynamoDB Pricing](https://aws.amazon.com/dynamodb/pricing/)
- [KMS Pricing](https://aws.amazon.com/kms/pricing/)

## What you need

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

The demo consists of a playbook (`credstash-demo.yml`), which makes use of two Ansible roles (`credstash-setup` and `ruby-app`).

### About credstash-setup role

This role performs the following tasks:

1. Creates an EC2 SSH key pair - the public key is uploaded to AWS, and the private key is saved to your `~/.ssh/` directory
1. Creates an encryption key using AWS Key Management Service (KMS), which will be used for encrypting Credstash items
1. Creates an IAM role and instance profile that allows an EC2 instance to use the encryption key to decrypt items
1. Installs `credstash` on your localhost and runs `credstash setup` to create the DynamoDB table where secrets will be stored
1. Uploads sample secrets to the Credstash DynamoDB table
1. Provisions an EC2 instance which will be used by the `ruby-app` role

### About ruby-app role

This role installs a small Ruby app (`ruby-app.rb`) on the EC2 instance, to demonstrate how Credstash secrets are used.

The app uses two secrets, and outputs their values to `/var/log/syslog`.

The first secret is fetched from an environment variable that gets set when we run the Ansible playbook. If we update the secret's value in Credstash, we would have to run the Ansible playbook again to update the environment variable value on our EC2 instance.

The second secret is fetched directly from Credstash. If we update its value in Credstash, the application will automatically fetch its updated value.

## How to run this demo

In your terminal:

```
git clone git@github.com:alimac/credstash-demo.git
cd credstash-demo/
ansible-playbook credstash-demo.yml
```

If you want to get more insight into the tasks that Ansible is running, add the `-v` flag to increase verbosity. You can go up to `-vvvv`.

## Variables

You can set the following optional variables:

- `ec2_keypair` - Name of EC2 public key you want to use for the instance. By default, Ansible will create and save a private key named `credstash-demo.pem`
- `ec2_instance_type` - By default set to **t2.nano** (smallest, cheapest instance). If your AWS account is eligible for the free tier, set this to **t2.micro**.

You can pass the variables via command line:

```
ansible-playbook credstash-demo.yml -e ec2_keypair=myKey -e ec2_instance_type=t2.micro
```

Or edit the `vars:` section of `credstash-demo.yml` playbook.

In this demo, `credstash_secrets` list contains unencrypted secrets. This is purely for convenience and not recommended outside of testing this demo.

## Author

Alina Mackenzie

## License

Licensed under the MIT License. See the [LICENSE](LICENSE.md) file for more details.
