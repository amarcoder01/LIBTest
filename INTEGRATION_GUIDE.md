# LibreSpeed Modern UI Integration Guide

## Overview

This document provides a complete integration of a modern, responsive UI with the LibreSpeed speed test engine. The integration maintains full compatibility with LibreSpeed's backend while providing a clean, professional user interface.

## Key Features

- **Modern Design**: Clean, gradient-based UI with smooth animations
- **Real-time Updates**: Live values for download, upload, ping, and jitter
- **Progress Indicators**: Visual progress bars for each test phase
- **Multi-server Support**: Server selection with auto-loading from servers.json
- **Responsive Design**: Works on desktop, tablet, and mobile devices
- **Status Messages**: User-friendly feedback during test execution
- **Active Test Highlighting**: Visual indication of current test phase

## Integration Architecture

### 1. Core Components

```
modern-ui.html          - Main UI interface
speedtest.js           - LibreSpeed main engine (unchanged)
speedtest_worker.js    - LibreSpeed worker (unchanged)
backend/               - PHP backend files (unchanged)
servers.json           - Server configuration file
```

### 2. UI-to-Engine Integration Points

#### Callback Functions

The integration uses LibreSpeed's built-in callback system:

**onupdate(data)** - Called periodically during test execution
- `data.dlStatus` - Download speed (Mbit/s)
- `data.ulStatus` - Upload speed (Mbit/s) 
- `data.pingStatus` - Ping time (ms)
- `data.jitterStatus` - Jitter (ms)
- `data.dlProgress` - Download test progress (0-1)
- `data.ulProgress` - Upload test progress (0-1)
- `data.pingProgress` - Ping test progress (0-1)
- `data.testState` - Current test state (-1 to 5)
- `data.clientIp` - Client IP address

**onend(aborted)** - Called when test completes
- `aborted` - Boolean indicating if test was stopped by user

#### Test States

- `-1`: Not started
- `0`: Starting
- `1`: Download test
- `2`: Ping + Jitter test  
- `3`: Upload test
- `4`: Finished
- `5`: Aborted

### 3. UI Elements Mapping

| UI Element | LibreSpeed Data | Function |
|------------|----------------|----------|
| Download Value | `data.dlStatus` | `formatSpeed()` |
| Upload Value | `data.ulStatus` | `formatSpeed()` |
| Ping Value | `data.pingStatus` | `formatPing()` |
| Jitter Value | `data.jitterStatus` | `formatPing()` |
| Download Progress | `data.dlProgress` | `updateProgress()` |
| Upload Progress | `data.ulProgress` | `updateProgress()` |
| Ping Progress | `data.pingProgress` | `updateProgress()` |
| Active Card | `data.testState` | `updateActiveCard()` |
| Status Message | `data.testState` | `updateStatusMessage()` |

## Backend File Requirements

### Required PHP Files

1. **empty.php** - Used for upload and ping tests
   - Location: `backend/empty.php`
   - Purpose: Returns empty response for timing measurements

2. **garbage.php** - Used for download test
   - Location: `backend/garbage.php`
   - Purpose: Generates random data for download speed measurement
   - Supports chunk size parameter: `?ckSize=4` (1-1024)

3. **getIP.php** - Used for client information
   - Location: `backend/getIP.php`
   - Purpose: Returns client IP and optional ISP information
   - Supports ISP info: `?isp=true`
   - Supports distance calculation: `?distance=km`

### Server Configuration (servers.json)

```json
[
    {
        "name": "Server Name",
        "server": "https://your-domain.com/",
        "dlURL": "backend/garbage.php",
        "ulURL": "backend/empty.php",
        "pingURL": "backend/empty.php",
        "getIpURL": "backend/getIP.php"
    }
]
```

## Hosting Instructions

### 1. Web Server Requirements

- **PHP**: Version 7.0+ (8.0+ recommended for offline IP database)
- **Web Server**: Apache, Nginx, or similar
- **HTTPS**: Recommended for accurate results
- **CORS**: Backend files support CORS headers

### 2. Directory Structure

