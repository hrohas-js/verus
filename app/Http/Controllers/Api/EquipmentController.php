<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\EquipmentResource;
use App\Models\Equipment;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Validation\ValidationException;

class EquipmentController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(): JsonResponse
    {
        $equipment = Equipment::all();

        return response()->json([
            'success' => true,
            'data' => EquipmentResource::collection($equipment)
        ]);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request): JsonResponse
    {
        try {
            $validated = $request->validate([
                'title' => 'required|string|max:255',
                'quantity' => 'required|integer|min:0',
                'image' => 'required|string|max:255',
            ]);

            $equipment = Equipment::create($validated);

            return response()->json([
                'success' => true,
                'message' => 'Equipment created successfully',
                'data' => new EquipmentResource($equipment)
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
        $equipment = Equipment::find($id);

        if (!$equipment) {
            return response()->json([
                'success' => false,
                'message' => 'Equipment not found'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => new EquipmentResource($equipment)
        ]);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id): JsonResponse
    {
        try {
            $equipment = Equipment::find($id);

            if (!$equipment) {
                return response()->json([
                    'success' => false,
                    'message' => 'Equipment not found'
                ], 404);
            }

            $validated = $request->validate([
                'title' => 'sometimes|string|max:255',
                'quantity' => 'sometimes|integer|min:0',
                'image' => 'sometimes|string|max:255',
            ]);

            $equipment->update($validated);

            return response()->json([
                'success' => true,
                'message' => 'Equipment updated successfully',
                'data' => new EquipmentResource($equipment)
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
     * Update equipment quantity (specific method for inventory management)
     */
    public function updateQuantity(Request $request, string $id): JsonResponse
    {
        try {
            $equipment = Equipment::find($id);

            if (!$equipment) {
                return response()->json([
                    'success' => false,
                    'message' => 'Equipment not found'
                ], 404);
            }

            $validated = $request->validate([
                'quantity' => 'required|integer|min:0',
            ]);

            $equipment->update(['quantity' => $validated['quantity']]);

            return response()->json([
                'success' => true,
                'message' => 'Equipment quantity updated successfully',
                'data' => new EquipmentResource($equipment)
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
        $equipment = Equipment::find($id);

        if (!$equipment) {
            return response()->json([
                'success' => false,
                'message' => 'Equipment not found'
            ], 404);
        }

        $equipment->delete();

        return response()->json([
            'success' => true,
            'message' => 'Equipment deleted successfully'
        ]);
    }
}
