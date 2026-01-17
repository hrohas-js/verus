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
    return this.request<StockItem[]>('/equipment')
  }

  // Get equipment by ID
  async getEquipmentById(id: number): Promise<StockItem> {
    return this.request<StockItem>(`/equipment/${id}`)
  }

  // Create new equipment
  async createEquipment(data: Omit<StockItem, 'id' | 'created_at' | 'updated_at'>): Promise<StockItem> {
    return this.request<StockItem>('/equipment', {
      method: 'POST',
      body: JSON.stringify(data),
    })
  }

  // Update equipment
  async updateEquipment(id: number, data: Partial<Omit<StockItem, 'id' | 'created_at' | 'updated_at'>>): Promise<StockItem> {
    return this.request<StockItem>(`/equipment/${id}`, {
      method: 'PUT',
      body: JSON.stringify(data),
    })
  }

  // Update equipment quantity
  async updateEquipmentQuantity(id: number, quantity: number): Promise<StockItem> {
    return this.request<StockItem>(`/equipment/${id}/quantity`, {
      method: 'PATCH',
      body: JSON.stringify({ quantity }),
    })
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
}

export const apiService = new ApiService()
