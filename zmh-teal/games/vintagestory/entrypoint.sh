#!/bin/sh

echo "📓 extra configuration..."
sh ./server.sh command "/op chillpickles"

echo "🖊️ Disabling whitelist..."
sh ./server.sh command "/serverconfig whitelistmode off"

echo "🚀 Starting server..."
sh ./server.sh start

echo "🕝 Keep-alive..."
tail -f /var/vintagestory/data/Logs/server-main.log /var/vintagestory/data/Logs/server-debug.log