#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status.

echo "Welcome User To Automated Installer"

# Ensure necessary tools are installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed. Please install Docker and try again."
    exit 1
fi

if ! command -v python3 &> /dev/null; then
    echo "Error: Python3 is not installed. Please install Python3 and try again."
    exit 1
fi

if ! command -v pip &> /dev/null; then
    echo "Error: Pip is not installed. Please install Pip and try again."
    exit 1
fi

# Clone the repository
REPO_URL="https://github.com/BossOPMC94/CRASHCLOUD-VPS-MAKER-BOT.git"
INSTALL_DIR="CRASHCLOUD-VPS-MAKER-BOT"

if [ ! -d "$INSTALL_DIR" ]; then
    echo "Cloning the repository..."
    git clone "$REPO_URL" || { echo "Failed to clone repository."; exit 1; }
else
    echo "Repository already cloned. Using existing directory."
fi

# Navigate to the repository directory
cd "$INSTALL_DIR" || { echo "Error: Could not enter the directory."; exit 1; }

# Prompt user for the bot token
read -p "Enter your Bot Token: " BOT_TOKEN

# Update the bot.py file with the provided token
if [[ -f "bot.py" ]]; then
    sed -i "s/TOKEN = '.*'/TOKEN = '$BOT_TOKEN'/" bot.py || { echo "Error updating bot.py"; exit 1; }
    echo "Bot token successfully updated in bot.py."
else
    echo "Error: bot.py not found. Ensure the file exists in the directory."
    exit 1
fi

# Install dependencies
echo "Installing Python dependencies..."
pip install -r requirements.txt || { echo "Failed to install Python dependencies."; exit 1; }

# Create a Dockerfile if it doesn’t exist
if [[ ! -f "Dockerfile" ]]; then
    echo "Creating Dockerfile..."
    touch Dockerfile
    cat <<EOF >Dockerfile
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    curl \
    openssh-client \
    tmate
WORKDIR /app
COPY . .
RUN pip3 install -r requirements.txt
CMD ["python3", "bot.py"]
EOF
    echo "Dockerfile created."
else
    echo "Dockerfile already exists. Skipping creation."
fi

# Build Docker image
echo "Building Docker image..."
docker build -t crashcloud-vps-maker . || { echo "Docker build failed."; exit 1; }

# Run the bot
echo "Starting the bot..."
docker run -it crashcloud-vps-maker || { echo "Failed to start the bot."; exit 1; }

echo "Setup Complete! The bot is now running."
