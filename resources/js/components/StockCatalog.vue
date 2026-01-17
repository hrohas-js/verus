<template>
  <v-container class="catalog-container" fluid>
    <div class="header">
      <h1>Складской учет</h1>
      <div class="header-buttons">
        <v-btn
          v-if="isAdminPath"
          color="primary"
          variant="flat"
          @click="goToRoot"
          v-ripple
          aria-label="Назад к выдаче"
        >
          Назад к выдаче
        </v-btn>
        <template v-else>
          <v-btn
            color="primary"
            variant="flat"
            @click="goToReport"
            v-ripple
            aria-label="Получить отчет"
            class="report-btn"
          >
            ПОЛУЧИТЬ ОТЧЕТ
          </v-btn>
          <v-btn
            color="primary"
            variant="flat"
            @click="goToAdmin"
            v-ripple
            aria-label="Редактировать остатки"
          >
            Редактировать остатки
          </v-btn>
        </template>
      </div>
    </div>

    <!-- Loading and Error States -->
    <v-alert v-if="error" type="error" class="mb-4" dismissible @click:close="clearError">
      {{ error }}
    </v-alert>

    <div v-if="loading && stockItems.length === 0" class="text-center pa-8">
      <v-progress-circular indeterminate color="primary" size="64"></v-progress-circular>
      <p class="mt-4">Загрузка данных...</p>
    </div>

    <div class="catalog-grid" v-else>
      <div v-for="item in stockItems" :key="item.id" class="catalog-item">
        <div class="item-image">
          <img 
            v-if="item.image && (item.image.startsWith('http') || item.image.startsWith('/'))" 
            :src="item.image" 
            :alt="item.title"
            class="item-image-icon"
          />
          <span v-else class="item-emoji">{{ item.image || '📦' }}</span>
          <div v-if="isItemSelected(item.id)" class="quantity-badge">
            {{ getSelectedQuantity(item.id) }}
          </div>
        </div>

        <div class="item-info">
          <h3 class="item-title">{{ item.title }}</h3>
          <div class="item-stock">
            <template v-if="userStore.isWarehouse && editingId === item.id">
              <input class="qty-input" type="number" min="0" v-model.number="tempQuantity" />
              <button class="mini-btn save" @click="saveQuantity(item)">Сохранить</button>
              <button class="mini-btn cancel" @click="cancelEdit">Отмена</button>
            </template>
            <template v-else>
              В наличии: {{ item.quantity }}
              <button v-if="userStore.isWarehouse" class="mini-btn edit" @click="startEdit(item)">
                Изм.
              </button>
            </template>
          </div>
        </div>

        <div
          class="item-controls split-controls"
          :class="{ 'is-selected': isItemSelected(item.id) }"
        >
          <v-btn
            color="error"
            variant="flat"
            size="small"
            class="control-btn control-part left"
            :disabled="getSelectedQuantity(item.id) === 0"
            @click="removeItem(item.id)"
            v-ripple
            aria-label="Уменьшить количество"
          >
            −
          </v-btn>

          <v-btn
            color="primary"
            variant="flat"
            size="small"
            class="control-btn control-part right"
            :disabled="
              isItemSelected(item.id)
                ? getSelectedQuantity(item.id) >= item.quantity
                : item.quantity === 0
            "
            @click="addItem(item.id)"
            v-ripple
            aria-label="Добавить / увеличить"
          >
            +
          </v-btn>
        </div>
      </div>
    </div>

    <div v-if="totalOrderItems > 0" class="order-footer">
      <v-btn color="primary" variant="flat" class="view-order-btn" @click="goToOrder" v-ripple>
        Смотреть заказ ({{ totalOrderItems }})
      </v-btn>
    </div>
  </v-container>
</template>

<script setup lang="ts">
import { storeToRefs } from 'pinia'
import { useStockStore } from '@/stores/stock'
import { useRoute, useRouter } from 'vue-router'
import { ref, watchEffect, computed } from 'vue'
import { useUserStore } from '@/stores/user'

const stockStore = useStockStore()
const router = useRouter()
const route = useRoute()
const userStore = useUserStore()

const { stockItems, totalOrderItems, loading, error } = storeToRefs(stockStore)
const { addItem, removeItem, getSelectedQuantity, isItemSelected, updateItem, clearError } = stockStore

const goToOrder = () => {
  router.push('/order')
}

const goToAdmin = () => {
  router.push({ name: 'catalog', params: { role: 'admin' } })
}

const goToRoot = () => {
  router.push('/')
}

const goToReport = () => {
  router.push({ name: 'report' })
}

const isAdminPath = computed(() => route.path.startsWith('/admin') || route.name === 'admin')

const editingId = ref<number | null>(null)
const tempQuantity = ref<number>(0)

// Keep user store role in sync when entering directly
watchEffect(() => {
  if (route.name === 'catalog' && typeof route.params.role === 'string') {
    const param = route.params.role as 'admin' | 'mech'
    const mapped = param === 'admin' ? 'warehouse' : 'mechanic'
    if (userStore.role !== mapped) {
      userStore.setRole(mapped)
    }
  }
})

const startEdit = (item: { id: number; quantity: number }) => {
  editingId.value = item.id
  tempQuantity.value = item.quantity
}

const cancelEdit = () => {
  editingId.value = null
}

const saveQuantity = async (item: { id: number; title: string; image: string }) => {
  const qty = Math.max(0, Number(tempQuantity.value) || 0)
  try {
    await updateItem({ id: item.id, title: item.title, image: item.image, quantity: qty })
    editingId.value = null
  } catch (error) {
    console.error('Failed to update quantity:', error)
    alert('Ошибка обновления количества. Попробуйте еще раз.')
  }
}
</script>

