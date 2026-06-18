# TF012 - CI/CD Básico e Registro de Imagens (ECR)

**Aluno(a):** Daniele Fagundes Rosa

**RA:** 6324661

**Disciplina:** Implementação de servidor e nuvem (cloud)

**Aula:** 12 - CI/CD Básico e Registro de Imagens (ECR)

---

## Respostas das Questões Teóricas e Práticas

### Questão 1: Conceitos de CI/CD

**a) CI (Continuous Integration):** A Integração Contínua foca em centralizar as atualizações de código dos desenvolvedores de maneira frequente. Seu propósito é utilizar a automação para validar o código, rodar testes e realizar o *build* (construção) do artefato final, a exemplo da geração de uma imagem Docker.

**b) CD (Continuous Delivery/Deployment):** A Entrega ou Implantação Contínua tem como meta capturar o artefato finalizado na etapa de CI e automatizar o seu *deploy*. Isso assegura que a aplicação seja liberada e chegue aos ambientes de execução (como homologação ou produção) de forma rápida, contínua e confiável.

### Questão 2: Ferramentas de Pipeline

Algumas das principais ferramentas utilizadas no mercado para orquestrar a fase de CI são:

1. AWS CodeBuild
2. GitLab CI/CD
3. GitHub Actions

### Questão 3: Amazon ECR

**a) Vantagem do ECR:** Em cenários de aplicações corporativas, o maior benefício do ECR é a sua sinergia com o AWS IAM (Identity and Access Management). Isso oferece uma camada robusta de segurança, permitindo definir restrições granulares de quem ou quais serviços têm autorização para enviar (*push*) ou baixar (*pull*) as imagens do repositório.

**b) Formato e Abrangência:** O Amazon ECR atua de forma regional na infraestrutura da nuvem. O padrão de estrutura da sua URI é estabelecido da seguinte forma: `[ID_DA_CONTA].dkr.ecr.[REGIAO].amazonaws.com/[NOME_DO_REPOSITORIO]`.

### Questão 4: Processo de Push

O envio de uma imagem local para a nuvem ocorre em três etapas fundamentais:

1. **Passo de Autenticação:** Geração de um token de acesso via AWS CLI (`aws ecr get-login-password`) e repasse desse token para liberar o cliente Docker (`docker login`).
2. **Passo de Tagging:** Utilização da instrução `docker tag` para "carimbar" a imagem local com o caminho (URI) do repositório de destino na AWS.
3. **Passo de Upload:** Execução do comando `docker push` para fazer o upload definitivo da imagem já referenciada para o ECR.

### Questão 5: Tarefa Prática Integrada (Simulação)

* **a) Criação do Repositório ECR:** Garante a criação do repositório na região especificada.
```bash
aws ecr create-repository --repository-name web-app-repo --region us-east-1

```


* **b) Liberação de Acesso (Login):** Conecta o serviço do Docker local ao repositório remoto.
```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com

```


* **c) Associação da Tag (Tagging):** Vincula a imagem original ao endereço do repositório criado.
```bash
docker tag web-app:v1 123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo:v1

```


* **d) Envio para a AWS (Push):** Faz o upload das camadas da imagem para a nuvem.
```bash
docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/web-app-repo:v1

```
---

## Evidências Práticas

### Parte 1: Preparação e Configuração

**1. Configuração AWS e Teste de Login no ECR**
*(Comandos: `aws configure list` e `aws ecr get-login-password...`)*
![Evidência de Credenciais](/prints/print_configure.png)

![Evidência de Login](/prints/print_login.png)
*Descrição: Confirmação das credenciais configuradas e sucesso no login com o repositório ECR.*

**2. Build da Imagem Docker**
*(Comando: `docker build -t web-app-v1:$IMAGE_TAG .`)*
![Evidência do Build Local1](/prints/print_build.png)

![Evidência do Build Local2](/prints/print_buildimage.png)
*Descrição: Criação da imagem local com a tag V1.0.*

### Parte 2: Registro e Push da Imagem

**3. Criação e Descrição do Repositório ECR**
*(Comandos: `aws ecr create-repository...` ou `aws ecr describe-repositories...`)*
![Evidência de Criação ECR Repositório ](/prints/print_repo.png)

![Evidência de Descrição ECR Repositório](/prints/print_describerepo.png)
*Descrição: Repositório app-frontend criado com sucesso na AWS.*

**4. Tagging e Verificação da Imagem Local**
*(Comandos: `docker tag...` e `docker images | grep $REPO_URI`)*
![Evidência de Tagging](/prints/print_tag.png)

![Evidência de Docker Images Tagging](/prints/print_tagimages.png)
*Descrição: Imagem local devidamente mapeada com a URI do repositório remoto.*

**5. Push para o ECR**
*(Comando: `docker push $REPO_URI:$IMAGE_TAG`)*
![Evidência do Push](/prints/print_push.png)
*Descrição: Upload dos layers da imagem para a nuvem finalizado.*

### Parte 3: Verificação Remota e Bônus EKS

**6. Verificação do ECR**
*(Comando: `aws ecr describe-images...`)*
![Evidência ECR Remoto](/prints/print_describeimage.png)
*Descrição: Confirmação da imagem V1.0 armazenada no repositório.*

**7. Deploy no EKS (Bônus)**
*(Comandos: `kubectl get deployments`, `kubectl get pods`, `kubectl get svc`)*
![Evidência Deploy EKS](/prints/print_gets.png)
*Descrição: Recursos criados e LoadBalancer provisionado no Kubernetes.*

**8. Aplicação no Ar**
*(Comando: `curl http://$ENDPOINT`)*
![Evidência Curl](/prints/print_curl.png)
*Descrição: Teste de conectividade retornando sucesso da aplicação via endpoint.*