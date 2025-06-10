#!/bin/bash

/sbin/init &
sleep 5

echo "--- STARTING BOT ---"
python3 /app/bot.py
echo "--- BOT EXITED WITH CODE $? ---"

# Keep container alive for debugging
tail -f /dev/null
