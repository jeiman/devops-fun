# Vault

## Setup Process
Vault is running Version 2 of KV. It has support for versioning and other features.

When running v2 of the `kv` backend, a key can retain a configurable number of versions. This defaults to 10 versions. The older versions' metadata and data can be retrieved. Additionally, Check-and-Set operations can be used to avoid overwriting data unintentionally.

When a version is deleted the underlying data is not removed, rather it is marked as deleted. Deleted versions can be undeleted. To permanently remove a version's data the destroy command or API endpoint can be used. Additionally all versions and metadata for a key can be deleted by deleting on the metadata command or API endpoint. Each of these operations can be ACL'ed differently, restricting who has permissions to soft delete, undelete, or fully remove data.

## Commands
**NOTE: The secret main path is needed for when you're trying to add, delete or update values in a directory, ie `secret/**/`**

### Add a new secret directory followed by a key-pair value of FOO=bar
`vault kv put secret/path/to/secret/dir FOO=bar`

Following output will appear:

```
Key              Value
---              -----
created_time     2019-11-10T11:52:41.695629503Z
deletion_time    n/a
destroyed        false
version          1
```

### Create/Add key-pair that are can't be parsed via the command line argument
`echo "BEGINRSAKEY\ndjsakdj kjkjdkasjkdsajk kjkdajdkjkaddsajd28738dsadk" | vault kv put secret/ssh SSH_KEY=-`

The key symbol is the `-` at the end of the command. It indicates that it will append the string at the end of the command.

### Add a new key-pair value to an existing secret directory 
`vault kv patch secret/path/to/dir NAME=jeiman`

Following output will appear:

```
Key              Value
---              -----
created_time     2019-11-10T11:53:42.899449962Z
deletion_time    n/a
destroyed        false
version          2
```

As you can see, with the new patch method, the version has updated to 2. It will continue to do so till 10.  The oldest versions are permanently deleted and you won't be able to read them.

### Retrieve keys from a directory
`vault kv get secret/creds`

Following output will appear:

```
====== Metadata ======
Key              Value
---              -----
created_time     2019-06-06T06:03:26.595978Z
deletion_time    n/a
destroyed        false
version          5

====== Data ======
Key         Value
---         -----
passcode    my-long-passcode
```

### List all key names at the specified location
`vault kv list secret/my-app`

Following output will appear:
```
Keys
----
admin_creds
domain
eng_creds
qa_creds
release
```

## Current secret directories

- `secret/aws/s3/production`
- `secret/aws/ec2/production`

### TODO
- `secret/api/production`
- `secret/api/staging`
- `secret/api/development`

Just indicates what is residing in those secret directories.

## Sources

- [Setting up Vault on a Linux Server (without HTTPS)](https://computingforgeeks.com/install-and-configure-vault-server-linux/)
- [Vault CLI Commands](https://www.vaultproject.io/docs/commands/index.html)
- [Setting Up Locally](https://learn.hashicorp.com/vault/getting-started/deploy)