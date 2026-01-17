export interface StockItem {
  id: number
  title: string
  quantity: number
  image: string
  created_at?: string
  updated_at?: string
}

export interface OrderItem {
  id: number
  title: string
  quantity: number
  image: string
  selectedQuantity: number
}