<style scoped>
.catalog-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
  min-height: 100vh;
}

.header {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 30px;
}

.header h1 {
  margin: 0;
  text-align: center;
  flex: 0 1 auto;
}

.header-buttons {
  position: absolute;
  right: 0;
  display: flex;
  gap: 10px;
  align-items: center;
}

.report-btn {
  text-transform: uppercase;
  font-weight: 600;
  letter-spacing: 0.5px;
}

.item-stock {
  display: flex;
  align-items: center;
  gap: 8px;
  justify-content: center;
}

.qty-input {
  width: 90px;
  padding: 6px 8px;
  border: 2px solid #ddd;
  border-radius: 6px;
  font-size: 0.95rem;
}

.mini-btn {
  border: none;
  border-radius: 6px;
  padding: 6px 10px;
  font-size: 0.85rem;
  cursor: pointer;
}

.mini-btn.edit {
  background: #1976d2;
  color: #fff;
}
.mini-btn.edit:hover {
  background: #1565c0;
}
.mini-btn.save {
  background: #4caf50;
  color: #fff;
}
.mini-btn.save:hover {
  background: #45a049;
}
.mini-btn.cancel {
  background: #eee;
  color: #333;
}
.mini-btn.cancel:hover {
  background: #e0e0e0;
}

.header h1 {
  color: #333;
  font-size: 2rem;
  margin: 0;
}

.edit-stock-btn {
  background: #1976d2;
  color: #fff;
  border: none;
  border-radius: 8px;
  padding: 10px 14px;
  font-size: 0.95rem;
  cursor: pointer;
}

.edit-stock-btn:hover {
  background: #1565c0;
}

.catalog-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 20px;
  margin-bottom: 30px;
}

.catalog-item {
  background: white;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  transition: transform 0.2s ease;
}

.catalog-item:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.15);
}

.item-image {
  position: relative;
  margin-bottom: 15px;
}

.item-emoji {
  font-size: 3rem;
  display: block;
}

.item-image-icon {
  width: 64px;
  height: 64px;
  object-fit: contain;
  display: block;
}

.quantity-badge {
  position: absolute;
  top: -8px;
  right: -8px;
  background: #4caf50;
  color: white;
  border-radius: 50%;
  width: 24px;
  height: 24px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.8rem;
  font-weight: bold;
}

.item-info {
  margin-bottom: 15px;
}

.item-title {
  font-size: 1.2rem;
  color: #333;
  margin: 0 0 8px 0;
  font-weight: 600;
}

.item-stock {
  color: #666;
  margin: 0;
  font-size: 0.9rem;
  display: flex;
  align-items: center;
  gap: 8px;
  justify-content: center;
  text-align: center;
}

.item-controls {
  display: flex;
  gap: 10px;
  align-items: center;
}

/* Split animation: single button morphs into two */
/* Morph animation: one button splits into two */
.split-controls {
  position: relative;
  width: 100px;
  height: 40px;
}
.split-controls .control-part {
  position: absolute;
  top: 0;
  height: 40px;
  width: 100px;
  transition: all 180ms ease;
}
.split-controls .control-part.left {
  transform-origin: right center;
  transform: scaleX(0);
  opacity: 0;
}
.split-controls .control-part.right {
  left: 0;
}
.split-controls.is-selected .control-part.left {
  width: 48px;
  left: 0;
  transform: scaleX(1);
  opacity: 1;
}
.split-controls.is-selected .control-part.right {
  width: 48px;
  left: 52px;
}

.control-btn {
  width: 40px;
  height: 40px;
  border: none;
  border-radius: 8px;
  font-size: 1.2rem;
  font-weight: bold;
  cursor: pointer;
  transition: all 0.2s ease;
}

.remove-btn {
  background: #f44336;
  color: white;
}

.remove-btn:hover:not(:disabled) {
  background: #d32f2f;
}

.add-btn {
  background: #4caf50;
  color: white;
}

.add-btn:hover:not(:disabled) {
  background: #45a049;
}

.add-item-btn {
  background: #4caf50;
  color: white;
  border: none;
  border-radius: 8px;
  padding: 12px 24px;
  font-size: 1.2rem;
  font-weight: bold;
  cursor: pointer;
  transition: all 0.2s ease;
  min-width: 80px;
}

.add-item-btn:hover:not(:disabled) {
  background: #45a049;
}

.control-btn:disabled,
.add-item-btn:disabled {
  background: #ccc;
  cursor: not-allowed;
}

.order-footer {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  background: white;
  padding: 20px;
  box-shadow: 0 -2px 8px rgba(0, 0, 0, 0.1);
  text-align: center;
}

.view-order-btn {
  background: #4caf50;
  color: white;
  border: none;
  border-radius: 8px;
  padding: 16px 32px;
  font-size: 1.1rem;
  font-weight: bold;
  cursor: pointer;
  transition: all 0.2s ease;
  width: 100%;
  max-width: 400px;
}

/* Ensure Vuetify buttons' content is vertically centered with our legacy classes */
.v-btn.control-btn,
.v-btn.add-item-btn,
.v-btn.view-order-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  line-height: 1;
}

.view-order-btn:hover {
  background: #45a049;
}

@media (max-width: 768px) {
  .catalog-grid {
    grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
    gap: 15px;
  }

  .catalog-item {
    padding: 15px;
  }

  .item-emoji {
    font-size: 2.5rem;
  }
}
</style>
