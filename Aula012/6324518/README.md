# TF012 - CI/CD Básico e Registro de Imagens (ECR)

**Aluno(a):** Rafaela Bianor de Azevedo

**RA:** 6324518

**Disciplina:** Implementação de servidor e nuvem (cloud)

**Aula:** 12 - CI/CD Básico e Registro de Imagens (ECR)

---

## Respostas das Questões Teóricas e Práticas

### Questão 1: Conceitos de CI/CD
**a) CI (Continuous Integration):** O objetivo principal desta fase é integrar as alterações de código em um repositório central de forma automatizada, onde ocorrem a validação, os testes automatizados e o *build* (construção) do artefato, como uma imagem Docker.

**b) CD (Continuous Delivery/Deployment):** O objetivo principal é receber o artefato gerado na fase de CI e automatizar a sua entrega ou implantação de forma segura nos ambientes de destino (homologação, produção, etc).

### Questão 2: Ferramentas de Pipeline
Três ferramentas que podem automatizar a fase de CI:
1. GitHub Actions
2. GitLab CI/CD
3. AWS CodeBuild

### Questão 3: Amazon ECR
**a) Vantagem do ECR:** A principal vantagem para aplicações privadas é a integração direta com o IAM da AWS, garantindo controle de acesso seguro e granular sobre quem ou o que pode fazer o *push* ou *pull* das imagens.

**b) Formato e Abrangência:** O ECR é um serviço regional. O formato padrão do URI é: `[ID_DA_CONTA].dkr.ecr.[REGIAO].amazonaws.com/[NOME_DO_REPOSITORIO]`.

### Questão 4: Processo de Push
1. **Passo de Autenticação:** Comando `aws ecr get-login-password` e `docker login`.
2. **Passo de Tagging:** Comando `docker tag` para marcar a imagem com o URI.
3. **Passo de Upload:** Comando `docker push` para enviar a imagem.

### Questão 5: Tarefa Prática Integrada (Simulação)
* **a) Criação do Repositório:** `aws ecr create-repository --repository-name web-app-repo --region us-east-1`

* **b) Autenticação:** `aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com`

* **c) Tagging da Imagem:** `docker tag web-app:v1 123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo:v1`

* **d) Push Final:** `docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo:v1`

---

## Evidências Práticas (Lab012)

### Parte 1: Preparação e Configuração

**1. Configuração AWS e Teste de Login no ECR**
*(Comandos: `aws configure list` e `aws ecr get-login-password...`)*
![Evidência de Credenciais](/imgs/aws_configure_list.png)

![Evidência de Login](/imgs/login_succeeded.png)
*Descrição: Confirmação das credenciais configuradas e sucesso no login com o repositório ECR.*

**2. Build da Imagem Docker**
*(Comando: `docker build -t web-app-v1:$IMAGE_TAG .`)*
![Evidência do Build Local](/imgs/docker_build.png)
*Descrição: Criação da imagem local com a tag V1.0.*

### Parte 2: Registro e Push da Imagem

**3. Criação e Descrição do Repositório ECR**
*(Comandos: `aws ecr create-repository...` ou `aws ecr describe-repositories...`)*
![Evidência de Criação ECR Repositório ](/imgs/create_repo.png)

![Evidência de Descrição ECR Repositório](/imgs/describe_repo.png)
*Descrição: Repositório app-frontend criado com sucesso na AWS.*

**4. Tagging e Verificação da Imagem Local**
*(Comandos: `docker tag...` e `docker images | grep $REPO_URI`)*
![Evidência de Tagging](/imgs/docker_tag.png)

![Evidência de Docker Images Tagging](/imgs/docker_tag_images.png)
*Descrição: Imagem local devidamente mapeada com a URI do repositório remoto.*

**5. Push para o ECR**
*(Comando: `docker push $REPO_URI:$IMAGE_TAG`)*
![Evidência do Push](/imgs/docker_push.png)
*Descrição: Upload dos layers da imagem para a nuvem finalizado.*

### Parte 3: Verificação Remota e Bônus EKS

**6. Verificação do ECR**
*(Comando: `aws ecr describe-images...`)*
![Evidência ECR Remoto](/imgs/describe_images.png)
*Descrição: Confirmação da imagem V1.0 armazenada no repositório.*

**7. Deploy no EKS (Bônus)**
*(Comandos: `kubectl get deployments`, `kubectl get pods`, `kubectl get svc`)*
![Evidência Deploy EKS](/imgs/kubectl_gets.png)
*Descrição: Recursos criados e LoadBalancer provisionado no Kubernetes.*

**8. Aplicação no Ar**
*(Comando: `curl http://$ENDPOINT`)*
![Evidência Curl](/imgs/curl_endpoint.png)
*Descrição: Teste de conectividade retornando sucesso da aplicação via endpoint.*

---

## Observações e Troubleshooting (Depuração)

Durante a execução do laboratório, encontrei e resolvi os seguintes obstáculos:

**1. Limite de Free Tier no Node Group (EKS)**
* **Erro Encontrado:** Ao tentar criar o Node Group na etapa 6.11, ocorreu o erro `CREATE_FAILED` com a justificativa de `InvalidParameterCombination`. A AWS impediu o lançamento porque a instância `t3.medium` solicitada pelo roteiro não era elegível ao *Free Tier*.
* **Solução:** Executei o comando de depuração `aws eks describe-nodegroup` para investigar a falha. Em seguida, deletei o grupo quebrado com `aws eks delete-nodegroup`, aguardei a exclusão e refiz a etapa 6.11 alterando o parâmetro `--instance-types` para `t3.micro`, o que permitiu o provisionamento correto dos nós.
* **Evidência do Debug:**
![Evidência Debug Free Tier](/imgs/debug.png)

![Evidência Solução 1](/imgs/solution.png)

**2. Erro no Script de Limpeza de Roles (IAM)**
* **Erro Encontrado:** Na Seção 8.1, passo 5, o comando para deletar a `EKSClusterRole` foi instruído duas vezes. Na segunda vez, o terminal retornou o erro `NoSuchEntity` informando que a *role* não pôde ser encontrada.
* **Solução:** Percebi que o roteiro deveria ter instruído a exclusão da *role* dos nós e não do cluster novamente. Corrigi o fluxo de limpeza executando o comando correto: `aws iam delete-role --role-name EKSNodeRole`.
* **Evidência do Debug:**
![Evidência Debug IAM Role](/imgs/error2(delete).png)

![Evidência Solução 2](/imgs/solution2(delete).png)