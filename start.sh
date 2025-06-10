#!/bin/bash

# Start systemd in the background
/sbin/init &

# Optional: give it a moment to fully start systemd
sleep 5

# Start your bot
python3 /app/bot.py
