# Guia de Deploy - TF09

## 1. Pré-requisitos

- Conta AWS com Free Tier ativo.
- AWS CLI configurado, se usar scripts.
- Par de chaves SSH `.pem`.
- VPC, subnets e Security Groups configurados.
- Instância WebServer com Docker e Docker Compose.
- Instância Database com MariaDB/MySQL.

## 2. Criar banco de dados na instância privada

Acessar a instância Database via WebServer usando ProxyJump:

```powershell
ssh lab-db
```

Configurar o MariaDB:

```bash
sudo systemctl start mariadb
sudo systemctl enable mariadb

sudo tee /etc/my.cnf.d/bind-address.cnf > /dev/null << 'EOF'
[mysqld]
bind-address=0.0.0.0
EOF

sudo systemctl restart mariadb
```

Criar banco e usuário:

```bash
set +H

sudo mysql <<'SQL'
CREATE DATABASE IF NOT EXISTS appdb;

DROP USER IF EXISTS 'appuser'@'localhost';
DROP USER IF EXISTS 'appuser'@'%';

CREATE USER 'appuser'@'%' IDENTIFIED BY 'SecurePass123!';
GRANT ALL PRIVILEGES ON appdb.* TO 'appuser'@'%';
FLUSH PRIVILEGES;

SELECT User, Host FROM mysql.user WHERE User='appuser';
SQL
```

Verificar porta:

```bash
sudo ss -ltnp | grep 3306
```

## 3. Deploy na WebServer

Copiar os arquivos da pasta `application/` para `~/app` na WebServer.

Criar `.env`:

```bash
cat > .env << 'EOF'
DB_HOST=10.0.2.70
DB_USER=appuser
DB_PASSWORD=SecurePass123!
DB_NAME=appdb
PORT=3000
INSTANCE_ID=ip-10-0-1-176.ec2.internal
AWS_REGION=us-east-1
EOF
```

Subir aplicação:

```bash
cd ~/app
sudo docker-compose up -d --build
sudo docker-compose ps
```

## 4. Verificações

Testar backend:

```bash
curl http://localhost:3000/health
```

Testar Nginx:

```bash
curl http://localhost/health
```

Testar API pública:

```bash
curl http://IP_PUBLICO_DA_WEBSERVER/api/info
```

## 5. Evidências

Salvar prints de:

- Instâncias EC2 rodando.
- Security Groups.
- Route Tables.
- `docker-compose ps`.
- `/health` com `database: connected`.
- `/api/info` funcionando no navegador.
