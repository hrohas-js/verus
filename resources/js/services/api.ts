import type { StockItem } from '@/types/StockItem'

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || '/api'

export interface ApiResponse<T> {
  data: T
  success: boolean
  message?: string
}

export class ApiError extends Error {
  constructor(
    message: string,
    public status: number,
    public response?: Response
  ) {
    super(message)
    this.name = 'ApiError'
  }
}

class ApiService {
  private async request<T>(
    endpoint: string,
    options: RequestInit = {}
  ): Promise<T> {
    const url = `${API_BASE_URL}${endpoint}`

    const config: RequestInit = {
      headers: {
        'Content-Type': 'application/json',
        ...options.headers,
      },
      ...options,
    }

    try {
      const response = await fetch(url, config)

      if (!response.ok) {
        let errorMessage = `HTTP ${response.status}: ${response.statusText}`
        try {
          const errorData = await response.json()
          errorMessage = errorData.message || errorMessage
        } catch {
          // If response is not JSON, use default error message
        }
        throw new ApiError(errorMessage, response.status, response)
      }

      const data = await response.json()
      return data
    } catch (error) {
      if (error instanceof ApiError) {
        throw error
      }
      // Network or other errors
      throw new ApiError(
        error instanceof Error ? error.message : 'Network error occurred',
        0
      )
    }
  }

  // Health check
  async healthCheck(): Promise<{ status: string }> {
    return this.request<{ status: string }>('/health')
  }

  // Get all equipment
  async getAllEquipment(): Promise<StockItem[]> {
    const response = await this.request<ApiResponse<StockItem[]>>('/equipment')
    return response.data
  }

  // Get equipment by ID
  async getEquipmentById(id: number): Promise<StockItem> {
    const response = await this.request<ApiResponse<StockItem>>(`/equipment/${id}`)
    return response.data
  }

  // Create new equipment
  async createEquipment(data: Omit<StockItem, 'id' | 'created_at' | 'updated_at'>): Promise<StockItem> {
    const response = await this.request<ApiResponse<StockItem>>('/equipment', {
      method: 'POST',
      body: JSON.stringify(data),
    })
    return response.data
  }

  // Update equipment
  async updateEquipment(id: number, data: Partial<Omit<StockItem, 'id' | 'created_at' | 'updated_at'>>): Promise<StockItem> {
    const response = await this.request<ApiResponse<StockItem>>(`/equipment/${id}`, {
      method: 'PUT',
      body: JSON.stringify(data),
    })
    return response.data
  }

  // Update equipment quantity
  async updateEquipmentQuantity(id: number, quantity: number): Promise<StockItem> {
    const response = await this.request<ApiResponse<StockItem>>(`/equipment/${id}/quantity`, {
      method: 'PATCH',
      body: JSON.stringify({ quantity }),
    })
    return response.data
  }

  // Delete equipment
  async deleteEquipment(id: number): Promise<void> {
    await this.request<void>(`/equipment/${id}`, {
      method: 'DELETE',
    })
  }

  // Batch update quantities (for processing orders)
  async batchUpdateQuantities(updates: { id: number; quantity: number }[]): Promise<StockItem[]> {
    // Since there's no batch endpoint, we'll make multiple requests
    const promises = updates.map(({ id, quantity }) =>
      this.updateEquipmentQuantity(id, quantity)
    )
    return Promise.all(promises)
  }

  // Orders API methods
  async createOrder(data: {
    car_number: string
    order_date?: string
    status?: string
    notes?: string
    is_pair_crew?: boolean
    items: Array<{ equipment_id: number; quantity: number }>
  }): Promise<any> {
    const response = await this.request<ApiResponse<any>>('/orders', {
      method: 'POST',
      body: JSON.stringify(data),
    })
    return response.data
  }

  async getAllOrders(): Promise<any[]> {
    const response = await this.request<ApiResponse<any[]>>('/orders')
    return response.data
  }

  async getOrderById(id: number): Promise<any> {
    const response = await this.request<ApiResponse<any>>(`/orders/${id}`)
    return response.data
  }

  // Download Excel report
  async downloadReport(): Promise<void> {
    const url = `${API_BASE_URL}/reports/excel`
    
    try {
      const response = await fetch(url, {
        method: 'GET',
        headers: {
          'Accept': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        },
      })

      if (!response.ok) {
        throw new ApiError(`HTTP ${response.status}: ${response.statusText}`, response.status, response)
      }

      const blob = await response.blob()
      const downloadUrl = window.URL.createObjectURL(blob)
      const link = document.createElement('a')
      link.href = downloadUrl
      
      // Получаем имя файла из заголовка Content-Disposition или используем дефолтное
      const contentDisposition = response.headers.get('Content-Disposition')
      let fileName = 'report_' + new Date().toISOString().split('T')[0] + '.xlsx'
      
      if (contentDisposition) {
        const fileNameMatch = contentDisposition.match(/filename[^;=\n]*=((['"]).*?\2|[^;\n]*)/)
        if (fileNameMatch && fileNameMatch[1]) {
          fileName = fileNameMatch[1].replace(/['"]/g, '')
        }
      }
      
      link.download = fileName
      document.body.appendChild(link)
      link.click()
      document.body.removeChild(link)
      window.URL.revokeObjectURL(downloadUrl)
    } catch (error) {
      if (error instanceof ApiError) {
        throw error
      }
      throw new ApiError(
        error instanceof Error ? error.message : 'Failed to download report',
        0
      )
    }
  }

  // Get report data for table view
  async getReportData(): Promise<{
    stock: Array<{
      id: number
      title: string
      quantity: number
      image: string
    }>
    orders: Array<{
      id: number
      order_date: string
      car_number: string
      status: string
      is_pair_crew: string
      items: string
    }>
  }> {
    const response = await this.request<ApiResponse<{
      stock: Array<{
        id: number
        title: string
        quantity: number
        image: string
      }>
      orders: Array<{
        id: number
        order_date: string
        car_number: string
        status: string
        is_pair_crew: string
        items: string
      }>
    }>>('/reports/data')
    return response.data
  }
}

export const apiService = new ApiService()
