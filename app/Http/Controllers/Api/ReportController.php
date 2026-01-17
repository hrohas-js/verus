<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Exports\StockReportExport;
use App\Models\Equipment;
use App\Models\Order;
use Illuminate\Http\JsonResponse;
use Maatwebsite\Excel\Facades\Excel;
use Symfony\Component\HttpFoundation\BinaryFileResponse;

class ReportController extends Controller
{
    /**
     * Export stock and orders report to Excel
     */
    public function export(): BinaryFileResponse
    {
        $fileName = 'report_' . date('Y-m-d') . '.xlsx';
        
        return Excel::download(new StockReportExport(), $fileName);
    }

    /**
     * Get report data for table view
     */
    public function getData(): JsonResponse
    {
        // Get all equipment (stock)
        $stock = Equipment::orderBy('title')->get()->map(function ($item) {
            return [
                'id' => $item->id,
                'title' => $item->title,
                'quantity' => $item->quantity,
                'image' => $item->image,
            ];
        });

        // Get completed orders with relationships
        $orders = Order::with('orderItems.equipment')
            ->where('status', 'completed')
            ->latest('order_date')
            ->get()
            ->map(function ($order) {
                // Format order items as string
                $items = $order->orderItems->map(function ($orderItem) {
                    $equipment = $orderItem->equipment;
                    return $equipment ? "{$equipment->title} x{$orderItem->quantity}" : '';
                })->filter()->implode(', ');

                return [
                    'id' => $order->id,
                    'order_date' => $order->order_date ? $order->order_date->format('Y-m-d H:i:s') : '',
                    'car_number' => $order->car_number,
                    'status' => $order->status,
                    'is_pair_crew' => $order->is_pair_crew ? 'Да' : 'Нет',
                    'items' => $items,
                ];
            });

        return response()->json([
            'success' => true,
            'data' => [
                'stock' => $stock,
                'orders' => $orders,
            ],
        ]);
    }
}
