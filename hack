// server.js — Node.js WebSocket server básico para comandos MHN
const WebSocket = require('ws');
const wss = new WebSocket.Server({ port: 8080 });
wss.on('connection', ws => {
  console.log('Cliente conectado');
  ws.on('message', msg => {
    console.log('Comando recibido:', msg);
    // reenviar a otros clientes si quieres sync entre múltiples
    wss.clients.forEach(c => { if (c !== ws && c.readyState === WebSocket.OPEN) c.send(msg); });
  });
  ws.send('Bienvenido al servidor MHN');
});
console.log('Servidor WS MHN corriendo en ws://localhost:8080');