# TF - Aula 12: CI/CD Básico e Registro de Imagens (ECR)

**Disciplina:** Implementação de Servidor e Nuvem (Cloud)  
**Aluno:** Vinicius Gigante  
**RA:** 6324558  
**Aula:** 12 - CI/CD Básico e Registro de Imagens (ECR)

---

## Questão 1: Conceitos de CI/CD

**a) CI (Continuous Integration):**  
O objetivo principal da integração contínua é automatizar a validação do código sempre que um desenvolvedor envia alterações ao repositório. Nessa fase, o código é compilado, testado e uma imagem Docker é construída (build), garantindo que novas alterações não quebrem o que já estava funcionando.

**b) CD (Continuous Delivery/Deployment):**  
O objetivo principal é automatizar a entrega do artefato gerado na fase de CI (a imagem Docker) para um ambiente de produção ou pré-produção. O artefato é publicado em um registro de imagens (como o ECR) e, em seguida, implantado automaticamente na infraestrutura de destino (como o EKS).

---

## Questão 2: Ferramentas de Pipeline (CI)

Três ferramentas que podem automatizar a fase de CI:

1. **GitHub Actions** — integrado ao GitHub, permite criar workflows que executam testes e build de imagens Docker automaticamente a cada push.
2. **Jenkins** — ferramenta open source amplamente usada para criar pipelines de CI/CD com suporte a Docker e AWS.
3. **AWS CodeBuild** — serviço gerenciado da AWS que compila código, executa testes e gera artefatos, integrando-se nativamente com o ECR.

---

## Questão 3: Amazon ECR

**a) Principal vantagem do ECR sobre o Docker Hub público:**  
O ECR é um registro privado e gerenciado pela AWS, integrado nativamente com serviços como IAM, EKS e ECS. Isso garante controle de acesso granular via políticas IAM, eliminando a exposição de imagens proprietárias em repositórios públicos. Além disso, a comunicação entre os serviços AWS e o ECR ocorre dentro da própria rede da AWS, reduzindo latência e riscos de segurança.

**b) ECR é regional ou global?**  
O ECR é um serviço **regional** — cada região da AWS possui seus próprios repositórios. O formato padrão do URI de um repositório ECR é:

```
<ID_DA_CONTA>.dkr.ecr.<REGIÃO>.amazonaws.com/<NOME_DO_REPOSITÓRIO>
```

Exemplo:
```
600627346835.dkr.ecr.us-east-1.amazonaws.com/app-frontend
```

---

## Questão 4: Processo de Push

**1. Passo de Autenticação** (AWS CLI + Docker):  
Obter um token temporário da AWS e usá-lo para autenticar o cliente Docker no ECR:
```bash
aws ecr get-login-password --region <REGIÃO> | \
docker login --username AWS --password-stdin <ID_CONTA>.dkr.ecr.<REGIÃO>.amazonaws.com
```

**2. Passo de Tagging** (Docker CLI):  
Marcar a imagem local com o URI completo do repositório ECR:
```bash
docker tag <IMAGEM_LOCAL>:<TAG> <URI_ECR>:<TAG>
```

**3. Passo de Upload** (Docker CLI):  
Enviar a imagem tagada para o repositório remoto no ECR:
```bash
docker push <URI_ECR>:<TAG>
```

---

## Questão 5: Tarefa Prática Integrada

Valores assumidos:
- **ID da Conta AWS:** `123456789012`
- **Região:** `us-east-1`
- **Nome do Repositório ECR:** `web-app-repo`
- **Imagem Local:** `web-app:v1`

**a) Criação do Repositório:**
```bash
aws ecr create-repository \
  --repository-name web-app-repo \
  --region us-east-1
```

**b) Autenticação (Login Docker):**
```bash
aws ecr get-login-password --region us-east-1 | \
docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com
```

**c) Tagging da Imagem:**
```bash
docker tag web-app:v1 123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo:v1
```

**d) Push Final:**
```bash
docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo:v1
```

---

## Questão 6: Evidências Práticas

### Comandos Executados (em ordem sequencial)

```bash
# Verificar Account ID
aws sts get-caller-identity --query Account --output text

# Definir variáveis de ambiente
export AWS_ACCOUNT_ID="600627346835"
export AWS_REGION="us-east-1"
export REPO_NAME="app-frontend"
export IMAGE_TAG="v1"
export REPO_URI="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME"

# Configurar credenciais AWS
aws configure

# Build da imagem Docker
docker build -t web-app-v1:$IMAGE_TAG .

# Criar repositório ECR
aws ecr create-repository \
  --repository-name $REPO_NAME \
  --region $AWS_REGION

# Autenticar Docker no ECR
aws ecr get-login-password --region $AWS_REGION | \
docker login --username AWS --password-stdin "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

# Tagging da imagem
docker tag web-app-v1:$IMAGE_TAG $REPO_URI:$IMAGE_TAG

# Verificar imagem tagada localmente
docker images | grep $REPO_URI

# Push para o ECR
docker push $REPO_URI:$IMAGE_TAG

# Verificar imagem no ECR
aws ecr describe-images \
  --repository-name $REPO_NAME \
  --region $AWS_REGION \
  --query 'imageDetails[].imageTags[0]'
```

### Descrição das Evidências

| Arquivo | Descrição |
|---|---|
| `1-aws-configure.png` | Saída do comando `aws configure list` mostrando as credenciais e região configuradas |
| `2-build-image.png` | Execução do `docker build` com saída de sucesso da construção da imagem `web-app-v1:v1` |
| `3-create-repository.png` | Criação do repositório `app-frontend` no ECR via AWS CLI com retorno do ARN e URI |
| `4-push.png` | Execução do `docker push` mostrando o upload de cada layer da imagem para o ECR |
| `5-login-ecr.png` | Autenticação do Docker no ECR com a mensagem `Login Succeeded` |
| `6-describe.png` | Verificação remota via `aws ecr describe-images` confirmando a tag `"v1"` no repositório |

### Observações

- As variáveis de ambiente precisam ser redefinidas a cada nova sessão do terminal Git Bash, pois não são persistidas entre sessões.
- O comando `$env:VAR` é sintaxe do PowerShell e não funciona no Git Bash; a sintaxe correta é `export VAR="valor"`.
- Os layers do push foram enviados rapidamente na segunda execução pois o ECR detectou as camadas já existentes e reutilizou o cache.
- O repositório foi nomeado `app-frontend` em vez de `web-app-repo` conforme adaptação feita durante a execução do lab.