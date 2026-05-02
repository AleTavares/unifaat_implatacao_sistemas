const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// In-memory data for demo purposes (acting as a basic DB)
let projects = [
    { id: 1, title: 'Projeto Cloud', description: 'Infraestrutura AWS com Terraform' },
    { id: 2, title: 'Portfolio Web', description: 'SPA em React com Node.js backend' }
];

// Health Check Endpoint
app.get('/health', (req, res) => {
    res.status(200).json({ status: 'UP', timestamp: new Date() });
});

// GET all projects
app.get('/api/projects', (req, res) => {
    res.json(projects);
});

// POST new project
app.post('/api/projects', (req, res) => {
    const newProject = {
        id: projects.length + 1,
        title: req.body.title,
        description: req.body.description
    };
    projects.push(newProject);
    res.status(201).json(newProject);
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`Backend server running on http://0.0.0.0:${PORT}`);
});
