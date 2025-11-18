<?php

header('HTTP/1.1 200 OK');
// Always allow CORS for cross-origin tests
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Content-Encoding, X-Requested-With');
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    // Preflight request
    exit;
}

header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0, s-maxage=0');
header('Cache-Control: post-check=0, pre-check=0', false);
header('Pragma: no-cache');
header('Connection: keep-alive');
