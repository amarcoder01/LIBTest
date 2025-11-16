# 📚 LibreSpeed Modern UI - API Documentation

## Backend API Endpoints

### 1. Download Test Endpoint

**Endpoint:** `GET /backend/garbage.php`

**Description:** Generates random binary data for download speed testing.

**Parameters:**
- `ckSize` (optional, integer, 1-1024): Number of 1MB chunks to generate (default: 4)
- `cors` (optional, string): Set to "true" to enable CORS headers

**Request Example:**
```http
GET /backend/garbage.php?ckSize=10&cors=true
```

**Response:**
- **Status:** 200 OK
- **Content-Type:** application/octet-stream
- **Body:** Binary data (size = ckSize × 1MB)
- **Headers:**
  ```
  Content-Description: File Transfer
  Content-Disposition: attachment; filename=random.dat
  Content-Transfer-Encoding: binary
  Cache-Control: no-store, no-cache, must-revalidate
  ```

**Example Usage:**
```javascript
// Used by speedtest_worker.js for download testing
const downloadUrl = server.server + server.dlURL + "?ckSize=10&cors=true";
```

---

### 2. Upload Test Endpoint

**Endpoint:** `POST /backend/empty.php`

**Description:** Receives uploaded data for upload speed testing. Returns empty response.

**Parameters:**
- `cors` (optional, string): Set to "true" to enable CORS headers

**Request Example:**
```http
POST /backend/empty.php?cors=true
Content-Type: application/octet-stream
Content-Length: 1048576

[Binary upload data]
```

**Response:**
- **Status:** 200 OK
- **Content-Type:** text/plain
- **Body:** Empty
- **Headers:**
  ```
  Cache-Control: no-store, no-cache, must-revalidate
  Connection: keep-alive
  ```

**Example Usage:**
```javascript
// Used by speedtest_worker.js for upload testing
const uploadUrl = server.server + server.ulURL + "?cors=true";
```

---

### 3. Ping Test Endpoint

**Endpoint:** `GET /backend/empty.php`

**Description:** Measures network latency by timing empty HTTP requests.

**Parameters:**
- `cors` (optional, string): Set to "true" to enable CORS headers

**Request Example:**
```http
GET /backend/empty.php?cors=true
```

**Response:**
- **Status:** 200 OK
- **Content-Type:** text/plain
- **Body:** Empty
- **Headers:**
  ```
  Cache-Control: no-store, no-cache, must-revalidate
  Connection: keep-alive
  ```

**Example Usage:**
```javascript
// Used by speedtest_worker.js for ping testing
const pingUrl = server.server + server.pingURL + "?cors=true";
```

---

### 4. Client IP Information Endpoint

**Endpoint:** `GET /backend/getIP.php`

**Description:** Returns client IP address and optional ISP/geolocation information.

**Parameters:**
- `isp` (optional, string): Set to "true" to include ISP information
- `distance` (optional, string): Set to "km" or "mi" to include distance calculation
- `cors` (optional, string): Set to "true" to enable CORS headers

**Request Example:**
```http
GET /backend/getIP.php?isp=true&distance=km&cors=true
```

**Response:**
- **Status:** 200 OK
- **Content-Type:** application/json; charset=utf-8
- **Body:** JSON object with client information

**Response Format:**
```json
{
  "processedString": "192.168.1.100 - Local ISP, US (25 km)",
  "rawIspInfo": {
    "ip": "192.168.1.100",
    "city": "New York",
    "region": "New York", 
    "country": "US",
    "loc": "40.7128,-74.0060",
    "org": "AS12345 Local ISP Inc.",
    "postal": "10001",
    "timezone": "America/New_York"
  }
}
```

**Simple Response (no ISP):**
```json
{
  "processedString": "192.168.1.100",
  "rawIspInfo": ""
}
```

**Example Usage:**
```javascript
// Used by speedtest_worker.js to get client info
const getIpUrl = server.server + server.getIpURL + "?isp=true&distance=km&cors=true";
```

---

### 5. Server Configuration Endpoint

**Endpoint:** `GET /servers.json`

**Description:** Provides list of available speed test servers.

**Request Example:**
```http
GET /servers.json
```

**Response:**
- **Status:** 200 OK
- **Content-Type:** application/json
- **Body:** Array of server configurations

