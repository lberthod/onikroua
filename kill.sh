#!/bin/bash

PORT=3001

echo "🔍 Recherche du processus sur le port $PORT..."

PID=$(lsof -ti tcp:$PORT)

if [ -z "$PID" ]; then
  echo "✅ Aucun processus n'écoute sur le port $PORT"
  exit 0
fi

echo "⚠️ Processus trouvé :"
lsof -nP -iTCP:$PORT -sTCP:LISTEN

echo ""
read -p "❓ Voulez-vous arrêter ce processus ? (y/N) " CONFIRM

if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
  echo "❌ Annulé"
  exit 0
fi

echo "🛑 Envoi SIGTERM au PID $PID..."
kill $PID
sleep 2

if ps -p $PID > /dev/null; then
  echo "⚠️ Le processus résiste, envoi SIGKILL..."
  kill -9 $PID
fi

echo "✅ Port $PORT libéré"
