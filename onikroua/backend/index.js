require('dotenv').config();

const express = require('express');
const cors = require('cors');
const http = require('http');
const roomsRouter = require('./routes/rooms');
const sessionsRouter = require('./routes/sessions');
const aiRouter = require('./routes/ai');
const geminiRouter = require('./routes/gemini');
const { createRobotWebSocketServer } = require('./robotServer');
const { createGeminiLiveWebSocketServer } = require('./geminiLiveServer');

const app = express();
const PORT = process.env.PORT || 3001;

// Middlewares
app.use(cors({
  origin: process.env.CORS_ORIGIN || 'http://localhost:5173',
  credentials: true
}));
app.use(express.json());

// Healthcheck
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Routes API
app.use('/api/rooms', roomsRouter);
app.use('/api/sessions', sessionsRouter);
app.use('/api/ai', aiRouter);
app.use('/api/gemini', geminiRouter);

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Route non trouvée' });
});

// Error handler
app.use((err, req, res, next) => {
  console.error('Erreur serveur:', err);
  res.status(500).json({ error: 'Erreur interne du serveur' });
});

const server = http.createServer(app);

createRobotWebSocketServer(server);
createGeminiLiveWebSocketServer(server);

server.listen(PORT, () => {
  console.log(`🚀 Serveur Onikroua démarré sur le port ${PORT}`);
  console.log(`   Health: http://localhost:${PORT}/health`);
  console.log(`   Robot WebSocket: ws://localhost:${PORT}/robot`);
  console.log(`   Gemini Live WebSocket: ws://localhost:${PORT}/gemini-live`);
});
