# ============================================
# LIMPEZA - Lab 12
# Antes de rodar, defina suas variáveis:
# export AWS_ACCOUNT_ID="SEU_ID_12_DIGITOS"
# export AWS_REGION="us-east-1"
# ============================================

# 1 - Parar e remover containers locais
docker container prune -f

# 2 - Remover imagens locais
docker rmi $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/app-frontend:v1
docker rmi web-app-v1:v1
docker rmi nginx:alpine

# 3 - Limpeza geral Docker
docker system prune -a --volumes -f

# 4 - Deletar imagem do ECR
aws ecr batch-delete-image \
  --repository-name app-frontend \
  --region $AWS_REGION \
  --image-ids imageTag=v1

# 5 - Deletar repositório ECR
aws ecr delete-repository \
  --repository-name app-frontend \
  --region $AWS_REGION \
  --force

# 6 - Verificação final
echo "=== Repositórios ECR restantes ==="
aws ecr describe-repositories --region $AWS_REGION

echo "=== Imagens Docker locais ==="
docker images