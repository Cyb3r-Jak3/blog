---
author: "Cyb3r Jak3"
title: "R2 API Token Terraform Module"
date: "2024-03-19"
tags: [ Tutorial, Cloudflare, Terraform ]
categories: [ Tutorial, Cloudflare, Terraform ]
thumbnail: "images/terraform/terraform.svg"
---
Now that R2 has [bucket scoped tokens](https://developers.cloudflare.com/r2/api/s3/tokens/), I wanted to create a simple way to generate the S3 tokens that can be used with any S3 compatible service. I was playing around with terraform and created a simple module that will generate the tokens for you. The module is available from the Terraform registry [here](https://registry.terraform.io/modules/Cyb3r-Jak3/r2-api-token/cloudflare/latest) and you can view the source [here](https://github.com/Cyb3r-Jak3/terraform-cloudflare-r2-api-token). Before I break down the module, I want to go over the basics of how to use it.

### Example Usage

The following example will return a token that has read and write access:

```terraform
module "r2-api-token" {
  source  = "Cyb3r-Jak3/r2-api-token/cloudflare"
  version = "1.0.0"
  account_id = "your_account_id"
  buckets = ["bucket-1", "bucket-2"]
}
```

The following example will return a token that has read only access:

```terraform
module "r2-api-token" {
  source  = "Cyb3r-Jak3/r2-api-token/cloudflare"
  version = "3.0.0"
  account_id = "your_account_id"
  buckets = ["bucket-1", "bucket-2"]
  bucket_write = false
}
```

There are outputs from the module of `id` and `secret` that you can use with S3 compatible services. If you want to be able to get the raw token, you can use the following:
  
```terraform
  output "id" {
    value = module.r2-api-token.id
  }
  output "secret" {
    value = module.r2-api-token.secret
  }
```

## Module Breakdown

The main part of the module is:

```terraform
terraform {
  required_version = ">= 1.2.0"
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = ">= 4.13.0"
    }
  }
}

data "cloudflare_api_token_permission_groups" "this" {}

locals {
  resources          = length(var.buckets) > 0 ? { for bucket in var.buckets : "com.cloudflare.edge.r2.bucket.${var.account_id}_default_${bucket}" => "*" } : { "com.cloudflare.edge.r2.bucket.*" = "*" }
  token_bucket_names = length(var.buckets) > 0 ? "All-Buckets" : join(",", var.buckets)
}

resource "cloudflare_api_token" "token" {
  name = var.token_name != "" ? var.token_name : "R2-${join(",", var.buckets)}-${var.bucket_read ? "Read" : ""}-${var.bucket_write ? "Write" : ""}"
  policy {
    permission_groups = compact([
      var.bucket_read ? module.api-permissions.r2["Workers R2 Storage Bucket Item Read"] : null,
      var.bucket_write ? module.api-permissions.r2["Workers R2 Storage Bucket Item Write"] : null,
    ])
    resources = { for bucket in var.buckets : "com.cloudflare.edge.r2.bucket.${var.account_id}_default_${bucket}" => "*" }
  }
  not_before = var.not_before != "" ? var.not_before : timestamp()
  expires_on = var.expires_on != "" ? var.expires_on : null
  condition {
    request_ip {
      in     = var.condition_ip_in
      not_in = var.condition_ip_not_in
    }
  }
}
```

### Resource

```terraform
resource "cloudflare_api_token" "token" {
  name = var.token_name != "" ? var.token_name : "R2-${local.token_bucket_names}-${var.bucket_read ? "Read" : ""}-${var.bucket_write ? "Write" : ""}"
  policy {
    permission_groups = compact([
      var.bucket_read ? data.cloudflare_api_token_permission_groups.this.r2["Workers R2 Storage Bucket Item Read"] : null,
      var.bucket_write ? data.cloudflare_api_token_permission_groups.this.r2["Workers R2 Storage Bucket Item Write"] : null,
    ])
    resources = local.resources
  }
  not_before = var.not_before != "" ? var.not_before : null
  expires_on = var.expires_on != "" ? var.expires_on : null
  condition {
    request_ip {
      in     = var.condition_ip_in
      not_in = var.condition_ip_not_in
    }
  }
}
```

This is the main meat of the module. It will create the token with the following attributes:

* `name` is either the name you pass in or it will be generated based on the buckets and permissions. So token with Read Write and a bucket of `bucket-1` will be `R2-bucket-1-Read-Write`.
* `permissions groups` lookup the ones specified for R2 and will only add the ones that are needed. So if you only want read access, it will only add the read permission. `compact` is used to remove any null values.
* `resources` are generated based on the buckets you pass in. This is something that I had use dev tools to figure out the format of it. So if you pass in `bucket-1` and `bucket-2`, it will generate the following resources:
  * `com.cloudflare.edge.r2.bucket.${var.account_id}_default_bucket-1`
  * `com.cloudflare.edge.r2.bucket.${var.account_id}_default_bucket-2`
* `not_before` and `expires_on` are set to either the values you pass in or the current timestamp and null respectively.
* `condition` allows you to choose the IPs that can use the token. You can either specify a list of IPs that can use the token or a list of IPs that can't use the token. If you don't specify either, then it will allow all IPs to use the token.
* `buckets` is a list of buckets that you want to grant access to. If you don't specify any, then it will grant access to all buckets.

## Inputs

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | Cloudflare Account ID | `string` | n/a | yes |
| <a name="input_bucket_read"></a> [bucket\_read](#input\_bucket\_read) | If true, grant read access to the bucket(s) | `bool` | `true` | no |
| <a name="input_bucket_write"></a> [bucket\_write](#input\_bucket\_write) | If true, grant write access to the bucket(s) | `bool` | `true` | no |
| <a name="input_buckets"></a> [buckets](#input\_buckets) | List of R2 buckets to grant access to. If empty, all buckets will be granted access. | `list(string)` | `[]` | no |
| <a name="input_condition_ip_in"></a> [condition\_ip\_in](#input\_condition\_ip\_in) | List of IP addresses or CIDR notation where the token may be used from. If not specified, the token will be valid for all IP addresses. | `list(string)` | `[]` | no |
| <a name="input_condition_ip_not_in"></a> [condition\_ip\_not\_in](#input\_condition\_ip\_not\_in) | List of IP addresses or CIDR notation where the token should not be used from. | `list(string)` | `[]` | no |
| <a name="input_expires_on"></a> [expires\_on](#input\_expires\_on) | The expiration time on or after which the token MUST NOT be accepted for processing. If not specified, the token will not expire. | `string` | `""` | no |
| <a name="input_not_before"></a> [not\_before](#input\_not\_before) | The time before which the token MUST NOT be accepted for processing. If not specified, the token will be valid immediately. | `string` | `""` | no |
| <a name="input_token_name"></a> [token\_name](#input\_token\_name) | Name of the API token.<br>If none given then the fomart is: `R2-<comma seperate names>-<Read if 'bucket-read'>-<Write if 'bucket-write'>` | `string` | `""` | no |
