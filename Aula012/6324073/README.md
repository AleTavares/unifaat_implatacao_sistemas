# TF - Tarefa Final - Aula 12: CI/CD Básico e Registro de Imagens (ECR)

**Aluno:** Leonardo Frazão Sano  
**RA:** 6324073  
**Disciplina:** Implementação de Servidor e Nuvem (Cloud)  
**Aula:** 12 — CI/CD Básico e Registro de Imagens (ECR)

---

## Questão 1: Conceitos de CI/CD

### a) CI — Continuous Integration

O objetivo principal da CI é **integrar e validar automaticamente** o código novo ao repositório principal de forma contínua. A cada commit ou pull request, um pipeline automatizado executa testes unitários, análise estática de código e o build da aplicação (incluindo a construção da imagem Docker). Isso garante que erros sejam detectados cedo, antes de chegarem ao ambiente de produção.

### b) CD — Continuous Delivery / Deployment

O objetivo principal do CD é **entregar o artefato buildado** (imagem Docker, binário, pacote) para um ambiente de staging ou produção de forma automatizada e confiável. Após o build aprovado na fase de CI, o CD realiza o push da imagem para o registry (ex.: ECR), atualiza os manifests de infraestrutura e aplica o deploy no ambiente alvo (ex.: ECS, EKS), garantindo que a versão mais recente esteja sempre disponível.

---

## Questão 2: Ferramentas de Pipeline CI

Três ferramentas que automatizam a fase de CI (testes e build de imagem Docker):

1. **GitHub Actions** — serviço de CI/CD integrado ao GitHub; executa workflows YAML disparados por eventos de repositório (push, pull_request).
2. **Jenkins** — servidor de automação open-source amplamente utilizado; suporta pipelines declarativos via `Jenkinsfile` e possui vasto ecossistema de plugins.
3. **AWS CodeBuild** — serviço gerenciado de build da AWS; executa comandos definidos em `buildspec.yml`, integra-se nativamente com ECR, CodePipeline e IAM.

---

## Questão 3: Amazon ECR

### a) Vantagem do ECR vs Docker Hub público

O ECR oferece **controle de acesso granular via IAM** e isolamento de rede privada. Imagens ficam restritas à conta AWS e nunca ficam expostas publicamente, eliminando o risco de vazamento de código proprietário. Além disso, o ECR possui **scanning automático de vulnerabilidades** (Amazon Inspector), **replicação cross-region** e **integração nativa com ECS, EKS e CodeBuild**, sem necessidade de gerenciar credenciais externas — autenticação é feita via roles IAM.

### b) ECR: Regional ou Global?

O ECR é um **serviço regional**. Cada repositório pertence a uma região específica da AWS.

**Formato padrão do URI:**

```
<account-id>.dkr.ecr.<region>.amazonaws.com/<repository-name>
```

**Exemplo:**

```
123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo
```

---

## Questão 4: Processo de Push — Ordem Correta

### Passo 1 — Autenticação (AWS CLI + Docker CLI)

Ferramenta: `aws` (AWS CLI) combinado com `docker login`

```bash
aws ecr get-login-password --region <region> \
  | docker login --username AWS --password-stdin \
    <account-id>.dkr.ecr.<region>.amazonaws.com
```

O AWS CLI obtém um token de autenticação temporário (válido por 12h) e o redireciona para o `docker login`, autenticando o Docker daemon no registry do ECR.

### Passo 2 — Tagging (Docker CLI)

Ferramenta: `docker tag`

```bash
docker tag <imagem-local>:<tag> \
  <account-id>.dkr.ecr.<region>.amazonaws.com/<repositorio>:<tag>
```

A imagem local recebe um segundo nome (tag) que contém o URI completo do repositório ECR, necessário para que o Docker saiba para onde enviar a imagem.

### Passo 3 — Upload (Docker CLI)

Ferramenta: `docker push`

```bash
docker push <account-id>.dkr.ecr.<region>.amazonaws.com/<repositorio>:<tag>
```

O Docker envia os layers da imagem para o ECR. Layers já presentes no registry são pulados (deduplicação por hash SHA256).

