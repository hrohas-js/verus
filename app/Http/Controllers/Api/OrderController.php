<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\OrderResource;
use App\Models\Order;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Validation\ValidationException;

class OrderController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(): JsonResponse
    {
        $orders = Order::with('orderItems.equipment')->latest('order_date')->get();

        return response()->json([
            'success' => true,
            'data' => OrderResource::collection($orders)
        ]);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request): JsonResponse
    {
        try {
            $validated = $request->validate([
                'car_number' => 'required|string|max:255',
                'order_date' => 'nullable|date',
                'status' => 'nullable|string|in:pending,completed,cancelled',
                'notes' => 'nullable|string',
                'is_pair_crew' => 'nullable|boolean',
                'items' => 'required|array|min:1',
                'items.*.equipment_id' => 'required|integer|exists:equipment,id',
                'items.*.quantity' => 'required|integer|min:1',
            ]);

            $order = Order::create([
                'car_number' => $validated['car_number'],
                'order_date' => $validated['order_date'] ?? now(),
                'status' => $validated['status'] ?? 'pending',
                'notes' => $validated['notes'] ?? null,
                'is_pair_crew' => $validated['is_pair_crew'] ?? false,
            ]);

            // Создаем позиции заказа
            foreach ($validated['items'] as $item) {
                $order->orderItems()->create([
                    'equipment_id' => $item['equipment_id'],
                    'quantity' => $item['quantity'],
                ]);
            }

            // Загружаем связи для ответа
            $order->load('orderItems.equipment');

            return response()->json([
                'success' => true,
                'message' => 'Order created successfully',
                'data' => new OrderResource($order)
            ], 201);
        } catch (ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $e->errors()
            ], 422);
        }
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id): JsonResponse
    {
        $order = Order::with('orderItems.equipment')->find($id);

        if (!$order) {
            return response()->json([
                'success' => false,
                'message' => 'Order not found'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => new OrderResource($order)
        ]);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id): JsonResponse
    {
        try {
            $order = Order::find($id);

            if (!$order) {
                return response()->json([
                    'success' => false,
                    'message' => 'Order not found'
                ], 404);
            }

            $validated = $request->validate([
                'car_number' => 'sometimes|string|max:255',
                'order_date' => 'sometimes|date',
                'status' => 'sometimes|string|in:pending,completed,cancelled',
                'notes' => 'nullable|string',
                'is_pair_crew' => 'nullable|boolean',
            ]);

            $order->update($validated);
            $order->load('orderItems.equipment');

            return response()->json([
                'success' => true,
                'message' => 'Order updated successfully',
                'data' => new OrderResource($order)
            ]);
        } catch (ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $e->errors()
            ], 422);
        }
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id): JsonResponse
    {
        $order = Order::find($id);

        if (!$order) {
            return response()->json([
                'success' => false,
                'message' => 'Order not found'
            ], 404);
        }

        $order->delete();

        return response()->json([
            'success' => true,
            'message' => 'Order deleted successfully'
        ]);
    }
}
