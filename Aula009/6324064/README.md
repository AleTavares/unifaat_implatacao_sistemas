# TF09 - Portfólio Pessoal na AWS

**Aluno:** Riquelme Menezes  
**RA:** 6324064  
**Disciplina:** Implementação de Sistemas  
**Curso:** Análise e Desenvolvimento de Sistemas - UniFAAT  

## 1. Visão Geral

Este trabalho implementa um sistema de portfólio pessoal hospedado na AWS, utilizando uma arquitetura com EC2, VPC customizada, subnet pública, subnet privada, Security Groups e banco de dados em rede privada.

A aplicação possui:

- Frontend responsivo com informações pessoais, habilidades e projetos.
- Backend em Node.js/Express com API REST.
- Banco de dados MariaDB/MySQL para armazenar projetos e experiências.
- Health check para validar a conexão entre aplicação e banco.
- Nginx como servidor web e proxy reverso.
- Docker Compose para execução dos containers.

## 2. Arquitetura

A arquitetura foi criada com uma VPC customizada contendo uma subnet pública e uma subnet privada.

![Diagrama da Infraestrutura](infrastructure/infrastructure-diagram.png)

### Fluxo da aplicação

```text
Usuário/Navegador
        |
        | HTTP porta 80
        v
EC2 WebServer - Subnet Pública
Nginx + Backend Node.js
        |
        | Porta 3306 liberada apenas via Security Group
        v
EC2 Database - Subnet Privada
MariaDB/MySQL
```

## 3. Arquitetura de Rede

### VPC Configuration

- **CIDR Block:** 10.0.0.0/16
- **Região:** us-east-1
- **VPC:** Lab009-VPC

### Subnets

- **Public Subnet:** 10.0.1.0/24 - us-east-1a
- **Private Subnet:** 10.0.2.0/24 - us-east-1a

### Routing

- **Public Route Table:** rota `0.0.0.0/0` apontando para o Internet Gateway `Lab009-IGW`.
- **Private Route Table:** sem rota pública permanente para internet após a configuração do banco.

## 4. Segurança Implementada

### Security Group do Web Server

| Tipo | Porta | Origem | Justificativa |
|---|---:|---|---|
| SSH | 22 | Meu IP /32 | Administração segura da instância |
| HTTP | 80 | 0.0.0.0/0 | Acesso público à aplicação |
| HTTPS | 443 | 0.0.0.0/0 | Preparado para acesso seguro via HTTPS |
| TCP Customizado | 3000 | 0.0.0.0/0 | Testes diretos da API/backend |

### Security Group do Database

| Tipo | Porta | Origem | Justificativa |
|---|---:|---|---|
| MySQL/Aurora | 3306 | Security Group do Web Server | Permite acesso ao banco apenas pela aplicação |
| SSH | 22 | Security Group do Web Server | Administração interna via bastion/ProxyJump |

## 5. Tecnologias Utilizadas

- **AWS EC2:** hospedagem das instâncias.
- **AWS VPC:** isolamento da rede.
- **Subnets pública e privada:** separação entre aplicação e banco.
- **Security Groups:** controle de acesso por porta e origem.
- **Amazon Linux 2023:** sistema operacional das instâncias.
- **Docker e Docker Compose:** empacotamento e execução da aplicação.
- **Nginx:** servidor web e proxy reverso.
- **Node.js + Express:** API backend.
- **MariaDB/MySQL:** banco de dados relacional.
- **HTML, CSS e JavaScript:** frontend responsivo.

## 6. Como Executar a Aplicação

Na instância WebServer:

```bash
cd ~/app
sudo docker-compose up -d --build
sudo docker-compose ps
```

Testar o backend diretamente:

```bash
curl http://localhost:3000/health
```

Testar via Nginx:

```bash
curl http://localhost/health
```

Testar API pública:

```bash
curl http://IP_PUBLICO_DA_WEBSERVER/api/info
curl http://IP_PUBLICO_DA_WEBSERVER/health
```

## 7. Endpoints da API

| Método | Endpoint | Descrição |
|---|---|---|
| GET | `/health` | Verifica status da aplicação e banco |
| GET | `/api/info` | Retorna informações da instância |
| GET | `/api/projects` | Lista projetos |
| POST | `/api/projects` | Cria novo projeto |
| PUT | `/api/projects/:id` | Atualiza projeto |
| DELETE | `/api/projects/:id` | Remove projeto |
| GET | `/api/experiences` | Lista experiências/habilidades |

## 8. Evidências de Funcionamento

Adicionar prints na pasta `evidencias/`:

- `01-vpc.png`: VPC criada.
- `02-subnets.png`: subnets pública e privada.
- `03-route-table.png`: tabela de rota pública com Internet Gateway.
- `04-security-groups.png`: regras de segurança.
- `05-ec2-instances.png`: instâncias WebServer e Database em execução.
- `06-health-local.png`: teste `curl http://localhost/health`.
- `07-api-info-browser.png`: navegador acessando `/api/info`.
- `08-health-browser.png`: navegador acessando `/health`.
- `09-frontend-browser.png`: frontend do portfólio funcionando.

## 9. Custos Estimados

A infraestrutura foi planejada para utilizar o Free Tier da AWS sempre que possível.

| Recurso | Tipo | Estimativa |
|---|---|---|
| EC2 WebServer | t3.micro | Free Tier, se elegível |
| EC2 Database | t3.micro | Free Tier, se elegível |
| EBS | volume padrão | Dentro do limite Free Tier, se elegível |
| VPC/Subnets/Security Groups | AWS Network | Sem custo direto |
| Elastic IP | Temporário | Deve ser liberado após uso para evitar cobrança |

> Observação: o Elastic IP usado temporariamente para instalar pacotes na instância privada deve ser desassociado e liberado após o uso.

## 10. Limpeza de Recursos

Para evitar custos, remover os recursos após a avaliação:

```bash
bash infrastructure/cleanup-infrastructure.sh
```

Também verificar manualmente no console da AWS:

- Instâncias EC2 terminadas.
- Elastic IP liberado.
- Internet Gateway removido.
- Security Groups removidos.
- Subnets removidas.
- VPC removida.
