# Complete Backend Files Deployment Guide

## Required Backend Files for Mumbai Server (65.20.76.247)

To fully integrate the LibreSpeed backend with your Vultr Mumbai server, you need these files:

---

## 📋 **ESSENTIAL FILES (Required)**

### 1. **garbage.php** ⬇️
- **Purpose**: Download speed test
- **Size**: 1,620 bytes
- **What it does**: Generates random data chunks (1MB each) to test download speed
- **Location**: `/var/www/html/backend/garbage.php`

### 2. **empty.php** ⬆️📡
- **Purpose**: Upload and Ping tests
- **Size**: 562 bytes
- **What it does**: Returns empty response with proper headers for upload/ping measurements
- **Location**: `/var/www/html/backend/empty.php`

### 3. **getIP.php** 🌐
- **Purpose**: Client IP detection with ISP info
- **Size**: 7,599 bytes
- **What it does**: Detects client IP and optionally fetches ISP/country information
- **Location**: `/var/www/html/backend/getIP.php`

### 4. **getIP_util.php** 🔧
- **Purpose**: Utility functions for IP detection
- **Size**: 546 bytes
- **What it does**: Helper function to extract client IP from various server variables
- **Location**: `/var/www/html/backend/getIP_util.php`
- **Note**: Required by `getIP.php`

---

## 🔧 **OPTIONAL FILES (Enhanced Features)**

### 5. **getIP_ipInfo_apikey.php** 🔑
- **Purpose**: API key for ipinfo.io service
- **Size**: 81 bytes
- **What it does**: Stores API key for ISP information lookup
- **Location**: `/var/www/html/backend/getIP_ipInfo_apikey.php`
- **Optional**: Without this, basic IP detection still works
- **Content Example**:
```php
<?php
$IPINFO_APIKEY = 'your_api_key_here';
```

### 6. **geoip2.phar** 📦
- **Purpose**: MaxMind GeoIP2 library (PHP 8+ only)
- **Size**: 542,785 bytes (~530 KB)
- **What it does**: Enables offline IP lookup using local database
- **Location**: `/var/www/html/backend/geoip2.phar`
- **Optional**: Used for offline ISP detection if API key not available

### 7. **country_asn.mmdb** 🗺️
- **Purpose**: Offline IP geolocation database
- **Size**: 48,965,921 bytes (~46.7 MB)
- **What it does**: Offline database for country and ISP detection
- **Location**: `/var/www/html/backend/country_asn.mmdb`
- **Optional**: Only needed if you want offline ISP detection
- **Note**: Requires PHP 8+ and geoip2.phar

---

## 📦 **DEPLOYMENT METHODS**

### Method 1: SCP (Secure Copy) - Recommended

```bash
# From your local machine (Windows PowerShell/CMD)
# Navigate to your project directory first
cd d:\speedtest-master

# Copy all essential backend files
scp backend/garbage.php root@65.20.76.247:/var/www/html/backend/
scp backend/empty.php root@65.20.76.247:/var/www/html/backend/
scp backend/getIP.php root@65.20.76.247:/var/www/html/backend/
scp backend/getIP_util.php root@65.20.76.247:/var/www/html/backend/

# Optional: Copy enhanced features (if you want ISP info)
scp backend/getIP_ipInfo_apikey.php root@65.20.76.247:/var/www/html/backend/
scp backend/geoip2.phar root@65.20.76.247:/var/www/html/backend/
scp backend/country_asn.mmdb root@65.20.76.247:/var/www/html/backend/
```

### Method 2: SFTP (Interactive)

```bash
# Connect via SFTP
sftp root@65.20.76.247

# Once connected:
sftp> cd /var/www/html
sftp> mkdir backend
sftp> cd backend
sftp> lcd d:\speedtest-master\backend
sftp> put garbage.php
sftp> put empty.php
sftp> put getIP.php
sftp> put getIP_util.php
sftp> put getIP_ipInfo_apikey.php
sftp> put geoip2.phar
sftp> put country_asn.mmdb
sftp> quit
```

### Method 3: Git Clone (If you have Git on server)

```bash
# SSH into server
ssh root@65.20.76.247

# Clone the repository
cd /var/www/html
git clone https://github.com/amarcoder01/LIBTest.git temp_speedtest

# Copy only backend files
mkdir -p backend
cp temp_speedtest/backend/* backend/

# Clean up
rm -rf temp_speedtest

# Set permissions
chown -R www-data:www-data backend/
chmod -R 755 backend/
```

### Method 4: Manual Upload via FTP Client

Use **FileZilla** or **WinSCP**:
1. Connect to `65.20.76.247`
2. Username: `root`
3. Protocol: SFTP (Port 22)
4. Navigate to `/var/www/html/`
5. Create `backend` folder
6. Upload all 7 files from `d:\speedtest-master\backend\`

---

## ⚙️ **POST-DEPLOYMENT CONFIGURATION**

### 1. Set Proper Permissions

```bash
ssh root@65.20.76.247

# Set ownership to web server user
chown -R www-data:www-data /var/www/html/backend/