**Response Format:**
```json
[
  {
    "name": "Primary Server (HTTPS)",
    "server": "https://your-domain.com/",
    "dlURL": "backend/garbage.php",
    "ulURL": "backend/empty.php", 
    "pingURL": "backend/empty.php",
    "getIpURL": "backend/getIP.php"
  },
  {
    "name": "Secondary Server (HTTP)",
    "server": "http://your-domain.com/",
    "dlURL": "backend/garbage.php",
    "ulURL": "backend/empty.php",
    "pingURL": "backend/empty.php",
    "getIpURL": "backend/getIP.php"
  }
]
```

**Example Usage:**
```javascript
// Used by modern-ui.html to populate server selection
fetch('servers.json')
  .then(response => response.json())
  .then(servers => {
    // Populate server dropdown
  });
```

---

### 6. Modern UI Endpoints

#### Basic Modern UI
**Endpoint:** `GET /modern-ui.html`

**Description:** Main speed test interface with manual server selection.

**Response:**
- **Status:** 200 OK
- **Content-Type:** text/html; charset=utf-8
- **Body:** Complete HTML page with modern UI

#### Auto-Select Modern UI
**Endpoint:** `GET /modern-ui-auto-select.html`

**Description:** Enhanced speed test interface with automatic server selection.

**Response:**
- **Status:** 200 OK
- **Content-Type:** text/html; charset=utf-8
- **Body:** Complete HTML page with auto-selection features

---

## Frontend Integration

### Speedtest Object Methods

**Initialization:**
```javascript
const speedtest = new Speedtest();
speedtest.setParameter("telemetry_level", "basic");
```

**Server Configuration:**
```javascript
// Manual server selection
speedtest.setSelectedServer(server);

// Auto server selection (built-in LibreSpeed feature)
speedtest.selectServer(callback);
```

**Test Control:**
```javascript
// Start test
speedtest.start();

// Abort test
speedtest.abort();
```

### Callback Functions

**onupdate(data):** Called periodically during test execution
```javascript
speedtest.onupdate = function(data) {
  // Update UI with live data
  console.log('Download:', data.dlStatus, 'Mbit/s');
  console.log('Upload:', data.ulStatus, 'Mbit/s');
  console.log('Ping:', data.pingStatus, 'ms');
  console.log('Jitter:', data.jitterStatus, 'ms');
  console.log('Progress:', data.dlProgress * 100, '%');
};
```

**onend(aborted):** Called when test completes
```javascript
speedtest.onend = function(aborted) {
  if (aborted) {
    console.log('Test was aborted');
  } else {
    console.log('Test completed successfully');
  }
};
```

### Data Format Reference

**Test States:**
- `-1`: Not started
- `0`: Starting
- `1`: Download test
- `2`: Ping + Jitter test
- `3`: Upload test
- `4`: Finished
- `5`: Aborted

**Data Object Structure:**
```javascript
{
  dlStatus: "45.23",        // Download speed (Mbit/s)
  ulStatus: "12.45",        // Upload speed (Mbit/s)
  pingStatus: "15",         // Ping time (ms)
  jitterStatus: "2",        // Jitter (ms)
  dlProgress: 0.75,         // Download progress (0-1)
  ulProgress: 0.0,            // Upload progress (0-1)
  pingProgress: 0.5,        // Ping progress (0-1)
  testState: 1,              // Current test state
  clientIp: "192.168.1.100" // Client IP address
}
```

## Error Handling

### Common HTTP Status Codes

- **200 OK**: Successful request
- **404 Not Found**: Endpoint or file not found
- **500 Internal Server Error**: PHP/server error
- **503 Service Unavailable**: Server overloaded

### CORS Headers

All endpoints support CORS when `cors=true` parameter is provided:
```http
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET, POST
Access-Control-Allow-Headers: Content-Encoding, Content-Type
```

### Error Response Format

Backend errors typically return HTTP status with plain text error message:
```http
HTTP/1.1 500 Internal Server Error
Content-Type: text/plain

Internal Server Error
```

## Performance Considerations

### Request Optimization
- Use appropriate `ckSize` values (4-20 for most connections)
- Enable gzip compression on web server (except for garbage.php)
- Use HTTP/2 or HTTP/3 for better multiplexing

### Rate Limiting
- Consider implementing rate limiting for production deployments
- Monitor server resources during high load
- Use CDN for static assets (UI files)

### Security Notes
- All endpoints are read-only (except upload endpoint)
- No authentication required for basic speed testing
- Consider IP-based rate limiting for production
- Use HTTPS for accurate results and security

This API documentation covers all endpoints used by the modern UI integration with LibreSpeed backend.