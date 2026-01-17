import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import type { StockItem, OrderItem } from '@/types/StockItem'
import { apiService, ApiError } from '@/services/api'

export const useStockStore = defineStore('stock', () => {
  const stockItems = ref<StockItem[]>([])
  const selectedItems = ref<Map<number, number>>(new Map()) // itemId -> selectedQuantity
  const carNumber = ref('')
  const isPairCrew = ref(false) // Парный экипаж
  const loading = ref(false)
  const error = ref<string | null>(null)

  // Load stock items from API
  const loadStockItems = async () => {
    loading.value = true
    error.value = null
    try {
      const items = await apiService.getAllEquipment()
      stockItems.value = items.sort((a, b) => a.title.localeCompare(b.title))
    } catch (err) {
      error.value = err instanceof ApiError ? err.message : 'Ошибка загрузки данных'
      console.error('Failed to load stock items:', err)
    } finally {
      loading.value = false
    }
  }

  // Get selected items with details
  const orderItems = computed((): OrderItem[] => {
    return Array.from(selectedItems.value.entries())
      .map(([itemId, selectedQuantity]) => {
        const item = stockItems.value.find((i) => i.id === itemId)
        if (!item) return null
        return {
          id: item.id,
          title: item.title,
          quantity: item.quantity,
          image: item.image,
          selectedQuantity,
        }
      })
      .filter((item): item is OrderItem => item !== null)
  })

  // Calculate total items in order
  const totalOrderItems = computed(() => {
    return Array.from(selectedItems.value.values()).reduce((sum, qty) => sum + qty, 0)
  })

  // Add item to selection
  const addItem = (itemId: number) => {
    const currentQuantity = selectedItems.value.get(itemId) || 0
    const stockItem = stockItems.value.find((item) => item.id === itemId)

    if (stockItem && currentQuantity < stockItem.quantity) {
      selectedItems.value.set(itemId, currentQuantity + 1)
      // Reassign to trigger reactivity for Map changes
      selectedItems.value = new Map(selectedItems.value)
    }
  }

  // Remove item from selection
  const removeItem = (itemId: number) => {
    const currentQuantity = selectedItems.value.get(itemId) || 0
    if (currentQuantity > 0) {
      const newQuantity = currentQuantity - 1
      if (newQuantity === 0) {
        selectedItems.value.delete(itemId)
      } else {
        selectedItems.value.set(itemId, newQuantity)
      }
      // Reassign to trigger reactivity for Map changes
      selectedItems.value = new Map(selectedItems.value)
    }
  }

  // Get selected quantity for an item
  const getSelectedQuantity = (itemId: number): number => {
    return selectedItems.value.get(itemId) || 0
  }

  // Check if item is selected
  const isItemSelected = (itemId: number): boolean => {
    return selectedItems.value.has(itemId) && selectedItems.value.get(itemId)! > 0
  }

  // Clear all selections
  const clearSelection = () => {
    // Replace Map instance to ensure dependents update
    selectedItems.value = new Map()
    carNumber.value = ''
    isPairCrew.value = false
  }

  // Process order and update stock
  const processOrder = async (orderCarNumber?: string, pairCrew: boolean = false) => {
    loading.value = true
    error.value = null
    try {
      const updates: { id: number; quantity: number }[] = []
      const orderItems: Array<{ equipment_id: number; quantity: number }> = []

      // Находим ID незамерзайки
      const nezamerzaykaItem = stockItems.value.find(item => 
        item.title.toLowerCase().includes('незамерзайка') || 
        item.title.toLowerCase().includes('незамерзайк')
      )

      for (const [itemId, selectedQuantity] of selectedItems.value.entries()) {
        const stockItem = stockItems.value.find((item) => item.id === itemId)
        if (stockItem) {
          let finalQuantity = selectedQuantity
          
          // Если это незамерзайка и парный экипаж, удваиваем количество
          if (nezamerzaykaItem && itemId === nezamerzaykaItem.id && pairCrew) {
            finalQuantity = selectedQuantity * 2
          }
          
          const newQuantity = stockItem.quantity - finalQuantity
          updates.push({ id: itemId, quantity: newQuantity })
          orderItems.push({ equipment_id: itemId, quantity: finalQuantity })
        }
      }

      if (updates.length > 0) {
        // Сохраняем заказ в БД, если передан номер машины
        if (orderCarNumber && orderCarNumber.trim()) {
          try {
            await apiService.createOrder({
              car_number: orderCarNumber.trim(),
              order_date: new Date().toISOString(),
              status: 'completed',
              is_pair_crew: pairCrew,
              items: orderItems,
            })
          } catch (orderErr) {
            console.error('Failed to save order to database:', orderErr)
            // Продолжаем выполнение даже если не удалось сохранить заказ
          }
        }

        // Обновляем остатки товаров
        await apiService.batchUpdateQuantities(updates)
        clearSelection()
        await loadStockItems() // Refresh stock items
      }
    } catch (err) {
      error.value = err instanceof ApiError ? err.message : 'Ошибка обработки заказа'
      console.error('Failed to process order:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  // Initialize store
  loadStockItems()

  // CRUD helpers for stock items
  const getItem = async (id: number) => {
    try {
      return await apiService.getEquipmentById(id)
    } catch (err) {
      error.value = err instanceof ApiError ? err.message : 'Ошибка получения товара'
      console.error('Failed to get item:', err)
      throw err
    }
  }

  const createItem = async (data: Omit<StockItem, 'id' | 'created_at' | 'updated_at'>) => {
    loading.value = true
    error.value = null
    try {
      const created = await apiService.createEquipment(data)
      await loadStockItems()
      return created
    } catch (err) {
      error.value = err instanceof ApiError ? err.message : 'Ошибка создания товара'
      console.error('Failed to create item:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  const updateItem = async (item: StockItem) => {
    loading.value = true
    error.value = null
    try {
      const updateData = {
        title: item.title,
        quantity: item.quantity,
        image: item.image
      }
      const updated = await apiService.updateEquipment(item.id, updateData)
      await loadStockItems()
      return updated
    } catch (err) {
      error.value = err instanceof ApiError ? err.message : 'Ошибка обновления товара'
      console.error('Failed to update item:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  const deleteItem = async (id: number) => {
    loading.value = true
    error.value = null
    try {
      await apiService.deleteEquipment(id)
      await loadStockItems()
    } catch (err) {
      error.value = err instanceof ApiError ? err.message : 'Ошибка удаления товара'
      console.error('Failed to delete item:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  // Clear error
  const clearError = () => {
    error.value = null
  }

  return {
    stockItems,
    selectedItems,
    carNumber,
    isPairCrew,
    loading,
    error,
    orderItems,
    totalOrderItems,
    loadStockItems,
    addItem,
    removeItem,
    getSelectedQuantity,
    isItemSelected,
    clearSelection,
    processOrder,
    getItem,
    createItem,
    updateItem,
    deleteItem,
    clearError,
  }
})
