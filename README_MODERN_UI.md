# LibreSpeed Modern UI Integration

A modern, responsive user interface for LibreSpeed speed test engine. This integration provides a clean, professional UI while maintaining full compatibility with LibreSpeed's backend.

## 🚀 Quick Start

### 1. Files Overview

**Main UI Files:**
- `modern-ui.html` - Basic modern UI with server selection
- `modern-ui-auto-select.html` - Enhanced UI with automatic server selection
- `servers.json` - Server configuration file
- `INTEGRATION_GUIDE.md` - Complete integration documentation

**LibreSpeed Core (unchanged):**
- `speedtest.js` - Main speedtest engine
- `speedtest_worker.js` - Web worker for test execution
- `backend/` - PHP backend files (`empty.php`, `garbage.php`, `getIP.php`)

### 2. Setup Instructions

#### Option A: Use with PHP Development Server
```bash
# Start PHP development server
php -S localhost:8000

# Open in browser
# Basic UI: http://localhost:8000/modern-ui.html
# Auto-select UI: http://localhost:8000/modern-ui-auto-select.html
```

#### Option B: Use with Existing Web Server
1. Upload all files to your web server
2. Ensure PHP is available (7.0+ recommended)
3. Configure `servers.json` with your server URLs
4. Access the HTML files through your web server

### 3. Server Configuration

Edit `servers.json` to add your speed test servers:

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

### 4. Testing Backend Files

Verify your setup by accessing these URLs:
- `https://your-domain.com/backend/empty.php` - Should return empty response
- `https://your-domain.com/backend/garbage.php` - Should download random data
- `https://your-domain.com/backend/getIP.php` - Should return your IP as JSON

## ✨ Features

### Modern UI (`modern-ui.html`)
- **Clean Design**: Modern gradient background with glassmorphism effects
- **Live Updates**: Real-time speed and ping values
- **Progress Indicators**: Visual progress bars for each test phase
- **Responsive Layout**: Works on desktop, tablet, and mobile
- **Status Messages**: User-friendly feedback during tests
- **Server Selection**: Dropdown with manual server selection

### Auto-Select UI (`modern-ui-auto-select.html`)
- **All Modern UI features** plus:
- **Automatic Server Selection**: Tests all servers and selects the best one based on ping
- **Server Comparison**: Visual server list with ping times
- **Best Server Highlighting**: Automatically highlights the optimal server
- **Manual Override**: Still allows manual server selection

### Key UI Elements

| Element | Description |
|---------|-------------|
| Start/Stop Button | Gradient button that changes to red during tests |
| Download Card | Shows download speed with blue progress bar |
| Upload Card | Shows upload speed with yellow progress bar |
| Ping Card | Shows ping latency with blue progress bar |
| Jitter Card | Shows jitter with red progress bar |
| Client Info | Displays user's IP address |
| Status Messages | Real-time test status updates |

## 🎨 Customization

### Styling
The UI uses CSS custom properties for easy theming:
```css
/* Primary gradient colors */
--primary-start: #667eea;
--primary-end: #764ba2;

/* Test-specific colors */
--download-color: #4fd1c5;
--upload-color: #fbbc04;
--ping-color: #4299e1;
--jitter-color: #f56565;
```

### Adding Features
- **Telemetry**: Enable by setting `telemetry_level` parameter
- **Custom Settings**: Use `speedtest.setParameter()` for configuration
- **Additional Metrics**: Access raw data in `onupdate` callback

## 🔧 Technical Details

### Integration Points

The UI connects to LibreSpeed through these key functions:

```javascript
// Initialize speedtest
speedtest = new Speedtest();
speedtest.setParameter("telemetry_level", "basic");

// Set up callbacks
speedtest.onupdate = function(data) {
    // Update UI with live data
    updateSpeedDisplay(data.dlStatus);
    updateProgressBars(data.dlProgress);
};

speedtest.onend = function(aborted) {
    // Handle test completion
    showResults();
};
```

### Test States

- `-1`: Not started
- `0`: Starting
- `1`: Download test
- `2`: Ping + Jitter test
- `3`: Upload test
- `4`: Finished
- `5`: Aborted

### Data Format

Speed values are in Mbit/s, ping values are in milliseconds:
```javascript
{
    dlStatus: "45.23",    // Download speed
    ulStatus: "12.45",    // Upload speed
    pingStatus: "15",     // Ping time
    jitterStatus: "2",    // Jitter
    dlProgress: 0.75,     // Download progress (0-1)
    ulProgress: 0.0,      // Upload progress (0-1)
    pingProgress: 0.5,    // Ping progress (0-1)
    testState: 1,         // Current test state
    clientIp: "1.2.3.4"   // Client IP
}
```

## 📱 Browser Support

- **Modern Browsers**: Chrome 60+, Firefox 55+, Safari 11+, Edge 79+
- **Mobile Browsers**: iOS Safari 11+, Chrome Mobile 60+
- **Requirements**: Web Workers support, ES6+ support

## 🔒 Security

- **HTTPS Recommended**: For accurate results and security
- **CORS Support**: Backend files include CORS headers
- **No External Dependencies**: All resources are self-hosted
- **No Data Collection**: UI doesn't collect or store user data

## 🐛 Troubleshooting

### Common Issues

1. **Test won't start**: Check server configuration and CORS settings
2. **Slow results**: Verify PHP configuration and server resources
3. **UI not updating**: Check browser console for JavaScript errors
4. **Server selection fails**: Verify `servers.json` format and accessibility

### Debug Mode
Enable debug logging:
```javascript
speedtest.setParameter("telemetry_level", "3");
```

Check browser console for detailed test information.

## 📚 Additional Resources

- **Complete Documentation**: See `INTEGRATION_GUIDE.md` for detailed setup and hosting instructions
- **LibreSpeed Official**: https://github.com/librespeed/speedtest
- **Backend Configuration**: Refer to LibreSpeed documentation for advanced backend settings

## 📄 License

This UI integration follows the same license as LibreSpeed (GNU LGPLv3). The LibreSpeed engine remains unchanged and is property of its respective authors.