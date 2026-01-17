<?php

namespace App\Exports;

use App\Models\Equipment;
use App\Models\Order;
use Maatwebsite\Excel\Concerns\WithMultipleSheets;
use Maatwebsite\Excel\Concerns\WithTitle;

class StockReportExport implements WithMultipleSheets
{
    /**
     * @return array
     */
    public function sheets(): array
    {
        return [
            new StockSheet(),
            new OrdersSheet(),
        ];
    }
}
