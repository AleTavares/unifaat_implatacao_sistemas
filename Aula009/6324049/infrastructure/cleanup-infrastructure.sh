#!/bin/bash
# TF09 - Script de Limpeza de Infraestrutura
# Aluno: Danilo Lenardi de Almeida
# RA: 6324049

echo "=== Iniciando limpeza da infraestrutura TF09 ==="

REGION="us-east-1"
VPC_ID="vpc-07c7c0923d6c3e926"
INSTANCE_ID="i-014f28246843ebc83"
IGW_ID="igw-08c3940a2775ff4af"
PUBLIC_SUBNET_ID="subnet-038979d8918bc203e"
PRIVATE_SUBNET_ID="subnet-0871b81f0aff74b1b"
RT_ID="rtb-0f3203e98dbfc3ec4"
SG_WEB_ID="sg-0c2436eecf9ba66f2"
SG_DB_ID="sg-01e9afcd38989916d"

# EC2
echo "[1/7] Terminando instancia EC2..."
aws ec2 terminate-instances --instance-ids $INSTANCE_ID --region $REGION
echo "Aguardando instancia terminar..."
aws ec2 wait instance-terminated --instance-ids $INSTANCE_ID --region $REGION
echo "EC2 terminada!"

# Key Pair
echo "[2/7] Deletando Key Pair..."
aws ec2 delete-key-pair --key-name TF09-KeyPair --region $REGION
echo "Key Pair deletada!"

# Security Groups
echo "[3/7] Deletando Security Groups..."
aws ec2 delete-security-group --group-id $SG_DB_ID --region $REGION
aws ec2 delete-security-group --group-id $SG_WEB_ID --region $REGION
echo "Security Groups deletados!"

# Subnets
echo "[4/7] Deletando Subnets..."
aws ec2 delete-subnet --subnet-id $PUBLIC_SUBNET_ID --region $REGION
aws ec2 delete-subnet --subnet-id $PRIVATE_SUBNET_ID --region $REGION
echo "Subnets deletadas!"

# Route Table
echo "[5/7] Deletando Route Table..."
aws ec2 delete-route-table --route-table-id $RT_ID --region $REGION
echo "Route Table deletada!"

# Internet Gateway
echo "[6/7] Deletando Internet Gateway..."
aws ec2 detach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID --region $REGION
aws ec2 delete-internet-gateway --internet-gateway-id $IGW_ID --region $REGION
echo "Internet Gateway deletado!"

# VPC
echo "[7/7] Deletando VPC..."
aws ec2 delete-vpc --vpc-id $VPC_ID --region $REGION
echo "VPC deletada!"

echo ""
echo "=== Limpeza concluida! Todos os recursos foram removidos ==="
echo "Verifique o console AWS para confirmar que nao ha recursos ativos."
