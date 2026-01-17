<?php

namespace App\Exceptions;

use Illuminate\Foundation\Exceptions\Handler as ExceptionHandler;
use Throwable;

class Handler extends ExceptionHandler
{
    /**
     * The list of the inputs that are never flashed to the session on validation exceptions.
     *
     * @var array<int, string>
     */
    protected $dontFlash = [
        'current_password',
        'password',
        'password_confirmation',
    ];

    /**
     * Register the exception handling callbacks for the application.
     */
    public function register(): void
    {
        $this->reportable(function (Throwable $e) {
            // #region agent log
            $logData = [
                'sessionId' => 'debug-session',
                'runId' => 'run1',
                'hypothesisId' => 'A,B,C,D,E,F,G',
                'location' => 'app/Exceptions/Handler.php:27',
                'message' => 'Exception reported',
                'data' => [
                    'exception_class' => get_class($e),
                    'message' => $e->getMessage(),
                    'file' => $e->getFile(),
                    'line' => $e->getLine()
                ],
                'timestamp' => (int)(microtime(true) * 1000)
            ];
            file_put_contents('/Users/a1111/Desktop/verus/.cursor/debug.log', json_encode($logData) . "\n", FILE_APPEND);
            // #endregion
        });
    }
}
