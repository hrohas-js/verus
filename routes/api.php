<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\EquipmentController;
use App\Http\Controllers\Api\OrderController;
use App\Http\Controllers\Api\ReportController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

// Equipment API Routes
Route::prefix('equipment')->group(function () {
    Route::get('/', [EquipmentController::class, 'index']); // Получение всей комплектации
    Route::post('/', [EquipmentController::class, 'store']); // Добавление итема комплектации
    Route::get('/{id}', [EquipmentController::class, 'show']); // Получение конкретного итема
    Route::put('/{id}', [EquipmentController::class, 'update']); // Обновление итема
    Route::patch('/{id}/quantity', [EquipmentController::class, 'updateQuantity']); // Изменение остатков комплектации
    Route::delete('/{id}', [EquipmentController::class, 'destroy']); // Удаление итема
});

// Orders API Routes
Route::prefix('orders')->group(function () {
    Route::get('/', [OrderController::class, 'index']); // Получение всех заказов
    Route::post('/', [OrderController::class, 'store']); // Создание нового заказа
    Route::get('/{id}', [OrderController::class, 'show']); // Получение конкретного заказа
    Route::put('/{id}', [OrderController::class, 'update']); // Обновление заказа
    Route::delete('/{id}', [OrderController::class, 'destroy']); // Удаление заказа
});

// Reports API Routes
Route::prefix('reports')->group(function () {
    Route::get('/excel', [ReportController::class, 'export']); // Генерация и скачивание Excel отчета
    Route::get('/data', [ReportController::class, 'getData']); // Получение данных отчета для табличного отображения
});

// Health check endpoint for microservice
Route::get('/health', function () {
    return response()->json([
        'status' => 'healthy',
        'service' => 'verus-warehouse-api',
        'timestamp' => now()->toISOString()
    ]);
});
