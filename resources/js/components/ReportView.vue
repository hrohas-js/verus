<template>
  <v-container class="report-container" fluid>
    <div class="header">
      <v-btn
        icon
        variant="text"
        color="primary"
        @click="goBack"
        v-ripple
        aria-label="Назад"
        class="back-btn"
      >
        <v-icon>mdi-arrow-left</v-icon>
      </v-btn>
      <h1>ОТЧЕТ</h1>
      <div class="header-spacer"></div>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="text-center pa-8">
      <v-progress-circular indeterminate color="primary" size="64"></v-progress-circular>
      <p class="mt-4">Загрузка данных...</p>
    </div>

    <!-- Error State -->
    <v-alert v-if="error" type="error" class="mb-4" dismissible @click:close="clearError">
      {{ error }}
    </v-alert>

    <!-- Report Content -->
    <div v-if="!loading && !error" class="report-content">
      <!-- Stock Section -->
      <div class="report-section">
        <h2 class="section-title">Остатки товаров</h2>
        <v-data-table
          :headers="stockHeaders"
          :items="reportData.stock"
          :items-per-page="25"
          class="report-table"
          :sort-by="[{ key: 'title', order: 'asc' }]"
        >
          <template v-slot:item.image="{ item }">
            <div class="image-cell">
              <img
                v-if="item.image && (item.image.startsWith('http') || item.image.startsWith('/'))"
                :src="item.image"
                :alt="item.title"
                class="item-image-icon"
              />
              <span v-else class="item-emoji">{{ item.image || '📦' }}</span>
            </div>
          </template>
          <template v-slot:item.quantity="{ item }">
            {{ formatNumber(item.quantity) }}
          </template>
        </v-data-table>
      </div>

      <!-- Orders Section -->
      <div class="report-section">
        <h2 class="section-title">Заказы</h2>
        <v-data-table
          :headers="orderHeaders"
          :items="reportData.orders"
          :items-per-page="25"
          class="report-table"
          :sort-by="[{ key: 'order_date', order: 'desc' }]"
        >
          <template v-slot:item.order_date="{ item }">
            {{ formatDate(item.order_date) }}
          </template>
        </v-data-table>
      </div>
    </div>
  </v-container>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { apiService } from '@/services/api'
import type { ReportData } from '@/types/Report'

const router = useRouter()

const loading = ref(false)
const error = ref<string | null>(null)
const reportData = ref<ReportData>({
  stock: [],
  orders: [],
})

const stockHeaders = [
  { title: 'ID', key: 'id', sortable: true, width: '80px' },
  { title: 'Изображение', key: 'image', sortable: false, width: '100px' },
  { title: 'Название', key: 'title', sortable: true },
  { title: 'Количество', key: 'quantity', sortable: true, width: '150px' },
]

const orderHeaders = [
  { title: 'ID', key: 'id', sortable: true, width: '80px' },
  { title: 'Дата заказа', key: 'order_date', sortable: true, width: '180px' },
  { title: 'Номер машины', key: 'car_number', sortable: true, width: '150px' },
  { title: 'Статус', key: 'status', sortable: true, width: '120px' },
  { title: 'Парный экипаж', key: 'is_pair_crew', sortable: true, width: '140px' },
  { title: 'Позиции', key: 'items', sortable: false },
]

const goBack = () => {
  router.back()
}

const loadReportData = async () => {
  loading.value = true
  error.value = null
  try {
    const data = await apiService.getReportData()
    reportData.value = data
  } catch (err) {
    error.value = err instanceof Error ? err.message : 'Ошибка загрузки данных отчета'
    console.error('Failed to load report data:', err)
  } finally {
    loading.value = false
  }
}

const clearError = () => {
  error.value = null
}

const formatNumber = (num: number): string => {
  return new Intl.NumberFormat('ru-RU').format(num)
}

const formatDate = (dateString: string): string => {
  if (!dateString) return ''
  const date = new Date(dateString)
  const day = String(date.getDate()).padStart(2, '0')
  const month = String(date.getMonth() + 1).padStart(2, '0')
  const year = date.getFullYear()
  const hours = String(date.getHours()).padStart(2, '0')
  const minutes = String(date.getMinutes()).padStart(2, '0')
  return `${day}.${month}.${year} ${hours}:${minutes}`
}

onMounted(() => {
  loadReportData()
})
</script>

<style scoped>
.report-container {
  max-width: 1400px;
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
  padding-bottom: 15px;
  border-bottom: 1px solid #ddd;
}

.header h1 {
  flex: 1;
  text-align: center;
  margin: 0;
  font-size: 2rem;
  color: #333;
}

.back-btn {
  position: absolute;
  left: 0;
}

.header-spacer {
  width: 48px; /* Ширина кнопки для симметрии */
}

.report-content {
  display: flex;
  flex-direction: column;
  gap: 40px;
}

.report-section {
  background: white;
  border-radius: 12px;
  padding: 24px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.section-title {
  font-size: 1.5rem;
  color: #333;
  margin-bottom: 20px;
  font-weight: 600;
}

.report-table {
  background: white;
}

.image-cell {
  display: flex;
  align-items: center;
  justify-content: center;
}

.item-image-icon {
  width: 40px;
  height: 40px;
  object-fit: contain;
}

.item-emoji {
  font-size: 2rem;
  display: block;
}

/* Vuetify table styling overrides */
:deep(.v-data-table__thead) {
  background-color: #f5f5f5;
}

:deep(.v-data-table__thead th) {
  font-weight: 600;
  color: #333;
}

:deep(.v-data-table__tbody tr:nth-child(even)) {
  background-color: #fafafa;
}

:deep(.v-data-table__tbody tr:hover) {
  background-color: #f0f0f0;
}
</style>
