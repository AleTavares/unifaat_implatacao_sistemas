#!/bin/bash
set -euo pipefail

# TF09 - Script de limpeza de infraestrutura AWS
# Preencha os IDs antes de executar. Confira no console da AWS para evitar apagar recurso errado.

WEB_INSTANCE_ID=""
DB_INSTANCE_ID=""
WEB_SG_ID=""
DB_SG_ID=""
IGW_ID=""
VPC_ID=""
PUBLIC_SUBNET_ID=""
PRIVATE_SUBNET_ID=""

if [ -n "$WEB_INSTANCE_ID" ] || [ -n "$DB_INSTANCE_ID" ]; then
  aws ec2 terminate-instances --instance-ids $WEB_INSTANCE_ID $DB_INSTANCE_ID
  aws ec2 wait instance-terminated --instance-ids $WEB_INSTANCE_ID $DB_INSTANCE_ID
fi

if [ -n "$WEB_SG_ID" ]; then
  aws ec2 delete-security-group --group-id "$WEB_SG_ID" || true
fi

if [ -n "$DB_SG_ID" ]; then
  aws ec2 delete-security-group --group-id "$DB_SG_ID" || true
fi

if [ -n "$IGW_ID" ] && [ -n "$VPC_ID" ]; then
  aws ec2 detach-internet-gateway --internet-gateway-id "$IGW_ID" --vpc-id "$VPC_ID" || true
  aws ec2 delete-internet-gateway --internet-gateway-id "$IGW_ID" || true
fi

if [ -n "$PUBLIC_SUBNET_ID" ]; then
  aws ec2 delete-subnet --subnet-id "$PUBLIC_SUBNET_ID" || true
fi

if [ -n "$PRIVATE_SUBNET_ID" ]; then
  aws ec2 delete-subnet --subnet-id "$PRIVATE_SUBNET_ID" || true
fi

if [ -n "$VPC_ID" ]; then
  aws ec2 delete-vpc --vpc-id "$VPC_ID" || true
fi

echo "Limpeza concluída. Verifique o console da AWS para confirmar se não há recursos órfãos."
