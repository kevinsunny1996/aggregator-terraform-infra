# VPC for the whole pipeline 
resource "aws_vpc" "e2e_ds_app" {
  cidr_block = var.vpc_cidr_block
}

# Public subnet to host NAT Gateway for AWS Glue to connect with external API
resource "aws_subnet" "ng_public_subnet" {
  depends_on = [
    aws_vpc.e2e_ds_app
  ]

  # VPC in which the subnet has to be created
  vpc_id = aws_vpc.e2e_ds_app.id
  cidr_block = var.public_subnet_cidr_block
  map_public_ip_on_launch = true
}

resource "aws_subnet" "agg_glue_private_subnet" {
  depends_on = [
    aws_vpc.e2e_ds_app,
    aws_subnet.ng_public_subnet
  ]

  vpc_id = aws_vpc.e2e_ds_app.id
  cidr_block = var.private_subnet_cidr_block
}
