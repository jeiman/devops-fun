# User Guide for creating AWS services using Teraform

- [S3 Bucket](https://www.terraform.io/docs/providers/aws/r/s3_bucket.html)
- [SQS Queue](https://www.terraform.io/docs/providers/aws/r/sqs_queue.html)
- [Cloudfront Distribution](https://www.terraform.io/docs/providers/aws/r/cloudfront_distribution.html)


# Table of Contents
  * [Multiple Provider Instances using Aliases](#multiple-provider-instances-using-aliases)
  * [Resource Dependencies](#resource-dependencies)
  * [Chapter 3](#chapter-3)


# Other Guides
## Multiple Provider Instances using Aliases
You can optionally define multiple configurations for the same provider, and select which one to use on a per-resource or per-module basis. The primary reason for this is to support multiple regions for a cloud platform; other examples include targeting multiple Docker hosts, multiple Consul hosts, etc.

```
# The default provider configuration
provider "aws" {
  region = "us-east-1"
}

# Additional provider configuration for west coast region
provider "aws" {
  alias  = "west"
  region = "us-west-2"
}
```

### Referring to Alternate Providers
When Terraform needs the name of a provider configuration, it always expects a reference of the form `<PROVIDER NAME>.<ALIAS>`. In the example above, `aws.west` would refer to the provider with the `us-west-2` region.

These references are special expressions. Like references to other named entities (for example, `var.image_id`), they aren't strings and don't need to be quoted. But they are only valid in specific meta-arguments of `resource`, `data`, and `module` blocks, and can't be used in arbitrary expressions.


### Selecting Alternate Providers
By default, resources use a default provider configuration inferred from the first word of the resource type name. For example, a resource of type `aws_instance` uses the default (un-aliased) `aws` provider configuration unless otherwise stated.

To select an aliased provider for a resource or data source, set its `provider` meta-argument to a `<PROVIDER NAME>.<ALIAS>` reference:

```
resource "aws_instance" "foo" {
  provider = aws.west

  # ...
}
```
To select aliased providers for a child module, use its `providers` meta-argument to specify which aliased providers should be mapped to which local provider names inside the module:
```
module "aws_vpc" {
  source = "./aws_vpc"
  providers = {
    aws = aws.west
  }
}
```

## Resource Dependencies
### Implicit and Explicit Dependencies

#### Implicit
```
resource "aws_eip" "ip" {
  instance = "${aws_instance.example.id}"
}
```

By studying the resource attributes used in interpolation expressions, Terraform can automatically infer when one resource depends on another. In the example above, the expression `${aws_instance.example.id}` creates an implicit dependency on the `aws_instance` named example.

Terraform uses this dependency information to determine the correct order in which to create the different resources. In the example above, Terraform knows that the `aws_instance` must be created **before** the `aws_eip`.


#### Explicit
Sometimes there are dependencies between resources that are not visible to Terraform. The `depends_on` argument is accepted by any resource and accepts a list of resources to create explicit dependencies for.

For example, perhaps an application we will run on our EC2 instance expects to use a specific Amazon S3 bucket, but that dependency is configured inside the application code and thus not visible to Terraform. In that case, we can use `depends_on` to explicitly declare the dependency:
```
# New resource for the S3 bucket our application will use.
resource "aws_s3_bucket" "example" {
  # NOTE: S3 bucket names must be unique across _all_ AWS accounts, so
  # this name must be changed before applying this example to avoid naming
  # conflicts.
  bucket = "terraform-getting-started-guide"
  acl    = "private"
}

# Change the aws_instance we declared earlier to now include "depends_on"
resource "aws_instance" "example" {
  ami           = "ami-2757f631"
  instance_type = "t2.micro"

  # Tells Terraform that this EC2 instance must be created only after the
  # S3 bucket has been created.
  depends_on = ["aws_s3_bucket.example"]
}
```