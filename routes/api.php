<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\EquipmentController;

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

// Health check endpoint for microservice
Route::get('/health', function () {
    return response()->json([
        'status' => 'healthy',
        'service' => 'verus-warehouse-api',
        'timestamp' => now()->toISOString()
    ]);
});
