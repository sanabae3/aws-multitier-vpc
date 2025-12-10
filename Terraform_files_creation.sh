#!/usr/bin/env bash

# create terraform files
touch main.tf
touch network.tf
touch security.tf
touch ec2.tf
touch route53.tf
touch cloudwatch.tf
touch variables.tf
touch outputs.tf

echo "Terraform file structure created:"
ls *.tf
