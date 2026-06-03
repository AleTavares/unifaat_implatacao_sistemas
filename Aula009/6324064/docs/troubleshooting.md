# Troubleshooting - TF09

## 1. Erro: `connect ECONNREFUSED 10.0.2.70:3306`

Causa provável:

- MariaDB não está rodando.
- Porta 3306 não está aberta.
- Banco não foi instalado corretamente.

Correções:

```bash
sudo systemctl status mariadb
sudo systemctl start mariadb
sudo ss -ltnp | grep 3306
```

## 2. Erro: `Host is not allowed to connect to this MariaDB server`

Causa provável:

- Usuário do banco criado apenas para `localhost`.

Correção:

```bash
set +H

sudo mysql <<'SQL'
DROP USER IF EXISTS 'appuser'@'localhost';
DROP USER IF EXISTS 'appuser'@'%';
CREATE USER 'appuser'@'%' IDENTIFIED BY 'SecurePass123!';
GRANT ALL PRIVILEGES ON appdb.* TO 'appuser'@'%';
FLUSH PRIVILEGES;
SQL
```

## 3. Erro: `502 Bad Gateway`

Causa provável:

- Backend reiniciando.
- Container `app` não está saudável.
- Nginx não consegue acessar `app:3000`.

Correções:

```bash
cd ~/app
sudo docker-compose ps
sudo docker-compose logs --tail=80 app
sudo docker-compose restart app
```

## 4. Erro SSH: `Permission denied`

Causa provável:

- Chave errada.
- Instância criada com outro Key Pair.
- Arquivo `.pem` sem permissão adequada.

Teste:

```powershell
ssh -i ".\Lab009-KeyPair.pem" ec2-user@IP_PUBLICO
```

## 5. Erro SSH: `Connection timed out`

Causa provável:

- Porta 22 bloqueada no Security Group.
- IP público da WebServer mudou.
- Subnet pública sem rota para Internet Gateway.

Verificações:

- Security Group WebServer permite SSH 22 do seu IP.
- Route Table pública possui `0.0.0.0/0 -> IGW`.
- Instância possui IPv4 público.

## 6. Testes úteis

```bash
curl http://localhost:3000/health
curl http://localhost/health
nc -vz 10.0.2.70 3306
sudo docker-compose ps
sudo docker-compose logs
```