```
your-web-root/
├── modern-ui.html
├── speedtest.js
├── speedtest_worker.js
├── servers.json
├── backend/
│   ├── empty.php
│   ├── garbage.php
│   ├── getIP.php
│   ├── getIP_util.php
│   ├── geoip2.phar (optional)
│   └── country_asn.mmdb (optional)
└── results/ (optional, for telemetry)
```

### 3. Backend File Setup

#### Step 1: Upload Backend Files
Upload the following files to your `backend/` directory:
- `empty.php`
- `garbage.php` 
- `getIP.php`
- `getIP_util.php`

#### Step 2: Configure IP Information (Optional)
For enhanced IP information:
1. Upload `geoip2.phar` and `country_asn.mmdb` (requires PHP 8.0+)
2. Create `getIP_ipInfo_apikey.php` with your IPinfo API key:
```php
<?php
$IPINFO_APIKEY = "your-api-key-here";
```

#### Step 3: Test Backend Files
Verify each backend file is accessible:
- `https://your-domain.com/backend/empty.php` - Should return empty response
- `https://your-domain.com/backend/garbage.php` - Should download random data
- `https://your-domain.com/backend/getIP.php` - Should return your IP as JSON

### 4. Server Configuration

#### Configure servers.json
Create a `servers.json` file in your web root:

```json
[
    {
        "name": "Primary Server (HTTPS)",
        "server": "https://your-primary-domain.com/",
        "dlURL": "backend/garbage.php",
        "ulURL": "backend/empty.php",
        "pingURL": "backend/empty.php",
        "getIpURL": "backend/getIP.php"
    },
    {
        "name": "Secondary Server (HTTP)",
        "server": "http://your-secondary-domain.com/",
        "dlURL": "backend/garbage.php",
        "ulURL": "backend/empty.php",
        "pingURL": "backend/empty.php",
        "getIpURL": "backend/getIP.php"
    }
]
```

#### Protocol Considerations
- Use `https://` for secure connections
- Use `//` for protocol-relative URLs (works with both HTTP/HTTPS)
- Ensure CORS headers are properly configured if using cross-domain requests

### 5. Performance Optimization

#### PHP Configuration
- Enable output buffering for better performance
- Configure appropriate memory limits for `garbage.php`
- Set reasonable execution time limits

#### Web Server Configuration
- Enable gzip compression (except for `garbage.php`)
- Configure appropriate cache headers
- Optimize for concurrent connections

### 6. Security Considerations

- Keep PHP and web server software updated
- Use HTTPS for all communications
- Implement rate limiting if needed
- Monitor server resources during high load
- Consider implementing authentication for private deployments

## Customization Guide

### Styling
The UI uses CSS custom properties for easy theming:
- Primary gradient: `#667eea` to `#764ba2`
- Download color: `#4fd1c5`
- Upload color: `#fbbc04`
- Ping color: `#4299e1`
- Jitter color: `#f56565`

### Adding Features
- **Telemetry**: Enable by setting `telemetry_level` parameter
- **Custom Settings**: Use `speedtest.setParameter()` for test configuration
- **Additional Metrics**: Access raw data in `onupdate` callback
- **Custom Callbacks**: Add your own functions to handle specific events

### Browser Compatibility
- Modern browsers (Chrome 60+, Firefox 55+, Safari 11+, Edge 79+)
- Mobile browsers (iOS Safari 11+, Chrome Mobile 60+)
- Web Workers support required

## Troubleshooting

### Common Issues

1. **Test won't start**: Check server configuration and CORS settings
2. **Slow results**: Verify PHP configuration and server resources
3. **Inconsistent results**: Check network conditions and server load
4. **UI not updating**: Verify JavaScript console for errors

### Debug Mode
Enable debug logging by setting telemetry level:
```javascript
speedtest.setParameter("telemetry_level", "3");
```

Check browser console for detailed test information and error messages.

## Support

For LibreSpeed engine issues, refer to the official documentation:
- GitHub: https://github.com/librespeed/speedtest
- Documentation: doc.md in the project root

For UI integration issues, check the browser console and network tab for specific error messages.