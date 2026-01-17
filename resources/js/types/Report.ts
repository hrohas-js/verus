export interface StockReportItem {
  id: number
  title: string
  quantity: number
  image: string
}

export interface OrderReportItem {
  id: number
  order_date: string
  car_number: string
  status: string
  is_pair_crew: string
  items: string
}

export interface ReportData {
  stock: StockReportItem[]
  orders: OrderReportItem[]
}
