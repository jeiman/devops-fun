# Terraform Build Infrastructure
![Terraform](tf.png)

This folder will allow us to automatically provision AWS services when needed for our operations. Further guides are provided in the [GUIDE.md](GUIDE.md) file.

# Table of Contents
  * [Steps](#steps)
  * [Executing new tf files of the same service](#executing-new-tf-files-of-the-same-service)
  * [Making changes to an existing resource created](#making-changes-to-an-existing-resource-created)
  * [Destroying existing resources](#destroying-existing-resources)
  * [Resources and Links](#resources-and-links)

# Steps

## Step 1 - Create an execution plan
The `terraform plan` command is used to create an execution plan. Terraform performs a refresh, unless explicitly disabled, and then determines what actions are necessary to achieve the desired state specified in the configuration files.

## Step 2 - Creating a .tf file

1. Make sure you have your aws credentials stored in your local machine under `~/.aws/credentials`. It will be explained below.

2. Create a new `.tf` file if needed to provision a new service that is not currently available in the repo folder.

3. An example of a Terraform file is shown below:

```
provider "aws" {
  access_key = "ACCESS_KEY_HERE" # Optional
  secret_key = "SECRET_KEY_HERE" # Optiona  l
  region     = "ap-southeast-1"
}

resource "aws_instance" "example" {
  ami           = "ami-2757f631"
  instance_type = "t2.micro"
}
```

4. The provider `block` is used to configure the named provider, in our case "aws". A provider is responsible for creating and managing resources. Multiple provider blocks can exist if a Terraform configuration is composed of multiple providers, which is a common situation.

The `resource` block defines a resource that exists within the infrastructure. A resource might be a physical component such as an EC2 instance, or it can be a logical resource such as a Heroku application.

5. NOTE: If you simply leave/comment out AWS credentials, Terraform will automatically search for saved API credentials (for example, in  `~/.aws/credentials`) or IAM instance profile credentials. This option is much cleaner for situations where tf files are checked into source control or where there is more than one admin user. See details here. Leaving IAM credentials out of the Terraform configs allows you to leave those credentials out of source control, and also use different IAM credentials for each user without having to modify the configuration files.

6. Run `terraform validate` to validate the syntax of the terraform files. Terraform performs a syntax check on all the terraform files in the directory, and will display an error if any of the files doesn't validate.


## Step 3 - Initialization
1. Run `terraform init` *on each aws service folder in the repo* if you want to provision new services in the AWS account. The first command to run for a new configuration -- or after checking out an existing configuration from version control -- is `terraform init`, which initializes various local settings and data that will be used by subsequent commands.

Terraform uses a plugin based architecture to support the numerous infrastructure and service providers available. As of Terraform version 0.10.0, each "Provider" is its own encapsulated binary distributed separately from Terraform itself. The `terraform init` command will automatically download and install any Provider binary for the providers in use within the configuration, which in this case is just the `aws` provider. The `aws` provider plugin is downloaded and installed in a subdirectory of the current working directory, along with various other book-keeping files.

## Step 4 - Apply Changes
1. In the same directory as the `terraform/aws/*.tf` file you created, run `terraform apply`. You should see output similar to below, though we've truncated some of the output to save space:

```
+ aws_s3_bucket.b
    id:                          <computed>
    acceleration_status:         <computed>
    acl:                         "private"
    arn:                         <computed>
    bucket:                      "jeimanjeya-test-bucket"
    bucket_domain_name:          <computed>
    bucket_regional_domain_name: <computed>
    force_destroy:               "false"
    hosted_zone_id:              <computed>
    region:                      <computed>
    request_payer:               <computed>
    tags.%:                      "2"
    tags.Environment:            "Dev"
    tags.Name:                   "Jeiman Jeya Test Bucket"
    versioning.#:                <computed>
    website_domain:              <computed>
    website_endpoint:            <computed>
```

NOTE: If `terraform apply` failed with an error, read the error message and fix the error that occurred. At this stage, it is likely to be a *syntax error in the configuration*.

2. If the plan was created successfully, Terraform will now pause and wait for approval before proceeding. If anything in the plan seems incorrect or dangerous, it is safe to abort here with no changes made to your infrastructure. In this case the plan looks acceptable, so type yes at the confirmation prompt to proceed. Executing the plan will take a few minutes since Terraform waits for the EC2 instance to become available:

```
# ...
aws_instance.example: Creating...
  ami:                      "" => "ami-2757f631"
  instance_type:            "" => "t2.micro"
  [...]

aws_instance.example: Still creating... (10s elapsed)
aws_instance.example: Creation complete

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

# ...
```

3. Terraform is all done! You can go to the EC2 console to see the created EC2 instance. (Make sure you're looking at the same region that was configured in the provider configuration!)

# Executing new tf files of the same service

Few rules to consider while creating Terraform files for a specific service, take S3 for an example.
1. Make sure the resource name is unique. ie `resource "aws_s3_bucket" "unique_name" {`. This would allow Terraform to recognise new resource blocks and create it accordingly. Note: Once it's created, it will ask if you want to destroy the previous resource and create a new one. Make a decision here whether you want to *destroy* or *create* a new one. Double Note: This resource name is unique to Terraform and not the AWS services.
2. Once the file is created and ready to be executed, you can run that target resource by calling the following flag in the command line: `-target=aws_s3_bucket.unique_name`.
3. Overall, it will look like this - `terraform apply -target=aws_s3_bucket.unique_name`.
4. This in turn will create a new s3 bucket with the respective details provided within the newly created `resource` block, called `unique_name`.
5. Watch for errors on the command line and confirm your new changes by either typing `yes/no` accordingly. Double check S3 and see if your newly created bucket is there.

# Making changes to an existing resource created
1. Simply make changes to the existing resources.
2. Type `terraform apply -target=target.resource_name`.
3. It will prompt for you to accept the overwriting changes, by stating the entity that will be changed (labeled `forces new resource`).
```
-/+ aws_instance.example
    ami:                      "ami-2757f631" => "ami-b374d5a5" (forces new resource)
    availability_zone:        "us-east-1a" => "<computed>"
    ebs_block_device.#:       "0" => "<computed>"
    ...
```
4. Accept the new changes (Message: `Apply complete! Resources: 1 added, 0 changed, 1 destroyed.`) and visit AWS to see the new changes to the service resource.

# Destroying existing resources

1. Resources can be destroyed using the `terraform destroy` command, which is similar to `terraform apply` but it behaves as if all of the resources have been removed from the configuration.
2. If you want to remove specific resources, use the `-target=` flag in the command.
3. It will display the following message: `Apply complete! Resources: 0 added, 0 changed, 1 destroyed.`.




# Resources and Links
- [TF Examples - AWS](https://github.com/terraform-providers/terraform-provider-aws)
- [TF Examples - AWS](https://github.com/terraform-providers/terraform-provider-google)
- [CLI Commands](https://www.terraform.io/docs/commands/index.html)
- [Cloud Providers Supported](https://www.terraform.io/docs/providers/index.html)
- [Terraform Getting Started Guide](https://learn.hashicorp.com/terraform/getting-started/build)
- [Terraform Apply Command Flags](https://www.terraform.io/docs/commands/apply.html)
- [TF One file Config Apply - Terraform Docs](https://www.terraform.io/docs/internals/resource-addressing.html)
- [TF One file Config Apply - Stack Exchange](https://devops.stackexchange.com/questions/4292/terraform-apply-only-one-tf-file)