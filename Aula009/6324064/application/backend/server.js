const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');
const morgan = require('morgan');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());
app.use(morgan(':method :url :status :response-time ms'));

const dbConfig = {
  host: process.env.DB_HOST,
  user: process.env.DB_USER || 'appuser',
  password: process.env.DB_PASSWORD || 'SecurePass123!',
  database: process.env.DB_NAME || 'appdb',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
};

let pool;

async function getPool() {
  if (!pool) {
    pool = mysql.createPool(dbConfig);
  }
  return pool;
}

async function initDatabase() {
  const connection = await mysql.createConnection({
    host: dbConfig.host,
    user: dbConfig.user,
    password: dbConfig.password
  });

  await connection.query(`CREATE DATABASE IF NOT EXISTS \`${dbConfig.database}\``);
  await connection.end();

  const db = await getPool();

  await db.query(`
    CREATE TABLE IF NOT EXISTS projects (
      id INT AUTO_INCREMENT PRIMARY KEY,
      title VARCHAR(120) NOT NULL,
      description TEXT NOT NULL,
      technologies VARCHAR(255) NOT NULL,
      repository_url VARCHAR(255),
      status VARCHAR(50) DEFAULT 'Em desenvolvimento',
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
  `);

  await db.query(`
    CREATE TABLE IF NOT EXISTS experiences (
      id INT AUTO_INCREMENT PRIMARY KEY,
      title VARCHAR(120) NOT NULL,
      description TEXT NOT NULL,
      category VARCHAR(80) NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
  `);

  const [projectRows] = await db.query('SELECT COUNT(*) AS total FROM projects');
  if (projectRows[0].total === 0) {
    await db.query(`
      INSERT INTO projects (title, description, technologies, repository_url, status)
      VALUES
      (?, ?, ?, ?, ?),
      (?, ?, ?, ?, ?),
      (?, ?, ?, ?, ?)
    `, [
      'Planeta Moto Parts',
      'E-commerce para venda de peças usadas de motocicletas, com foco em catálogo, carrinho e painel administrativo.',
      'HTML, CSS, JavaScript, Node.js, PostgreSQL, APIs',
      'https://github.com/sleyck021/PLANETA-MOTO-PARTS',
      'Em desenvolvimento',

      'TF09 Portfolio AWS',
      'Portfólio pessoal hospedado em EC2 com VPC, Security Groups, Nginx, Docker e banco privado.',
      'AWS EC2, VPC, Docker, Nginx, Node.js, MariaDB',
      '',
      'Concluído',

      'Laboratórios de Infraestrutura',
      'Projetos acadêmicos envolvendo Linux, Docker Compose, Nginx, firewall e supervisores.',
      'Linux, Docker, Nginx, AWS, Bash',
      '',
      'Acadêmico'
    ]);
  }

  const [experienceRows] = await db.query('SELECT COUNT(*) AS total FROM experiences');
  if (experienceRows[0].total === 0) {
    await db.query(`
      INSERT INTO experiences (title, description, category)
      VALUES
      (?, ?, ?),
      (?, ?, ?),
      (?, ?, ?),
      (?, ?, ?)
    `, [
      'Backend Node.js',
      'Criação de APIs REST com Express, rotas, controllers, banco de dados e integração com serviços externos.',
      'Backend',

      'Infraestrutura e Deploy',
      'Configuração de ambientes Linux, Docker, Nginx, EC2, VPC e Security Groups.',
      'DevOps',

      'Banco de Dados',
      'Modelagem e uso de bancos relacionais como PostgreSQL, MySQL e MariaDB.',
      'Database',

      'Frontend Web',
      'Criação de interfaces responsivas com HTML, CSS e JavaScript.',
      'Frontend'
    ]);
  }
}

app.get('/health', async (req, res) => {
  try {
    const db = await getPool();
    await db.query('SELECT 1');

    res.json({
      status: 'healthy',
      timestamp: new Date().toISOString(),
      database: 'connected',
      server: 'EC2'
    });
  } catch (error) {
    res.status(503).json({
      status: 'unhealthy',
      timestamp: new Date().toISOString(),
      database: 'disconnected',
      error: error.message
    });
  }
});

app.get('/api/info', (req, res) => {
  res.json({
    message: 'API do Portfólio rodando no EC2!',
    student: 'Riquelme Menezes',
    ra: '6324064',
    instance: process.env.INSTANCE_ID || 'unknown',
    region: process.env.AWS_REGION || 'us-east-1'
  });
});

app.get('/api/projects', async (req, res) => {
  const db = await getPool();
  const [rows] = await db.query('SELECT * FROM projects ORDER BY created_at DESC');
  res.json(rows);
});

app.post('/api/projects', async (req, res) => {
  const { title, description, technologies, repository_url, status } = req.body;

  if (!title || !description || !technologies) {
    return res.status(400).json({ error: 'title, description e technologies são obrigatórios.' });
  }

  const db = await getPool();
  const [result] = await db.query(
    'INSERT INTO projects (title, description, technologies, repository_url, status) VALUES (?, ?, ?, ?, ?)',
    [title, description, technologies, repository_url || '', status || 'Em desenvolvimento']
  );

  res.status(201).json({ id: result.insertId, title, description, technologies, repository_url, status });
});

app.put('/api/projects/:id', async (req, res) => {
  const { id } = req.params;
  const { title, description, technologies, repository_url, status } = req.body;

  const db = await getPool();
  const [result] = await db.query(
    `UPDATE projects
     SET title = ?, description = ?, technologies = ?, repository_url = ?, status = ?
     WHERE id = ?`,
    [title, description, technologies, repository_url || '', status || 'Em desenvolvimento', id]
  );

  if (result.affectedRows === 0) {
    return res.status(404).json({ error: 'Projeto não encontrado.' });
  }

  res.json({ id, title, description, technologies, repository_url, status });
});

app.delete('/api/projects/:id', async (req, res) => {
  const { id } = req.params;
  const db = await getPool();

  const [result] = await db.query('DELETE FROM projects WHERE id = ?', [id]);

  if (result.affectedRows === 0) {
    return res.status(404).json({ error: 'Projeto não encontrado.' });
  }

  res.json({ message: 'Projeto removido com sucesso.' });
});

app.get('/api/experiences', async (req, res) => {
  const db = await getPool();
  const [rows] = await db.query('SELECT * FROM experiences ORDER BY id ASC');
  res.json(rows);
});

app.use((req, res) => {
  res.status(404).json({ error: 'Rota não encontrada.' });
});

initDatabase()
  .then(() => {
    app.listen(PORT, '0.0.0.0', () => {
      console.log(JSON.stringify({
        level: 'info',
        message: `Servidor iniciado na porta ${PORT}`,
        timestamp: new Date().toISOString()
      }));
    });
  })
  .catch((error) => {
    console.error(JSON.stringify({
      level: 'error',
      message: 'Erro ao inicializar banco de dados',
      error: error.message,
      timestamp: new Date().toISOString()
    }));
    process.exit(1);
  });
