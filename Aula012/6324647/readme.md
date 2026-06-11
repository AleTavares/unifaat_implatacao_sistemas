# TF012 - Respostas das Questões 1 a 5

**RA:** 6324647  
**Disciplina:** Implementação de Servidor e Nuvem (Cloud)  
**Aula:** 12 - CI/CD Básico e Registro de Imagens (ECR)

---

## Questão 1: Conceitos de CI/CD

Defina as duas fases principais do fluxo de CI/CD:

a) **CI (Continuous Integration):** O objetivo principal é integrar o código de diferentes desenvolvedores frequentemente em um repositório compartilhado. A cada integração, o código passa por build automatizado e testes, detectando erros rapidamente e garantindo que o código esteja sempre em um estado funcional.

b) **CD (Continuous Delivery/Deployment):** O objetivo principal é automatizar a entrega do artefato buildado para ambientes de homologação ou produção. O artefato (ex: imagem Docker) é validado e disponibilizado para deploy de forma contínua e confiável, reduzindo o esforço manual e o risco de falhas.

---

## Questão 2: Ferramentas de Pipeline

Três ferramentas/serviços para automatizar a fase de CI:

1. **GitHub Actions** - ferramenta de código aberto integrada ao GitHub que executa workflows de build e testes automaticamente.
2. **AWS CodeBuild** - serviço gerenciado da AWS que compila código, executa testes e gera artefatos como imagens Docker.
3. **Jenkins** - ferramenta open source amplamente usada para criar pipelines de CI/CD com grande flexibilidade de plugins.

---

## Questão 3: Amazon ECR

a) A principal vantagem do ECR em relação ao Docker Hub público é a **segurança e privacidade**: o ECR é integrado ao IAM da AWS, permitindo controle granular de acesso. As imagens ficam em repositórios privados dentro da própria infraestrutura AWS, sem exposição pública, além de suportar criptografia em repouso e em trânsito.

b) O ECR é um serviço **regional**. O formato padrão do URI de um repositório ECR é:

```
<account-id>.dkr.ecr.<region>.amazonaws.com/<repository-name>
```

Exemplo: `123456789012.dkr.ecr.us-east-1.amazonaws.com/meu-repositorio`

---

## Questão 4: Processo de Push

Sequência correta de passos para enviar uma imagem local para o ECR:

1. **Passo de Autenticação** (AWS CLI):  
   Obter o token de autenticação do ECR e fazer login no Docker:
   ```bash
   aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <account-id>.dkr.ecr.<region>.amazonaws.com
   ```

2. **Passo de Tagging** (Docker CLI):  
   Marcar a imagem local com o URI completo do repositório ECR:
   ```bash
   docker tag <imagem-local>:<tag> <account-id>.dkr.ecr.<region>.amazonaws.com/<repositorio>:<tag>
   ```

3. **Passo de Upload** (Docker CLI):  
   Enviar a imagem tagueada para o ECR:
   ```bash
   docker push <account-id>.dkr.ecr.<region>.amazonaws.com/<repositorio>:<tag>
   ```

---

## Questão 5: Tarefa Prática Integrada

Valores assumidos:
- **ID da Conta AWS:** `123456789012`
- **Região:** `us-east-1`
- **Nome do Repositório ECR:** `web-app-repo`
- **Imagem Local:** `web-app:v1`

a) **Criação do Repositório:**
```bash
aws ecr create-repository --repository-name web-app-repo --region us-east-1
```

b) **Autenticação (Login Docker):**
```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com
```

c) **Tagging da Imagem:**
```bash
docker tag web-app:v1 123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo:v1
```

d) **Push Final:**
```bash
docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo:v1
```

---

## Comandos Utilizados no Lab012 (Seções 1 a 5)

### Seção 1: Preparação da Imagem Local e Definição de Variáveis

```bash
# Criar diretório de trabalho
mkdir -p ~/aulas_lab/aula012
cd ~/aulas_lab/aula012

# Abrir VSCode
code .
```

Dockerfile utilizado:
```Dockerfile
FROM nginx:alpine
COPY . /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

```bash
# Definir tag da imagem
IMAGE_TAG="V1.0"

