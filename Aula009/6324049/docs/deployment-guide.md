# Guia de Deploy - TF09

## Pré-requisitos
- Conta AWS ativa
- AWS CLI instalado e configurado
- Docker e Docker Compose instalados
- Git instalado

## Passo a Passo

### 1. Clonar o repositório
```bash
git clone https://github.com/Danilo8922/unifaat_implatacao_sistemas.git
cd unifaat_implatacao_sistemas/Aula009/6324049
```

### 2. Criar a infraestrutura
```bash
cd infrastructure
chmod +x create-infrastructure.sh
./create-infrastructure.sh
```

### 3. Conectar no EC2
```bash
ssh -i TF09-KeyPair.pem ubuntu@<IP_PUBLICO>
```

### 4. Instalar dependências no EC2
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install docker.io docker-compose -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu
```

### 5. Copiar aplicação para o EC2
```bash
scp -i TF09-KeyPair.pem -r application/ ubuntu@<IP_PUBLICO>:~/TF09
```

### 6. Deploy da aplicação
```bash
cd ~/TF09
sudo docker-compose up -d --build
```

## Verificação
- Site: http://<IP_PUBLICO>
- Health Check: http://<IP_PUBLICO>:5000/health
- Projetos: http://<IP_PUBLICO>:5000/api/projects

## Troubleshooting
- Se o site não carregar, verifique os Security Groups
- Se a API estiver offline, verifique se a porta 5000 está liberada
- Para ver logs: `sudo docker-compose logs`
