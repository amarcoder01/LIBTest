# Mumbai Server (65.20.76.247) - Setup Guide

## Current Status: ❌ NOT WORKING

**Problem**: Port 80 (HTTP) is not responding on the Vultr Mumbai server.

**Diagnosis Results**:
- ✅ Server is online and pingable (63ms latency)
- ❌ Port 80 (HTTP) - Not responding
- ⚠️ No web server running

## Server Details

```
IP Address:    65.20.76.247
Netmask:       255.255.254.0
Gateway:       65.20.76.1
Reverse DNS:   65.20.76.247.vultrusercontent.com
Provider:      Vultr (Mumbai)
```

## How to Fix

### Step 1: SSH into Your Vultr Server

```bash
ssh root@65.20.76.247
```

### Step 2: Install Web Server (Choose One)

**Option A: Apache with PHP**
```bash
# Update package list
apt update

# Install Apache and PHP
apt install -y apache2 php libapache2-mod-php php-mbstring

# Enable Apache
systemctl enable apache2
systemctl start apache2

# Verify it's running
systemctl status apache2
```

**Option B: Nginx with PHP-FPM**
```bash
# Update package list
apt update

# Install Nginx and PHP
apt install -y nginx php-fpm php-mbstring

# Enable services
systemctl enable nginx
systemctl enable php-fpm
systemctl start nginx
systemctl start php-fpm

# Verify they're running
systemctl status nginx
systemctl status php-fpm
```

### Step 3: Deploy Backend Files

```bash
# Create backend directory
mkdir -p /var/www/html/backend

# Upload your backend PHP files to the server
# You can use SCP, SFTP, or Git

# Using SCP from your local machine:
scp -r d:\speedtest-master\backend\* root@65.20.76.247:/var/www/html/backend/

# Set proper permissions
chown -R www-data:www-data /var/www/html/backend/
chmod -R 755 /var/www/html/backend/
```

### Step 4: Configure Firewall

```bash
# Allow HTTP traffic (port 80)
ufw allow 80/tcp

# Allow HTTPS traffic (port 443) - optional but recommended
ufw allow 443/tcp

# Reload firewall
ufw reload

# Check status
ufw status
```

### Step 5: Test the Server

```bash
# Test locally on the server
curl http://localhost/backend/empty.php

# If you get a response, the server is working!
```

### Step 6: Test from Your App

1. Keep the Mumbai server in `servers.json`:
```json
{
    "name": "Vultr Mumbai",
    "server": "http://65.20.76.247/",
    "dlURL": "backend/garbage.php",
    "ulURL": "backend/empty.php",
    "pingURL": "backend/empty.php",
    "getIpURL": "backend/getIP.php"
}
```

2. Reload the speed test page
3. Select "Vultr Mumbai" from the dropdown
4. You should see "Server connected! Ready to test." in green

## Optional: Add HTTPS (Recommended)

```bash
# Install Certbot for free SSL certificate
apt install -y certbot python3-certbot-apache  # For Apache
# OR
apt install -y certbot python3-certbot-nginx   # For Nginx

# Get SSL certificate (you'll need a domain name)
# For now, you can test with HTTP
```

## Troubleshooting

### Check if web server is running:
```bash
systemctl status apache2  # For Apache
systemctl status nginx     # For Nginx
```

### Check if port 80 is open:
```bash
netstat -tuln | grep :80
```

### Test PHP processing:
```bash
echo "<?php phpinfo(); ?>" > /var/www/html/test.php
curl http://localhost/test.php
```

### Check Apache/Nginx logs:
```bash
tail -f /var/log/apache2/error.log    # Apache
tail -f /var/log/nginx/error.log      # Nginx
```

## Why Render Deployment Works

The Render deployment (`https://libtest.onrender.com/`) works because:
- ✅ Web server is properly configured
- ✅ Backend files are deployed
- ✅ HTTPS is enabled
- ✅ Firewall allows traffic
- ✅ CORS is configured correctly

Your Mumbai server needs the same setup!

## Quick Commands Reference

```bash
# Start web server
systemctl start apache2     # or nginx

# Stop web server  
systemctl stop apache2      # or nginx

# Restart web server
systemctl restart apache2   # or nginx

# View web server status
systemctl status apache2    # or nginx

# Check firewall rules
ufw status

# View active connections
netstat -tuln | grep LISTEN
```

## After Setup

Once the Mumbai server is properly configured:
1. Uncommit it in `servers.json`
2. The validation should pass
3. Tests should work correctly

**Need Help?** Check the main SETUP_INSTRUCTIONS.md for more details.