---

## Questão 5: Tarefa Prática Integrada

Valores assumidos:
- **ID da Conta AWS:** `123456789012`
- **Região:** `us-east-1`
- **Nome do Repositório ECR:** `web-app-repo`
- **Imagem Local:** `web-app:v1`

### a) Criação do Repositório

```bash
aws ecr create-repository \
  --repository-name web-app-repo \
  --region us-east-1
```

### b) Autenticação — Login Docker no ECR

```bash
aws ecr get-login-password --region us-east-1 \
  | docker login --username AWS --password-stdin \
    123456789012.dkr.ecr.us-east-1.amazonaws.com
```

### c) Tagging da Imagem

```bash
docker tag web-app:v1 \
  123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo:v1
```

### d) Push Final para o ECR

```bash
docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo:v1
```

---

## Questão 6: Evidências Práticas da Execução do Lab012

### Lista de Comandos Executados

```bash
# Configuração AWS
aws configure list

# Variáveis de ambiente
export AWS_REGION=us-east-1
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export REPO_NAME=web-app-repo
export IMAGE_TAG=v1
export REPO_URI=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME

# Login no ECR
aws ecr get-login-password --region $AWS_REGION \
  | docker login --username AWS --password-stdin \
    $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# Build da imagem
docker build -t web-app-v1:$IMAGE_TAG .

# Criação do repositório ECR
aws ecr create-repository --repository-name $REPO_NAME --region $AWS_REGION

# Verificação do repositório
aws ecr describe-repositories --repository-names $REPO_NAME --region $AWS_REGION

# Tagging
docker tag web-app-v1:$IMAGE_TAG $REPO_URI:$IMAGE_TAG

# Verificação local
docker images | grep $REPO_URI

# Push para o ECR
docker push $REPO_URI:$IMAGE_TAG

# Verificação remota
aws ecr describe-images \
  --repository-name $REPO_NAME \
  --region $AWS_REGION \
  --query 'imageDetails[].imageTags[0]'
```

### Descrição das Evidências

| Arquivo | Comando | Descrição |
|---|---|---|
| `evidencias/01-aws-configure-list.txt` | `aws configure list` | Credenciais AWS configuradas (chaves ocultadas) |
| `evidencias/02-ecr-login.txt` | `aws ecr get-login-password \| docker login` | Resultado do login com mensagem `Login Succeeded` |
| `evidencias/03-docker-build.txt` | `docker build -t web-app-v1:v1 .` | Saída do build com `Successfully built` |
| `evidencias/04-ecr-create-repo.txt` | `aws ecr create-repository` | JSON de criação do repositório com `repositoryUri` |
| `evidencias/05-ecr-describe-repos.txt` | `aws ecr describe-repositories` | Confirmação do repositório existente na região |
| `evidencias/06-docker-tag.txt` | `docker tag web-app-v1:v1 <REPO_URI>:v1` | Comando de tagging sem erros |
| `evidencias/07-docker-images.txt` | `docker images \| grep <REPO_URI>` | Imagem local com URI completo do ECR |
| `evidencias/08-docker-push.txt` | `docker push <REPO_URI>:v1` | Upload dos layers com digest SHA256 |
| `evidencias/09-ecr-describe-images.txt` | `aws ecr describe-images` | Tag `v1` confirmada no registry remoto |

### Observações sobre a Execução

- Comandos executados em ambiente Linux (WSL2 Ubuntu 24.04) com Docker Desktop integrado.
- A autenticação no ECR usa token temporário de 12 horas gerado via `aws ecr get-login-password`; tokens expirados causam erro `no basic auth credentials` no push.
- O comando `aws ecr create-repository` retorna erro `RepositoryAlreadyExistsException` se o repositório já existe — comportamento esperado, não é falha.
- Layers de imagens Docker são enviados em paralelo; layers já presentes no ECR são pulados com `Layer already exists`, reduzindo tempo de push em re-deploys.
- O bônus EKS não foi executado por ausência de cluster EKS ativo no ambiente de laboratório.
