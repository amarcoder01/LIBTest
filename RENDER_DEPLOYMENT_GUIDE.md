# 🚀 LibreSpeed Modern UI - Render Deployment Guide

## 📋 Complete Deployment Instructions

### 1. Build & Start Commands

**Build Command:**
```bash
docker build -t librespeed-modern .
```

**Start Command:**
```bash
docker run -p 80:80 librespeed-modern
```

**For Render (Auto-detected):**
- Build Command: `docker build -t librespeed-modern .`
- Start Command: `docker run -p 80:80 librespeed-modern`

### 2. Runtime / Platform

**Platform:** Docker (Recommended for Render)
- **Base Image:** `php:8.1-apache`
- **Web Server:** Apache 2.4
- **PHP Version:** 8.1
- **Port:** 80 (HTTP)

**Alternative Runtime Options:**
- **PHP Native:** Requires PHP 7.0+ with Apache/Nginx
- **Node.js:** Not recommended (LibreSpeed is PHP-based)
- **Python:** Not supported (LibreSpeed requires PHP)

### 3. Environment Variables

**No Required Environment Variables** - The application works out-of-the-box with default configuration.

**Optional Environment Variables (for advanced configuration):**
```bash
# Server Configuration
SERVER_NAME=LibreSpeed Modern UI
SERVER_ADMIN=admin@yourdomain.com

# PHP Configuration (optional)
PHP_MEMORY_LIMIT=256M
PHP_MAX_EXECUTION_TIME=300
PHP_UPLOAD_MAX_FILESIZE=100M
PHP_POST_MAX_SIZE=100M

# Apache Configuration (optional)
APACHE_DOCUMENT_ROOT=/var/www/html
APACHE_SERVER_NAME=localhost
```

### 4. Backend API Endpoints

#### Core Speed Test Endpoints

**1. Download Test Endpoint**
```
GET /backend/garbage.php?ckSize=4
```
- **Purpose:** Generates random data for download speed testing
- **Parameters:** `ckSize` (1-1024) - Number of 1MB chunks to generate
- **Response:** Binary data (random bytes)
- **Content-Type:** application/octet-stream
- **Example Response:** Binary data stream (1-1024 MB)

**2. Upload Test Endpoint**
```
POST /backend/empty.php
```
- **Purpose:** Receives uploaded data for upload speed testing
- **Request Body:** Binary data (uploaded by client)
- **Response:** Empty response (HTTP 200 OK)
- **Content-Type:** text/plain (empty)
- **Example Response:** `` (empty body)

**3. Ping Test Endpoint**
```
GET /backend/empty.php?cors=true
```
- **Purpose:** Measures network latency (ping)
- **Parameters:** `cors=true` (for CORS support)
- **Response:** Empty response with timing headers
- **Content-Type:** text/plain (empty)
- **Example Response:** `` (empty body)

**4. Client IP Information Endpoint**
```
GET /backend/getIP.php?isp=true&distance=km
```
- **Purpose:** Returns client IP and optional ISP/geolocation data
- **Parameters:** 
  - `isp=true` (optional) - Include ISP information
  - `distance=km` (optional) - Include distance calculation
- **Response:** JSON object with client information
- **Content-Type:** application/json
- **Example Response:**
```json
{
  "processedString": "192.168.1.100 - Local ISP, US (25 km)",
  "rawIspInfo": {
    "ip": "192.168.1.100",
    "city": "New York",
    "region": "New York",
    "country": "US",
    "loc": "40.7128,-74.0060",
    "org": "AS12345 Local ISP Inc."
  }
}
```

#### Frontend UI Endpoints

**5. Modern UI (Basic)**
```
GET /modern-ui.html
```
- **Purpose:** Main speed test interface with manual server selection
- **Response:** HTML page with modern UI
- **Content-Type:** text/html

**6. Modern UI (Auto-Select)**
```
GET /modern-ui-auto-select.html
```
- **Purpose:** Enhanced speed test interface with automatic server selection
- **Response:** HTML page with auto-selection features
- **Content-Type:** text/html

**7. Server Configuration**
```
GET /servers.json
```
- **Purpose:** Provides list of available test servers
- **Response:** JSON array of server configurations
- **Content-Type:** application/json
- **Example Response:**
```json
[
  {
    "name": "Primary Server",
    "server": "https://your-domain.com/",
    "dlURL": "backend/garbage.php",
    "ulURL": "backend/empty.php",
    "pingURL": "backend/empty.php",
    "getIpURL": "backend/getIP.php"
  }
]
```

### 5. Render Configuration

#### Service Settings
- **Service Type:** Web Service
- **Runtime:** Docker
- **Port:** 80 (HTTP)
- **Health Check Path:** `/backend/empty.php`

#### Build Settings
- **Dockerfile Path:** `./Dockerfile` (root directory)
- **Docker Build Context:** `.` (root directory)
- **Build Timeout:** 15 minutes (default)

#### Environment Configuration
- **Environment Variables:** None required (see section 3 for optional vars)
- **Secrets:** Not required for basic deployment

#### Scaling Configuration
- **Instance Type:** Starter (free tier) or Standard (paid)
- **Auto-scaling:** Not required for typical usage
- **Concurrent Connections:** Limited by instance type

#### Network Configuration
- **CORS Settings:** Already configured in backend files
- **Custom Domains:** Supported (configure in Render dashboard)
- **SSL/TLS:** Automatically provided by Render

#### Directory Structure
```
/
├── Dockerfile                 # Docker configuration
├── modern-ui.html            # Basic modern UI
├── modern-ui-auto-select.html # Enhanced UI with auto-selection
├── servers.json              # Server configuration
├── speedtest.js              # LibreSpeed main engine
├── speedtest_worker.js       # LibreSpeed web worker
├── backend/                  # PHP backend files
│   ├── empty.php            # Upload/ping endpoint
│   ├── garbage.php          # Download endpoint
│   ├── getIP.php            # Client info endpoint
│   └── ...
├── results/                  # Telemetry files (optional)
└── ...
```

### 🚀 Quick Deploy Steps

1. **Fork/Clone the Repository**
   ```bash
   git clone https://github.com/amarcoder01/LIBTest.git
   cd LIBTest
   ```

2. **Configure Servers (Optional)**
   Edit `servers.json` to add your server URLs

3. **Deploy to Render**
   - Connect your GitHub repository to Render
   - Select the repository: `amarcoder01/LIBTest`
   - Service type: Web Service
   - Runtime: Docker
   - Port: 80
   - Deploy!

4. **Access Your Speed Test**
   - Basic UI: `https://your-app.onrender.com/modern-ui.html`
   - Auto-Select UI: `https://your-app.onrender.com/modern-ui-auto-select.html`

### 🔧 Troubleshooting

**Common Issues:**
- **Port 80 not responding:** Check Dockerfile EXPOSE directive
- **PHP files not executing:** Verify Apache PHP module is enabled
- **CORS errors:** Backend files include CORS headers
- **Slow performance:** Consider upgrading Render instance type

**Health Check:**
Test your deployment: `curl -f https://your-app.onrender.com/backend/empty.php`

### 📊 Monitoring

- **Logs:** Available in Render dashboard
- **Metrics:** Response time, error rate, CPU/memory usage
- **Uptime:** Monitor via Render dashboard or external services

### 🎯 Success Criteria

✅ Deployment successful when:
- Modern UI loads at `/modern-ui.html`
- Auto-select UI loads at `/modern-ui-auto-select.html`
- Backend endpoints return proper responses
- Speed test completes successfully
- Health check passes

Your LibreSpeed Modern UI is now ready for production deployment on Render! 🎉