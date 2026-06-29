# TF012 - Diogo Vieira Amori-RA 6324639

## Disciplina
Implementação de servidor e nuvem (cloud)

## Aula
12 - CI/CD Básico e Registro de Imagens (ECR)

## Respostas das questões teóricas

### Questão 1: Conceitos de CI/CD

**a) CI (Continuous Integration)**
- Objetivo principal: integrar alterações de código em um repositório central com frequência e garantir que cada alteração seja validada automaticamente.
- O que acontece com o código: ele é compilado/buildado e testado automaticamente, detectando erros de integração o mais cedo possível.

**b) CD (Continuous Delivery/Deployment)**
- Objetivo principal: entregar o artefato buildado para um ambiente de produção ou deixá-lo pronto para implantação.
- O que acontece com o artefato buildado: ele é empacotado e armazenado em um repositório seguro (por exemplo ECR) para que possa ser implantado automaticamente ou manualmente.

### Questão 2: Ferramentas de Pipeline (CI)

Três ferramentas/serviços que podem automatizar a fase de CI:
- Jenkins
- GitHub Actions
- AWS CodeBuild

### Questão 3: Amazon ECR

**a) Vantagem do ECR sobre Docker Hub público**
- O ECR oferece repositórios privados com autenticação via IAM e controle de acesso granular, garantindo que imagens privadas fiquem seguras.

**b) ECR é global ou regional?**
- O ECR é um serviço regional.

**Formato padrão do URI de um repositório ECR**
- `123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo`

### Questão 4: Processo de Push

1. **Passo de Autenticação:**
   - `aws ecr get-login-password --region <região> | docker login --username AWS --password-stdin <account>.dkr.ecr.<região>.amazonaws.com`

2. **Passo de Tagging:**
   - `docker tag <imagem-local>:<tag> <repository-uri>:<tag>`

3. **Passo de Upload:**
   - `docker push <repository-uri>:<tag>`

### Questão 5: Simulação de comandos práticos

**Dados:**
- ID da conta: `123456789012`
- Região: `us-east-1`
- Repositório: `web-app-repo`
- Imagem local: `web-app:v1`

**a) Criação do repositório**
- `aws ecr create-repository --repository-name web-app-repo --region us-east-1`

**b) Autenticação Docker**
- `aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com`

**c) Tagging da imagem**
- `docker tag web-app:v1 123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo:v1`

**d) Push final**
- `docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo:v1`

## Comandos do TF e evidências

### Comandos simulados com os valores do TF012
1. `aws ecr create-repository --repository-name web-app-repo --region us-east-1`
2. `aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com`
3. `docker tag web-app:v1 123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo:v1`
4. `docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo:v1`

### Prints exigidos pelo TF012
Todos os prints estão salvos na pasta `evidencias/`.

- `evidencias/aws-config-list.png`: print do comando `aws configure list` mostrando as credenciais configuradas.
- `evidencias/aws_caller_identity.png`: print do comando `aws sts get-caller-identity` mostrando a conta AWS usada.
- `evidencias/ecr_create_repository.png`: print do comando `aws ecr create-repository --repository-name app-frontend-6324639 --region sa-east-1 --image-scanning-configuration scanOnPush=false`.
- `evidencias/ecr_describe_repository.png`: print do comando `aws ecr describe-repositories --repository-names app-frontend-6324639 --region sa-east-1`.
- `evidencias/docker_login.png`: print do comando `aws ecr get-login-password --region sa-east-1 | docker login --username AWS --password-stdin 845836832542.dkr.ecr.sa-east-1.amazonaws.com` mostrando `Login Succeeded`.
- `evidencias/docker_build.png`: print do comando `docker build -t web-app-v1:V1.0 .` com saída de sucesso.
- `evidencias/docker_tag.png`: print do comando `docker tag web-app-v1:V1.0 845836832542.dkr.ecr.sa-east-1.amazonaws.com/app-frontend-6324639:V1.0`.
- `evidencias/docker_images.png`: print da saída de `docker images | findstr "845836832542.dkr.ecr.sa-east-1.amazonaws.com/app-frontend-6324639"` mostrando a imagem marcada.
- `evidencias/docker_push.png`: print do comando `docker push 845836832542.dkr.ecr.sa-east-1.amazonaws.com/app-frontend-6324639:V1.0` com upload dos layers.
- `evidencias/ecr_describe_images.png`: print do comando `aws ecr describe-images --repository-name app-frontend-6324639 --region sa-east-1 --query 'imageDetails[].imageTags[0]'` mostrando a tag carregada.

## Observações

- A pasta `Aula012/6324639` deve conter o `README.md` com as respostas, os prints de evidência e os arquivos de configuração necessários.
- Os prints devem ser nomeados conforme a lista acima.
- O título do pull request deve ser: `RA - Nome do Aluno`.

## Limpeza após entrega

Para evitar qualquer custo AWS adicional, o repositório ECR criado pode ser removido após a avaliação com:
- `aws ecr delete-repository --repository-name app-frontend-6324639 --region sa-east-1 --force`

Isso garante que não haja armazenamento residual no ECR após a correção.
