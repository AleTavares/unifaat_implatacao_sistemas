# TF-12 - Bruno Pereira dos Santos - 6324550

## Questões Teóricas:

## Questão 1: Conceitos de CI/CD (Teórica)

a) **CI (Continuous Integration):** 
R-O objetivo principal da Integração Contínua (CI) é integrar frequentemente as alterações de código feitas pelos desenvolvedores em um repositório central. Nessa fase, o código é validado automaticamente por meio de testes, análise de qualidade e processo de build, garantindo que novas alterações não quebrem a aplicação

b) **CD (Continuous Delivery/Deployment):** 
R- O objetivo principal da Entrega/Implantação Contínua (CD) é automatizar a distribuição do artefato gerado no build (imagem Docker, pacote ou aplicação) para ambientes de teste, homologação ou produção. O artefato buildado é preparado e implantado automaticamente ou com mínima intervenção manual.

## Questão 2: Ferramentas de Pipeline (Teórica)

R - Três ferramentas ou serviços que podem ser utilizados para automatizar a fase de CI são:

Jenkins
GitHub Actions
AWS CodeBuild

## Questão 3: Amazon ECR (Teórica)

a) O ECR oferece integração nativa com a AWS, controle de acesso através do IAM, armazenamento privado de imagens e maior segurança para aplicações corporativas. Diferentemente de um Docker Hub público, as imagens podem permanecer totalmente privadas e protegidas por políticas de acesso da AWS.

b) O Amazon ECR é um serviço regional. Cada repositório existe em uma região específica da AWS.

Formato padrão do URI:

<ID_DA_CONTA>.dkr.ecr.<REGIAO>.amazonaws.com/<NOME_REPOSITORIO>

Exemplo:

123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo

## Questão 4: Processo de Push (Prática Teórica)
1.  **Passo de Autenticação:**
Utilizar a AWS CLI para obter um token e realizar login no Docker.

aws ecr get-login-password --region <REGIAO> | docker login --username AWS --password-stdin <URI_ECR>

2.  **Passo de Tagging:**
Marcar a imagem local com o URI completo do repositório ECR.

docker tag imagem-local:tag URI_ECR:tag

3.  **Passo de Upload:**
Enviar a imagem para o ECR.

docker push URI_ECR:tag

## Questão 5: Tarefa Prática Integrada (Simulação com AWS CLI e Docker)

* **ID da Conta AWS:** `123456789012`
* **Região:** `us-east-1`
* **Nome do Repositório ECR:** `web-app-repo`
* **Imagem Local:** `web-app:v1`

**Comandos a serem simulados:**

a) **Criação do Repositório:**

Criação do Repositório
aws ecr create-repository \
  --repository-name web-app-repo \
  --region us-east-1

b) **Autenticação (Login Docker):** 

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com

c) **Tagging da Imagem:** 

docker tag web-app:v1 123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo:v1

d) **Push Final:** 

docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo:v1

## Lista de Comandos - Caso Queira Crie um Arquivo .sh do Item 3

1.
```bash
# Criar diretório principal
mkdir -p ~/aulas_lab/aula012
cd ~/aulas_lab/aula012
# Inicialize o VSCode
code .
```
2. Dockerfile:
```Dockerfile
FROM nginx:alpine

COPY . /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```
3. Comandos Criação
```sh
IMAGE_TAG="V1.0"
# Constrói uma imagem Docker com o nome 'web-app-v1' usando o Dockerfile no diretório atual
docker build -t web-app-v1:$IMAGE_TAG .

# Lista apenas as imagens que contêm 'web-app-v1' no nome
docker images | grep web-app-v1

# Substitua [SEU_ID_DA_CONTA] pelo seu ID real (12 dígitos)
AWS_ACCOUNT_ID="123123123123" 
AWS_REGION="us-east-2" # Altere se necessário
REPO_NAME="app-frontend"

aws ecr create-repository \
--repository-name $REPO_NAME \
--region $AWS_REGION

REPO_URI="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME"
echo "URI do ECR: $REPO_URI"

aws ecr get-login-password --region $AWS_REGION | \
docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

docker tag web-app-v1:$IMAGE_TAG $REPO_URI:$IMAGE_TAG

docker push $REPO_URI:$IMAGE_TAG

aws ecr describe-images \
--repository-name $REPO_NAME \
--region $AWS_REGION \
--query 'imageDetails[].imageTags[0]'
```
## Descrição e Anexos das Prints

```bash
# Comando Configuração AWS
aws configure list
```
![ConfiguraçãoAWS](./prints/PRINT%20AWS%20CONFIGURE%20LIST.PNG)

```bash
# Comando Teste de login no ECR
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
```
![Teste de login no ECR](./prints/AWS%20ECR%20GET%20LOGIN.PNG)

```bash
# Comando Build da imagem Docker
docker build -t web-app-v1:$IMAGE_TAG .
```
![Build da imagem Docker](./prints/PRINT%20DA%20BUILD.PNG)

```bash
# Criação/descrição do repositório ECR
aws ecr create-repository --repository-name $REPO_NAME --region $AWS_REGION e aws ecr describe-repositories --repository-names $REPO_NAME --region $AWS_REGION
```
![Criação/descrição do repositório ECR](./prints/PRINT%20CRIACAO%20E%20DESCRIBE%20ECR-CREATE-REPOSITORY.PNG)

```bash
# Tagging da imagem
docker tag web-app-v1:$IMAGE_TAG $REPO_URI:$IMAGE_TAG
```
![Tagging da imagem](./prints/Docker%20Tag%20e%20Push.PNG)

```bash
# Verificação da imagem local marcada
docker images | grep $REPO_URI
```
![Verificação da imagem local marcada](./prints/PRINT%20DA%20BUILD.PNG)

```bash
# Push para o ECR
docker push $REPO_URI:$IMAGE_TAG
```
![Push para o ECR](./prints/Docker%20Tag%20e%20Push.PNG)

```bash
#Verificação do ECR
aws ecr describe-images --repository-name $REPO_NAME --region $AWS_REGION --query 'imageDetails[].imageTags[0]'
```
![Verificação do ECR](./prints/aws%20ecr%20describe.PNG)