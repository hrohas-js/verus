<?php

use Illuminate\Contracts\Http\Kernel;
use Illuminate\Http\Request;

// #region agent log
$logData = [
    'sessionId' => 'debug-session',
    'runId' => 'run1',
    'hypothesisId' => 'F',
    'location' => 'public/index.php:7',
    'message' => 'Request started',
    'data' => [
        'uri' => $_SERVER['REQUEST_URI'] ?? 'unknown',
        'method' => $_SERVER['REQUEST_METHOD'] ?? 'unknown',
        'timestamp' => microtime(true)
    ],
    'timestamp' => (int)(microtime(true) * 1000)
];
file_put_contents('/Users/a1111/Desktop/verus/.cursor/debug.log', json_encode($logData) . "\n", FILE_APPEND);
// #endregion

define('LARAVEL_START', microtime(true));

/*
|--------------------------------------------------------------------------
| Check If The Application Is Under Maintenance
|--------------------------------------------------------------------------
|
| If the application is in maintenance / demo mode via the "down" command
| we will load this file so that any pre-rendered content can be shown
| instead of starting the framework, which could cause an exception.
|
*/

if (file_exists($maintenance = __DIR__.'/../storage/framework/maintenance.php')) {
    require $maintenance;
}

/*
|--------------------------------------------------------------------------
| Register The Auto Loader
|--------------------------------------------------------------------------
|
| Composer provides a convenient, automatically generated class loader for
| this application. We just need to utilize it! We'll simply require it
| into the script here so we don't need to manually load our classes.
|
*/

require __DIR__.'/../vendor/autoload.php';

// #region agent log
$logData = [
    'sessionId' => 'debug-session',
    'runId' => 'run1',
    'hypothesisId' => 'F',
    'location' => 'public/index.php:35',
    'message' => 'Autoload loaded',
    'data' => ['vendor_exists' => file_exists(__DIR__.'/../vendor/autoload.php')],
    'timestamp' => (int)(microtime(true) * 1000)
];
file_put_contents('/Users/a1111/Desktop/verus/.cursor/debug.log', json_encode($logData) . "\n", FILE_APPEND);
// #endregion

/*
|--------------------------------------------------------------------------
| Run The Application
|--------------------------------------------------------------------------
|
| Once we have the application, we can handle the incoming request using
| the application's HTTP kernel. Then, we will send the response back
| to this client's browser, allowing them to enjoy our application.
|
*/

// #region agent log
$envFile = __DIR__.'/../.env';
$envExists = file_exists($envFile);
$appKey = $_ENV['APP_KEY'] ?? getenv('APP_KEY') ?? 'NOT_SET';
$dbPath = $_ENV['DB_DATABASE'] ?? getenv('DB_DATABASE') ?? 'NOT_SET';
$dbExists = $dbPath !== 'NOT_SET' && file_exists($dbPath);
$storageWritable = is_writable(__DIR__.'/../storage');
$bootstrapWritable = is_writable(__DIR__.'/../bootstrap/cache');
$logData = [
    'sessionId' => 'debug-session',
    'runId' => 'run1',
    'hypothesisId' => 'A,B,C,E',
    'location' => 'public/index.php:47',
    'message' => 'Environment check before bootstrap',
    'data' => [
        'env_exists' => $envExists,
        'app_key_set' => $appKey !== 'NOT_SET' && !empty($appKey),
        'app_key_length' => strlen($appKey),
        'db_path' => $dbPath,
        'db_exists' => $dbExists,
        'storage_writable' => $storageWritable,
        'bootstrap_writable' => $bootstrapWritable
    ],
    'timestamp' => (int)(microtime(true) * 1000)
];
file_put_contents('/Users/a1111/Desktop/verus/.cursor/debug.log', json_encode($logData) . "\n", FILE_APPEND);
// #endregion

$app = require_once __DIR__.'/../bootstrap/app.php';

// #region agent log
$logData = [
    'sessionId' => 'debug-session',
    'runId' => 'run1',
    'hypothesisId' => 'F',
    'location' => 'public/index.php:75',
    'message' => 'App bootstrapped',
    'data' => ['app_class' => get_class($app)],
    'timestamp' => (int)(microtime(true) * 1000)
];
file_put_contents('/Users/a1111/Desktop/verus/.cursor/debug.log', json_encode($logData) . "\n", FILE_APPEND);
// #endregion

try {
    $kernel = $app->make(Kernel::class);
    
    // #region agent log
    $logData = [
        'sessionId' => 'debug-session',
        'runId' => 'run1',
        'hypothesisId' => 'F,G',
        'location' => 'public/index.php:85',
        'message' => 'Kernel created',
        'data' => ['kernel_class' => get_class($kernel)],
        'timestamp' => (int)(microtime(true) * 1000)
    ];
    file_put_contents('/Users/a1111/Desktop/verus/.cursor/debug.log', json_encode($logData) . "\n", FILE_APPEND);
    // #endregion
    
    $request = Request::capture();
    
    // #region agent log
    $logData = [
        'sessionId' => 'debug-session',
        'runId' => 'run1',
        'hypothesisId' => 'G',
        'location' => 'public/index.php:95',
        'message' => 'Request captured',
        'data' => [
            'uri' => $request->getRequestUri(),
            'method' => $request->getMethod()
        ],
        'timestamp' => (int)(microtime(true) * 1000)
    ];
    file_put_contents('/Users/a1111/Desktop/verus/.cursor/debug.log', json_encode($logData) . "\n", FILE_APPEND);
    // #endregion
    
    $response = $kernel->handle($request);
    
    // #region agent log
    $logData = [
        'sessionId' => 'debug-session',
        'runId' => 'run1',
        'hypothesisId' => 'G',
        'location' => 'public/index.php:108',
        'message' => 'Response generated',
        'data' => ['status_code' => $response->getStatusCode()],
        'timestamp' => (int)(microtime(true) * 1000)
    ];
    file_put_contents('/Users/a1111/Desktop/verus/.cursor/debug.log', json_encode($logData) . "\n", FILE_APPEND);
    // #endregion
    
    $response->send();
    $kernel->terminate($request, $response);
} catch (Throwable $e) {
    // #region agent log
    $logData = [
        'sessionId' => 'debug-session',
        'runId' => 'run1',
        'hypothesisId' => 'A,B,C,D,E,F,G',
        'location' => 'public/index.php:120',
        'message' => 'Exception caught',
        'data' => [
            'exception_class' => get_class($e),
            'message' => $e->getMessage(),
            'file' => $e->getFile(),
            'line' => $e->getLine(),
            'trace' => substr($e->getTraceAsString(), 0, 500)
        ],
        'timestamp' => (int)(microtime(true) * 1000)
    ];
    file_put_contents('/Users/a1111/Desktop/verus/.cursor/debug.log', json_encode($logData) . "\n", FILE_APPEND);
    // #endregion
    
    throw $e;
}
