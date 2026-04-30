#!/bin/bash
set -euo pipefail

# TF09 - Script de criação de infraestrutura AWS
# Ajuste as variáveis abaixo antes de executar.
# Observação: se a infraestrutura já foi criada manualmente, use este script apenas como documentação.

REGION="us-east-1"
AZ="us-east-1a"
VPC_CIDR="10.0.0.0/16"
PUBLIC_CIDR="10.0.1.0/24"
PRIVATE_CIDR="10.0.2.0/24"
KEY_NAME="Lab009-KeyPair"
MY_IP="$(curl -s https://checkip.amazonaws.com)/32"

aws configure set region "$REGION"

echo "Criando VPC..."
VPC_ID=$(aws ec2 create-vpc   --cidr-block "$VPC_CIDR"   --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=Lab009-VPC}]'   --query 'Vpc.VpcId'   --output text)

aws ec2 modify-vpc-attribute --vpc-id "$VPC_ID" --enable-dns-hostnames
aws ec2 modify-vpc-attribute --vpc-id "$VPC_ID" --enable-dns-support

echo "Criando subnets..."
PUBLIC_SUBNET_ID=$(aws ec2 create-subnet   --vpc-id "$VPC_ID"   --cidr-block "$PUBLIC_CIDR"   --availability-zone "$AZ"   --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=Lab009-Public-Subnet}]'   --query 'Subnet.SubnetId'   --output text)

PRIVATE_SUBNET_ID=$(aws ec2 create-subnet   --vpc-id "$VPC_ID"   --cidr-block "$PRIVATE_CIDR"   --availability-zone "$AZ"   --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=Lab009-Private-Subnet}]'   --query 'Subnet.SubnetId'   --output text)

aws ec2 modify-subnet-attribute --subnet-id "$PUBLIC_SUBNET_ID" --map-public-ip-on-launch

echo "Criando Internet Gateway..."
IGW_ID=$(aws ec2 create-internet-gateway   --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=Lab009-IGW}]'   --query 'InternetGateway.InternetGatewayId'   --output text)

aws ec2 attach-internet-gateway --internet-gateway-id "$IGW_ID" --vpc-id "$VPC_ID"

echo "Criando Route Table pública..."
PUBLIC_RT_ID=$(aws ec2 create-route-table   --vpc-id "$VPC_ID"   --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=Lab009-Public-RT}]'   --query 'RouteTable.RouteTableId'   --output text)

aws ec2 create-route   --route-table-id "$PUBLIC_RT_ID"   --destination-cidr-block "0.0.0.0/0"   --gateway-id "$IGW_ID"

aws ec2 associate-route-table   --route-table-id "$PUBLIC_RT_ID"   --subnet-id "$PUBLIC_SUBNET_ID"

echo "Criando Security Groups..."
WEB_SG_ID=$(aws ec2 create-security-group   --group-name "Lab009-WebServer-SG"   --description "Security Group para Web Server"   --vpc-id "$VPC_ID"   --query 'GroupId'   --output text)

DB_SG_ID=$(aws ec2 create-security-group   --group-name "Lab009-Database-SG"   --description "Security Group para Database"   --vpc-id "$VPC_ID"   --query 'GroupId'   --output text)

aws ec2 authorize-security-group-ingress --group-id "$WEB_SG_ID" --protocol tcp --port 22 --cidr "$MY_IP"
aws ec2 authorize-security-group-ingress --group-id "$WEB_SG_ID" --protocol tcp --port 80 --cidr "0.0.0.0/0"
aws ec2 authorize-security-group-ingress --group-id "$WEB_SG_ID" --protocol tcp --port 443 --cidr "0.0.0.0/0"
aws ec2 authorize-security-group-ingress --group-id "$WEB_SG_ID" --protocol tcp --port 3000 --cidr "0.0.0.0/0"

aws ec2 authorize-security-group-ingress --group-id "$DB_SG_ID" --protocol tcp --port 3306 --source-group "$WEB_SG_ID"
aws ec2 authorize-security-group-ingress --group-id "$DB_SG_ID" --protocol tcp --port 22 --source-group "$WEB_SG_ID"

cat <<EOF
Infraestrutura base criada.

VPC_ID=$VPC_ID
PUBLIC_SUBNET_ID=$PUBLIC_SUBNET_ID
PRIVATE_SUBNET_ID=$PRIVATE_SUBNET_ID
IGW_ID=$IGW_ID
PUBLIC_RT_ID=$PUBLIC_RT_ID
WEB_SG_ID=$WEB_SG_ID
DB_SG_ID=$DB_SG_ID
EOF
