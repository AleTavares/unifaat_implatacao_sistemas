# TF09 - Portfólio Pessoal na AWS

**Aluno:** Danilo Lenardi de Almeida  
**RA:** 6324049  
**Disciplina:** Implementação de Sistemas  
**Curso:** Análise e Desenvolvimento de Sistemas - UniFAAT  

---

## Visão Geral

Projeto de deploy de aplicação web na AWS utilizando EC2, VPC, Security Groups e Docker.
A aplicação é um portfólio pessoal com frontend em Nginx e backend em Python/Flask.

---

## Arquitetura de Rede

### VPC Configuration
- **CIDR Block:** 10.0.0.0/16
- **Region:** us-east-1 (N. Virginia)

### Subnets
| Nome | CIDR | AZ | Tipo |
|------|------|----|------|
| TF09-Subnet-Publica | 10.0.1.0/24 | us-east-1a | Pública |
| TF09-Subnet-Privada | 10.0.2.0/24 | us-east-1b | Privada |

### Recursos de Rede
| Recurso | ID |
|---------|-----|
| VPC | vpc-07c7c0923d6c3e926 |
| Subnet Pública | subnet-038979d8918bc203e |
| Subnet Privada | subnet-0871b81f0aff74b1b |
| Internet Gateway | igw-08c3940a2775ff4af |
| Route Table | rtb-0f3203e98dbfc3ec4 |

### Routing
- **Public Route Table:** 0.0.0.0/0 → igw-08c3940a2775ff4af
- **Private Route Table:** Apenas tráfego local (10.0.0.0/16)

---

## Segurança Implementada

### Security Groups

#### TF09-SG-Web (sg-0c2436eecf9ba66f2)
| Porta | Protocolo | Origem | Descrição |
|-------|-----------|--------|-----------|
| 80 | TCP | 0.0.0.0/0 | HTTP público |
| 443 | TCP | 0.0.0.0/0 | HTTPS público |
| 5000 | TCP | 0.0.0.0/0 | API Backend |
| 22 | TCP | 187.0.234.39/32 | SSH restrito |

#### TF09-SG-Database (sg-01e9afcd38989916d)
| Porta | Protocolo | Origem | Descrição |
|-------|-----------|--------|-----------|
| 5432 | TCP | sg-0c2436eecf9ba66f2 | PostgreSQL só pelo EC2 |

### Medidas de Segurança
- ✅ VPC isolada com subnets pública e privada
- ✅ SSH restrito ao IP do desenvolvedor (187.0.234.39/32)
- ✅ Banco de dados em subnet privada sem acesso externo
- ✅ Princípio do menor privilégio aplicado
- ✅ Chave SSH com permissão 400

---

## Instância EC2

| Recurso | Valor |
|---------|-------|
| Instance ID | i-014f28246843ebc83 |
| Tipo | t3.micro (Free Tier) |
| AMI | Ubuntu 20.04 LTS |
| IP Público | 18.206.148.26 |
| Region | us-east-1 |

---

## Tecnologias Utilizadas

| Tecnologia | Uso |
|------------|-----|
| AWS EC2 | Servidor de aplicação |
| AWS VPC | Rede privada isolada |
| Docker | Containerização |
| Docker Compose | Orquestração de containers |
| Python/Flask | API Backend |
| Nginx | Servidor Web Frontend |
| PostgreSQL | Banco de dados |

---

## Como Executar

### Pré-requisitos
- AWS CLI configurado
- Docker e Docker Compose instalados

### Deploy
```bash
# 1. Criar infraestrutura
cd infrastructure
chmod +x create-infrastructure.sh
./create-infrastructure.sh

# 2. Conectar no EC2
ssh -i TF09-KeyPair.pem ubuntu@18.206.148.26

# 3. Subir aplicação
cd ~/TF09
sudo docker-compose up -d --build
```

### Verificação
- **Site:** http://18.206.148.26
- **Health Check:** http://18.206.148.26:5000/health
- **API Projetos:** http://18.206.148.26:5000/api/projects

---

## Custos Estimados

| Recurso | Custo |
|---------|-------|
| EC2 t3.micro | Free Tier (750h/mês) |
| VPC | Gratuito |
| Internet Gateway | Gratuito |
| Security Groups | Gratuito |
| Transferência de dados | ~$0.01/GB |
| **Total estimado** | **$0,00 (Free Tier)** |

---

## Limpeza de Recursos
```bash
cd infrastructure
chmod +x cleanup-infrastructure.sh
./cleanup-infrastructure.sh
```

---

## Documentação Adicional
- [Guia de Deploy](docs/deployment-guide.md)
- [Análise de Segurança](docs/security-analysis.md)
- [Troubleshooting](docs/troubleshooting.md)
