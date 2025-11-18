# Setup SSL/HTTPS for Mumbai Server (65.20.76.247)

## Problem

**Mixed Content Error**: Your site is served over HTTPS, but Mumbai server uses HTTP.

```
Error: Mixed Content: The page at 'https://libtest.onrender.com/modern-ui.html' 
was loaded over HTTPS, but requested an insecure resource 
'http://65.20.76.247/backend/empty.php'
```

**Browsers block HTTP requests from HTTPS pages for security.**

## Solutions

### Option 1: Use IP with HTTPS (Quick Fix - Self-Signed Certificate)

This will work but show "Not Secure" warning.

```bash
# SSH into server
ssh root@65.20.76.247

# Install OpenSSL (usually pre-installed)
apt update
apt install -y openssl

# Generate self-signed certificate
mkdir -p /etc/ssl/private
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/apache-selfsigned.key \
  -out /etc/ssl/certs/apache-selfsigned.crt \
  -subj "/C=IN/ST=Maharashtra/L=Mumbai/O=SpeedTest/CN=65.20.76.247"

# For Apache - Enable SSL module
a2enmod ssl
a2enmod headers

# Create SSL virtual host config
cat > /etc/apache2/sites-available/default-ssl.conf << 'EOF'
<IfModule mod_ssl.c>
    <VirtualHost _default_:443>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

        SSLEngine on
        SSLCertificateFile /etc/ssl/certs/apache-selfsigned.crt
        SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key

        <FilesMatch "\.(cgi|shtml|phtml|php)$">
            SSLOptions +StdEnvVars
        </FilesMatch>
        
        <Directory /usr/lib/cgi-bin>
            SSLOptions +StdEnvVars
        </Directory>
    </VirtualHost>
</IfModule>
EOF

# Enable SSL site
a2ensite default-ssl

# Open firewall for HTTPS
ufw allow 443/tcp

# Restart Apache
systemctl restart apache2

# Test
curl -k https://65.20.76.247/backend/empty.php
```

### Option 2: Get a Domain Name + Free SSL (Recommended)

**Steps:**

1. **Get a domain** (e.g., from Namecheap, GoDaddy, or Cloudflare)
2. **Point domain to your server**:
   - Create A record: `speedtest.yourdomain.com` → `65.20.76.247`
3. **Install Certbot for free SSL**:

```bash
ssh root@65.20.76.247

# Install Certbot
apt update
apt install -y certbot python3-certbot-apache

# Get free SSL certificate (Let's Encrypt)
certbot --apache -d speedtest.yourdomain.com

# Follow prompts:
# - Enter email
# - Agree to terms
# - Choose to redirect HTTP to HTTPS (recommended)

# Auto-renewal is set up automatically!
# Test renewal:
certbot renew --dry-run
```

4. **Update servers.json**:
```json
{
    "name": "Vultr Mumbai",
    "server": "https://speedtest.yourdomain.com/",
    ...
}
```

### Option 3: Use Cloudflare (Free SSL + CDN)

**Benefits**: Free SSL, DDoS protection, CDN, no server changes needed

**Steps:**

1. **Sign up** at https://cloudflare.com (free)
2. **Add your domain** to Cloudflare
3. **Update nameservers** at your domain registrar to Cloudflare's
4. **Add DNS record**:
   - Type: `A`
   - Name: `speedtest` (or `@` for root)
   - IPv4: `65.20.76.247`
   - Proxy status: ✅ Proxied (orange cloud)
5. **SSL/TLS Settings**:
   - Go to SSL/TLS → Overview
   - Set to "Flexible" (if server has no SSL) or "Full" (if self-signed SSL)
6. **Done!** Access via `https://speedtest.yourdomain.com`

### Option 4: Temporary Workaround - Access via HTTP

**For testing only** - not recommended for production:

Access your speedtest via HTTP instead of HTTPS:
- ❌ `https://libtest.onrender.com/modern-ui.html`
- ✅ `http://libtest.onrender.com/modern-ui.html` (if Render allows)

**Note**: Render likely forces HTTPS, so this may not work.

## Quick Test - Self-Signed Certificate

If you just want to test quickly, use the self-signed certificate:

```bash
# On Mumbai server
ssh root@65.20.76.247

# Quick SSL setup
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/apache-selfsigned.key \
  -out /etc/ssl/certs/apache-selfsigned.crt \
  -subj "/CN=65.20.76.247"

a2enmod ssl
a2ensite default-ssl
ufw allow 443/tcp
systemctl restart apache2
```

Then in your browser, when you access `https://65.20.76.247/backend/empty.php`:
- Click "Advanced" when you see security warning
- Click "Proceed anyway" or "Accept risk"

## Update servers.json

I've already updated it to use HTTPS. After setting up SSL, the Mumbai server will work!

```json
{
    "name": "Vultr Mumbai",
    "server": "https://65.20.76.247/",  // ← Now using HTTPS!
    ...
}
```

## Recommended Solution Summary

**Best for Production**: Option 2 (Domain + Let's Encrypt SSL)
- ✅ Free SSL certificate
- ✅ Trusted by browsers (no warnings)
- ✅ Auto-renewal
- ✅ Takes ~10 minutes to set up

**Best for Quick Test**: Option 1 (Self-Signed)
- ✅ Works immediately
- ⚠️ Browser security warning (need to accept)
- ✅ Good for testing

**Best Overall**: Option 3 (Cloudflare)
- ✅ Free SSL
- ✅ No server configuration needed
- ✅ Extra benefits (CDN, DDoS protection)
- ✅ Trusted certificate

## After SSL Setup

1. Access your speedtest: `https://libtest.onrender.com/modern-ui.html`
2. Select "Vultr Mumbai"
3. Should see "Server connected! Ready to test." ✅
4. Tests will work!

## Troubleshooting

### Certificate not trusted
- Use Let's Encrypt (Option 2) for trusted certificates
- Or use Cloudflare (Option 3)

### Port 443 blocked
```bash
ufw status
ufw allow 443/tcp
systemctl restart apache2
```

### Apache SSL not enabled
```bash
a2enmod ssl
a2ensite default-ssl
systemctl restart apache2
```

### Test SSL
```bash
# From server
curl -k https://localhost/backend/empty.php

# From internet
curl -k https://65.20.76.247/backend/empty.php
```

## Need Help?

Choose one of the options above and follow the steps. Option 2 (Domain + Let's Encrypt) is recommended for the best experience!
