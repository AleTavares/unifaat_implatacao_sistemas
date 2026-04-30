# Análise de Segurança - TF09

## 1. Objetivo

Este documento descreve as medidas de segurança implementadas na infraestrutura AWS do TF09.

## 2. Segmentação de rede

A aplicação foi separada em duas camadas:

- **Subnet pública:** contém a instância WebServer, responsável por receber tráfego HTTP do usuário.
- **Subnet privada:** contém a instância Database, sem acesso público permanente.

Essa separação reduz a exposição do banco de dados e aplica o princípio de defesa em profundidade.

## 3. Security Groups

### WebServer SG

Regras de entrada:

| Porta | Protocolo | Origem | Motivo |
|---:|---|---|---|
| 22 | TCP | Meu IP /32 | Administração via SSH restrita |
| 80 | TCP | 0.0.0.0/0 | Acesso público ao site |
| 443 | TCP | 0.0.0.0/0 | Preparação para HTTPS |
| 3000 | TCP | 0.0.0.0/0 | Testes do backend durante o desenvolvimento |

### Database SG

Regras de entrada:

| Porta | Protocolo | Origem | Motivo |
|---:|---|---|---|
| 3306 | TCP | WebServer SG | Acesso ao banco apenas pela aplicação |
| 22 | TCP | WebServer SG | Acesso administrativo interno via WebServer |

## 4. Key Pair e SSH

Foi utilizado um Key Pair `.pem` para autenticação SSH. A chave privada não deve ser versionada no Git e deve permanecer armazenada apenas na máquina do aluno.

## 5. Menor privilégio

O banco de dados não recebe tráfego direto da internet. A porta 3306 só aceita conexões originadas pelo Security Group da WebServer.

## 6. Risco temporário identificado

Durante a instalação de pacotes na instância privada, foi necessário liberar internet temporariamente por meio de rota e Elastic IP. Após a instalação, esse acesso deve ser removido para retornar ao modelo seguro.

## 7. Melhorias futuras

- Remover exposição pública da porta 3000 e manter apenas a porta 80/443 pública.
- Configurar HTTPS com certificado SSL/TLS.
- Usar RDS em subnet privada para produção.
- Usar AWS Systems Manager Session Manager em vez de SSH.
- Configurar CloudWatch Logs para centralizar logs.
- Criar NAT Gateway ou VPC Endpoint para updates em instâncias privadas.
