---
title: "SLS OAuth"
date: 2019-05-14T19:45:09-04:00
draft: true
---

# SLS OAuth

Outside of the most introductory getting-started style tutorials, any major web application requires authentication and some kind of user records. Actually creating a system to do this is incredibly difficult, and requires substantial devops.

## Background

I'm sure there are some easier ways of doing this, but I had a few goals and angles for this project. As you read this list, notice how it quickly spirals out of control.

1. I wanted to learn [Golang](https://golang.org)
1. I wanted a better understanding of oauth. I didn't want to write my own authentication for projects. I want users to authenticate via some other means (GitHub, LinkedIn, Google, hey, even Facebook or Twitter).
1. I kind of wanted to use Serverless, AWS, and a relational database. This is roughly our stack at work.
1. A relational database means some kind of migration management.
1. A relational database on AWS needs to be inside a VPC for security. Hooray. Note that the VPC [slows down](https://medium.freecodecamp.org/lambda-vpc-cold-starts-a-latency-killer-5408323278dd) Lambda cold starts, which is sad times.

## Groundwork

Serverless is configured by default via a `serverless.yml` file. In the config, you can specify `Resources`, which in the case of AWS use [CloudFormation's template syntax](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-template-resource-type-ref.html).

The first step is going to be adding a [VPC resource](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-ec2-vpc.html). AWS gives you one by default, but I wanted to make one that was designated to the Serverless stack I was standing up.

The worst part about this is specifying a CIDR block, which requires some hexadecimal math that I am not going to discuss in this post. I found this [calculator](https://www.ipaddressguide.com/cidr) very useful to make sure I created a block that didn't overlap with my existing VPC.

I started with using a Go example from one of the Serverless examples. I deleted one of their functions to keep things a little simpler.

I then edited the `serverless.yml` to create a VPC. Here's the [commit](https://github.com/mladlow/sls-oauth/commit/e6b05def000e641d53f42c428bb2f5e7c16b6c52).

It's difficult to know what's required to get a Lambda to be able to access resources inside a VPC. Whenever possible, I default to using the AWS documentation, and there are instructions for [Lambda + VPC](https://docs.aws.amazon.com/lambda/latest/dg/vpc.html). These instructions tell me that I need some subnet IDs and some security group IDs. In order to get those, I'm going to have to create some security group and subnet resources in my `serverless.yml` file. Here's the [commit](https://github.com/mladlow/sls-oauth/commit/84dbb99389dea7151aaa77bcfb308e2866fb86f9).

It's worth noting that with this `serverless.yml` file, the cold start time for the lambda becomes noticable. It's worth researching some remediation for cold starts, but outside the scope of this project. At this point, it's possible to look at the Lambda function in the AWS console and see the Subnets and Security Groups there.

Next I want to add an [AWS Aurora](https://aws.amazon.com/rds/aurora/) RDS Cluster using Postgres. This resource needs to live inside the VPC. Figuring out what was supposed to go in the CloudFormation template for an Aurora instance was considerably more difficult than for a VPC, Subnet, or Security Group. I couldn't quite figure out how to use the CloudFormation function to get multiple availability zones based on the region, for example. I did find a comprehensive resource on [best practices](https://aws.amazon.com/blogs/database/deploy-an-amazon-aurora-postgresql-db-cluster-with-recommended-best-practices-using-aws-cloudformation/), with an associated [github](https://github.com/aws-samples/aws-aurora-cloudformation-samples). In the end, I wasn't sure how to best get around needing to specify a MasterUsername and MasterUserPassword in the `serverless.yml` file, which I really didn't want to do.

Additionally, around the same time I was working on getting RDS working, AWS released a [Data API](https://aws.amazon.com/blogs/aws/new-data-api-for-amazon-aurora-serverless/) for Aurora. While I'd prefer to use Postgres over MySQL, the option to have a database available over HTTPs is pretty exciting. I'm going to be backing off this exact approach next time I work on this project, but the commit with my failing attempt to stand up an RDS cluster is [here](https://github.com/mladlow/sls-oauth/commit/f294286ddea884988d7df7fdae51301521152bbc).
