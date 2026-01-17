<?php

namespace App\Exports;

use App\Models\Order;
use Maatwebsite\Excel\Concerns\FromCollection;
use Maatwebsite\Excel\Concerns\WithHeadings;
use Maatwebsite\Excel\Concerns\WithTitle;
use Maatwebsite\Excel\Concerns\WithColumnWidths;
use Maatwebsite\Excel\Concerns\WithStyles;
use PhpOffice\PhpSpreadsheet\Worksheet\Worksheet;
use PhpOffice\PhpSpreadsheet\Style\Alignment;
use PhpOffice\PhpSpreadsheet\Style\Fill;

class OrdersSheet implements FromCollection, WithHeadings, WithTitle, WithColumnWidths, WithStyles
{
    /**
     * @return \Illuminate\Support\Collection
     */
    public function collection()
    {
        return Order::with('orderItems.equipment')
            ->where('status', 'completed')
            ->latest('order_date')
            ->get()
            ->map(function ($order) {
                // Формируем список позиций
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
    }

    /**
     * @return array
     */
    public function headings(): array
    {
        return [
            'ID',
            'Дата заказа',
            'Номер машины',
            'Статус',
            'Парный экипаж',
            'Позиции',
        ];
    }

    /**
     * @return string
     */
    public function title(): string
    {
        return 'Заказы';
    }

    /**
     * @return array
     */
    public function columnWidths(): array
    {
        return [
            'A' => 10,
            'B' => 20,
            'C' => 20,
            'D' => 15,
            'E' => 18,
            'F' => 60,
        ];
    }

    /**
     * @param Worksheet $sheet
     * @return array
     */
    public function styles(Worksheet $sheet)
    {
        return [
            1 => [
                'font' => ['bold' => true, 'size' => 12],
                'fill' => [
                    'fillType' => Fill::FILL_SOLID,
                    'startColor' => ['rgb' => 'E0E0E0'],
                ],
                'alignment' => [
                    'horizontal' => Alignment::HORIZONTAL_CENTER,
                    'vertical' => Alignment::VERTICAL_CENTER,
                ],
            ],
        ];
    }
}