# Set proper file permissions
chmod 755 /var/www/html/backend/
chmod 644 /var/www/html/backend/*.php
chmod 644 /var/www/html/backend/*.phar
chmod 644 /var/www/html/backend/*.mmdb
```

### 2. Verify File Structure

```bash
ssh root@65.20.76.247
ls -lah /var/www/html/backend/

# Should show:
# garbage.php
# empty.php
# getIP.php
# getIP_util.php
# getIP_ipInfo_apikey.php (optional)
# geoip2.phar (optional)
# country_asn.mmdb (optional)
```

### 3. Test Each Endpoint

```bash
# Test from server
curl http://localhost/backend/empty.php
curl http://localhost/backend/garbage.php?ckSize=1
curl http://localhost/backend/getIP.php

# Test from external (your machine)
curl http://65.20.76.247/backend/empty.php
curl http://65.20.76.247/backend/garbage.php?ckSize=1
curl http://65.20.76.247/backend/getIP.php
```

### 4. Check PHP Error Logs

```bash
tail -f /var/log/apache2/error.log     # Apache
# OR
tail -f /var/log/nginx/error.log       # Nginx
```

---

## 🔐 **SECURITY NOTES**

### File Permissions
- **PHP files**: `644` (readable, not executable)
- **Directory**: `755` (accessible)
- **Owner**: `www-data:www-data` (web server user)

### API Key Security
If using `getIP_ipInfo_apikey.php`:
```php
<?php
// Never commit this to public repos!
$IPINFO_APIKEY = 'your_actual_api_key_from_ipinfo.io';
```

Get free API key from: https://ipinfo.io/signup

---

## 🧪 **TESTING CHECKLIST**

After deployment, test each endpoint:

### ✅ Test empty.php (Ping/Upload)
```bash
curl -I http://65.20.76.247/backend/empty.php

# Expected: HTTP/1.1 200 OK
# Expected: Access-Control-Allow-Origin: *
```

### ✅ Test garbage.php (Download)
```bash
curl -I http://65.20.76.247/backend/garbage.php?ckSize=1

# Expected: HTTP/1.1 200 OK
# Expected: Content-Type: application/octet-stream
```

### ✅ Test getIP.php (IP Detection)
```bash
curl http://65.20.76.247/backend/getIP.php

# Expected: {"processedString":"YOUR_IP","rawIspInfo":""}
```

### ✅ Test getIP.php with ISP info
```bash
curl http://65.20.76.247/backend/getIP.php?isp=true

# Expected: {"processedString":"YOUR_IP - ISP_NAME, COUNTRY","rawIspInfo":{...}}
```

---

## 📝 **MINIMAL VS FULL DEPLOYMENT**

### Minimal (Basic Speed Test - 10 KB total)
```
✅ garbage.php      (1.6 KB)   - Download test
✅ empty.php        (0.6 KB)   - Upload/Ping test  
✅ getIP.php        (7.6 KB)   - IP detection
✅ getIP_util.php   (0.5 KB)   - IP helper
```

**Result**: Speed test works, shows IP address only

### Full (With ISP Info - 47 MB total)
```
✅ All minimal files above          (~10 KB)
✅ getIP_ipInfo_apikey.php         (0.1 KB)   - API key
✅ geoip2.phar                     (530 KB)   - GeoIP library
✅ country_asn.mmdb                (46.7 MB)  - Offline DB
```

**Result**: Speed test works + shows ISP name, country, and distance

---

## 🚀 **QUICK DEPLOYMENT SCRIPT**

Create this script on your local machine:

**`deploy_to_mumbai.sh`** (Linux/Mac) or **`deploy_to_mumbai.ps1`** (Windows):

```powershell
# PowerShell script for Windows
$SERVER = "root@65.20.76.247"
$BACKEND_PATH = "d:\speedtest-master\backend"

Write-Host "Deploying backend files to Mumbai server..."

# Create backend directory on server
ssh $SERVER "mkdir -p /var/www/html/backend"

# Copy essential files
scp "$BACKEND_PATH\garbage.php" "${SERVER}:/var/www/html/backend/"
scp "$BACKEND_PATH\empty.php" "${SERVER}:/var/www/html/backend/"
scp "$BACKEND_PATH\getIP.php" "${SERVER}:/var/www/html/backend/"
scp "$BACKEND_PATH\getIP_util.php" "${SERVER}:/var/www/html/backend/"

# Set permissions
ssh $SERVER "chown -R www-data:www-data /var/www/html/backend/ && chmod -R 755 /var/www/html/backend/"

Write-Host "Deployment complete! Testing endpoints..."

# Test endpoints
curl http://65.20.76.247/backend/empty.php
curl http://65.20.76.247/backend/getIP.php

Write-Host "Done! Check output above for any errors."
```

---

## 📞 **NEED HELP?**

### Common Issues

1. **Permission Denied**: Run `chmod` and `chown` commands
2. **404 Not Found**: Check file paths and Apache/Nginx config
3. **500 Internal Error**: Check PHP error logs
4. **CORS Errors**: All files have proper CORS headers already

### File Summary Table

| File | Size | Required | Purpose |
|------|------|----------|---------|
| `garbage.php` | 1.6 KB | ✅ Yes | Download test |
| `empty.php` | 0.6 KB | ✅ Yes | Upload/Ping test |
| `getIP.php` | 7.6 KB | ✅ Yes | IP detection |
| `getIP_util.php` | 0.5 KB | ✅ Yes | IP helper |
| `getIP_ipInfo_apikey.php` | 0.1 KB | ⚠️ Optional | API key for ISP |
| `geoip2.phar` | 530 KB | ⚠️ Optional | GeoIP library |
| `country_asn.mmdb` | 46.7 MB | ⚠️ Optional | Offline ISP DB |

**TOTAL SIZE**: 
- **Minimal**: ~10 KB
- **Full**: ~47 MB

---

## ✅ **AFTER SUCCESSFUL DEPLOYMENT**

1. Update `servers.json` to re-enable Mumbai server
2. Refresh speed test page
3. Select "Vultr Mumbai" 
4. Should see "Server connected! Ready to test." ✅
5. Run the test!

**Questions?** Check `MUMBAI_SERVER_FIX.md` for server setup or `SETUP_INSTRUCTIONS.md` for general help.
