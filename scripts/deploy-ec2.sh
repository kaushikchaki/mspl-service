#!/bin/bash

# MSPL Service - Deployment Script for AWS EC2
# This script deploys the application to AWS EC2

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration
REPO_URL="https://github.com/yourusername/mspl-service.git"
DEPLOY_DIR="/home/ec2-user/mspl-service"
APP_PORT=5000
PM2_APP_NAME="mspl-api"

echo -e "${BLUE}MSPL Service - AWS EC2 Deployment${NC}"
echo "======================================="

# Check if script is run as ec2-user
if [ "$USER" != "ec2-user" ]; then
    echo -e "${YELLOW}Warning: Script should be run as ec2-user${NC}"
fi

# Update system
echo -e "${BLUE}1. Updating system packages...${NC}"
sudo yum update -y

# Install Node.js if not present
if ! command -v node &> /dev/null; then
    echo -e "${BLUE}2. Installing Node.js...${NC}"
    curl -sL https://rpm.nodesource.com/setup_18.x | sudo bash -
    sudo yum install -y nodejs
    echo -e "${GREEN}✓ Node.js installed${NC}"
else
    echo -e "${GREEN}✓ Node.js already installed: $(node -v)${NC}"
fi

# Install PM2 globally
if ! command -v pm2 &> /dev/null; then
    echo -e "${BLUE}3. Installing PM2...${NC}"
    sudo npm install -g pm2
    sudo pm2 startup
    echo -e "${GREEN}✓ PM2 installed${NC}"
else
    echo -e "${GREEN}✓ PM2 already installed${NC}"
fi

# Install PostgreSQL client
echo -e "${BLUE}4. Installing PostgreSQL client...${NC}"
sudo yum install -y postgresql

# Clone or pull repository
if [ ! -d "$DEPLOY_DIR" ]; then
    echo -e "${BLUE}5. Cloning repository...${NC}"
    git clone $REPO_URL $DEPLOY_DIR
else
    echo -e "${BLUE}5. Pulling latest changes...${NC}"
    cd $DEPLOY_DIR
    git pull origin main
fi

cd $DEPLOY_DIR

# Backend setup
echo -e "${BLUE}6. Setting up backend...${NC}"
cd backend

# Install dependencies
npm install --production

# Create .env if it doesn't exist
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}Creating .env file - Please update it with your configuration${NC}"
    cp .env.example .env
    echo -e "${YELLOW}Edit .env: nano .env${NC}"
    read -p "Press Enter after updating .env..."
fi

# Run migrations
echo -e "${BLUE}7. Running database migrations...${NC}"
npx prisma migrate deploy

# Build
echo -e "${BLUE}8. Building backend...${NC}"
npm run build

# Start with PM2
echo -e "${BLUE}9. Starting application with PM2...${NC}"
pm2 delete $PM2_APP_NAME || true
pm2 start npm --name $PM2_APP_NAME -- start
pm2 save

# Firewall setup
echo -e "${BLUE}10. Configuring firewall...${NC}"
sudo firewall-cmd --permanent --add-port=$APP_PORT/tcp
sudo firewall-cmd --reload

cd $DEPLOY_DIR

echo -e "${GREEN}✓ Deployment complete!${NC}"
echo ""
echo -e "${BLUE}Application Information:${NC}"
echo "URL: http://$(ec2-metadata --public-ipv4 | cut -d ' ' -f 2):$APP_PORT"
echo "Port: $APP_PORT"
echo "PM2 App: $PM2_APP_NAME"
echo ""
echo -e "${BLUE}Useful PM2 Commands:${NC}"
echo "pm2 start $PM2_APP_NAME"
echo "pm2 stop $PM2_APP_NAME"
echo "pm2 restart $PM2_APP_NAME"
echo "pm2 logs $PM2_APP_NAME"
echo "pm2 monit"
echo ""
echo -e "${GREEN}Deployment successful!${NC}"