# Build da imagem Docker
docker build -t web-app-v1:$IMAGE_TAG .

# Verificar imagem criada
docker images | grep web-app-v1

# Definir variáveis de ambiente AWS
AWS_ACCOUNT_ID="123123123123"
AWS_REGION="us-east-2"
REPO_NAME="app-frontend"
```

### Seção 2: Criação do Repositório ECR

```bash
# Criar repositório ECR
aws ecr create-repository \
--repository-name $REPO_NAME \
--region $AWS_REGION

# Obter e exibir o URI do repositório
REPO_URI="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME"
echo "URI do ECR: $REPO_URI"
```

### Seção 3: Autenticação (Login Docker)

```bash
# Obter token de login e autenticar Docker com o ECR
aws ecr get-login-password --region $AWS_REGION | \
docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
```

> Resultado esperado: mensagem `Login Succeeded`

### Seção 4: Tagging e Push (Upload)

```bash
# Taguear a imagem local com o URI completo do ECR
docker tag web-app-v1:$IMAGE_TAG $REPO_URI:$IMAGE_TAG

# Verificar imagem tagueada
docker images | grep $REPO_URI

# Enviar imagem para o ECR
docker push $REPO_URI:$IMAGE_TAG
```

### Seção 5: Verificação Remota

```bash
# Confirmar que a imagem foi carregada no repositório ECR
aws ecr describe-images \
--repository-name $REPO_NAME \
--region $AWS_REGION \
--query 'imageDetails[].imageTags[0]'
```

> Resultado esperado: a tag `V1.0` exibida, comprovando o upload.

---

## Descrição das Evidências Coletadas

### Parte 1: Preparação e Configuração

**Evidência 1 - Configuração AWS (`aws configure list`)**  
Print do terminal exibindo as credenciais AWS configuradas no ambiente, incluindo o nome do perfil, região padrão e output format. As chaves de acesso sensíveis foram ocultadas para segurança.

![Configuração AWS](./Prints/aws%20configure%20list.PNG)

**Evidência 2 - Login no ECR (`Login Succeeded`)**  
Print do terminal mostrando a execução do comando `aws ecr get-login-password` combinado com `docker login`. A mensagem `Login Succeeded` confirma que o Docker foi autenticado com sucesso junto ao Amazon ECR.

![Teste de login no ECR](./Prints/login%20succeeded.PNG)

**Evidência 3 - Build da imagem Docker**  
Print do terminal com a saída do comando `docker build -t web-app-v1:$IMAGE_TAG .`, mostrando o processo de construção da imagem camada por camada a partir do Dockerfile baseado em `nginx:alpine`, finalizando com sucesso.

![Build da imagem Docker](./Prints/build%20imagen.PNG)

### Parte 2: Registro e Push da Imagem

**Evidência 4 - Criação/descrição do repositório ECR**  
Print do terminal com a resposta JSON dos comandos `aws ecr create-repository` e `aws ecr describe-repositories`, confirmando a criação do repositório `app-frontend` na região configurada e exibindo seu URI completo.

![Criação/descrição do repositório ECR](./Prints/descricao%20ecr.PNG)

**Evidência 5 - Tagging da imagem**  
Print do terminal após execução do `docker tag`, seguido da verificação com `docker images | grep $REPO_URI`, confirmando que a imagem local foi marcada corretamente com o URI completo do repositório ECR.

![Tagging da imagem](./Prints/verificao%20do%20ecr.PNG)

**Evidência 6 - Verificação da imagem local marcada**  
Print do terminal exibindo a saída do comando `docker images | grep $REPO_URI`, listando a imagem com o nome completo do ECR e a tag `V1.0`, confirmando que o tagging foi aplicado corretamente antes do push.

![Verificação da imagem local marcada](./Prints/imagen%20local.PNG)

**Evidência 7 - Push para o ECR**  
Print do terminal com a saída do comando `docker push $REPO_URI:$IMAGE_TAG`, mostrando o upload de cada layer da imagem para o Amazon ECR e a confirmação de envio bem-sucedido com o digest da imagem.

![Push para o ECR](./Prints/push%20ecr.PNG)

