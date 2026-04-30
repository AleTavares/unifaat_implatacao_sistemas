# TF09 - Portfólio Pessoal na AWS

## Nome: Paulo Vinicius Bernardes
## RA: 6324010

## Visão Geral
Este projeto consiste na criação de uma infraestrutura na AWS utilizando EC2, VPC e Security Groups para hospedar um portfólio pessoal.

## Arquitetura
- VPC: 10.0.0.0/16
- Subnets:
  - Pública: 10.0.0.0/20
  - Privada: 10.0.144.0/20
- EC2 rodando servidor web Apache

## Tecnologias
- AWS EC2
- Apache (httpd)
- Linux (Amazon Linux 2023)

## Segurança
- SSH liberado apenas para meu IP
- HTTP liberado para acesso público
- Subnet privada sem acesso externo

## Como acessar
http://SEU-IP-AQUI

## Custos
Uso dentro do Free Tier (t3.micro)