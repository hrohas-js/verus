<template>
  <v-container class="order-container" fluid>
    <div class="header">
      <h1>ВАШ ЗАКАЗ</h1>
      <v-btn
        variant="text"
        color="primary"
        @click="goBack"
        v-ripple
        aria-label="Редактировать заказ"
        >Редактировать</v-btn
      >
    </div>

    <!-- Error Alert -->
    <v-alert v-if="error" type="error" class="mb-4" dismissible @click:close="clearError">
      {{ error }}
    </v-alert>

    <div class="order-items">
      <div v-for="item in orderItems" :key="item.id" class="order-item">
        <div class="item-image">
          <span class="item-emoji">{{ item.image }}</span>
        </div>

        <div class="item-details">
          <h3 class="item-title">{{ item.title }}</h3>
          <p class="item-quantity">x{{ item.selectedQuantity }}</p>
          <p class="item-description">{{ getItemDescription(item.title) }}</p>
        </div>
      </div>
    </div>

    <div class="car-number-section">
      <label for="carNumber" class="car-label">Номер автомобиля:</label>
      <v-text-field
        id="carNumber"
        v-model="carNumber"
        label="Номер автомобиля"
        :aria-label="'Номер автомобиля'"
        variant="outlined"
        color="primary"
      />
    </div>

    <div class="order-footer">
      <v-btn
        color="primary"
        variant="flat"
        class="submit-btn"
        :disabled="isSending || loading || !carNumber.trim() || orderItems.length === 0"
        :loading="isSending || loading"
        @click="submitOrder"
        v-ripple
      >
        {{ (isSending || loading) ? 'Отправка…' : 'Отправить в бота' }}
      </v-btn>
    </div>
  </v-container>
</template>

<script setup lang="ts">
import { storeToRefs } from 'pinia'
import { useStockStore } from '@/stores/stock'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { ref } from 'vue'

const stockStore = useStockStore()
const router = useRouter()
const user = useUserStore()

const { orderItems, carNumber, loading, error } = storeToRefs(stockStore)
const { processOrder, clearError } = stockStore

const goBack = () => {
  const roleParam = user.isWarehouse ? 'admin' : 'mech'
  router.push({ name: 'catalog', params: { role: roleParam } })
}

const isSending = ref(false)

const submitOrder = async () => {
  if (!carNumber.value.trim() || orderItems.value.length === 0 || isSending.value) return
  isSending.value = true

  const BOT_TOKEN = import.meta.env.VITE_TELEGRAM_BOT_TOKEN || '8367250027:AAGtcYqEkciUfHgMZab6Y-zviG63KaI9UPc'
  const CHAT_ID = import.meta.env.VITE_TELEGRAM_CHAT_ID || '-1002982093895'

  const header = `Выдача комплектующих`
  const carLine = `Авто: ${carNumber.value.trim()}`
  const itemsLines = orderItems.value
    .map((i) => `• ${i.title} — ${i.selectedQuantity} шт.`)
    .join('\n')
  const text = `${header}\n${carLine}\n\nПозиции:\n${itemsLines}`

  try {
    const resp = await fetch(`https://api.telegram.org/bot${BOT_TOKEN}/sendMessage`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ chat_id: CHAT_ID, text }),
    })

    if (!resp.ok) {
      throw new Error(`Telegram API error: ${resp.status}`)
    }

    await processOrder()
    // After processing, return to catalog
    const roleParam = user.isWarehouse ? 'admin' : 'mech'
    router.push({ name: 'catalog', params: { role: roleParam } })
  } catch (e) {
    console.error(e)
    alert('Не удалось отправить сообщение в Telegram. Попробуйте еще раз.')
  } finally {
    isSending.value = false
  }
}

const getItemDescription = (title: string): string => {
  const descriptions: Record<string, string> = {
    Ремни: 'Крепежные элементы',
    'Торс 36 м': 'Измерительный инструмент',
    'Трос 40м': 'Тяговый трос 40 метров',
    'Трос 44м': 'Тяговый трос 44 метра',
    'Трос 46м': 'Тяговый трос 46 метров',
    Аптечка: 'Медицинские принадлежности',
    'Знак аварийной остановки': 'Предупреждающий знак',
    Манометр: 'Измерительный прибор',
    Огнетушитель: 'Средство пожаротушения',
    Домкрат: 'Подъемное устройство',
    Жилет: 'Средство защиты',
    'Шланг подкачки': 'Воздушный шланг',
    'Перекидка воздух': 'Воздушная перекидка',
    'Перекидка (15-15)': 'Перекидка 15-15 мм',
    'Перекидка (7-7)': 'Перекидка 7-7 мм',
    'Перекидка (15-7-7)': 'Перекидка 15-7-7 мм',
  }
  return descriptions[title] || 'Складской товар'
}
</script>

<script lang="ts">
export default {}
</script>

<style scoped>
.order-container {
  max-width: 800px;
  margin: 0 auto;
  padding: 20px;
  min-height: 100vh;
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
  padding-bottom: 15px;
  border-bottom: 1px solid #ddd;
}

.header h1 {
  color: #333;
  font-size: 1.8rem;
  margin: 0;
  font-weight: bold;
}

.edit-btn {
  background: none;
  border: none;
  color: #4caf50;
  font-size: 1rem;
  cursor: pointer;
  text-decoration: underline;
}

.edit-btn:hover {
  color: #45a049;
}

.order-items {
  margin-bottom: 30px;
}

.order-item {
  display: flex;
  align-items: center;
  background: white;
  border-radius: 12px;
  padding: 20px;
  margin-bottom: 15px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.item-image {
  margin-right: 15px;
}

.item-emoji {
  font-size: 2.5rem;
  display: block;
}

.item-details {
  flex: 1;
  text-align: left;
}

.item-title {
  font-size: 1.2rem;
  color: #333;
  margin: 0 0 5px 0;
  font-weight: 600;
}

.item-quantity {
  color: #4caf50;
  font-weight: bold;
  margin: 0 0 5px 0;
  font-size: 1rem;
}

.item-description {
  color: #666;
  margin: 0;
  font-size: 0.9rem;
}

.car-number-section {
  background: white;
  border-radius: 12px;
  padding: 20px;
  margin-bottom: 30px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.car-label {
  display: block;
  font-weight: bold;
  color: #333;
  margin-bottom: 10px;
  font-size: 1.1rem;
}

.car-input {
  width: 100%;
  padding: 12px;
  border: 2px solid #ddd;
  border-radius: 8px;
  font-size: 1rem;
  transition: border-color 0.2s ease;
}

.car-input:focus {
  outline: none;
  border-color: #4caf50;
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

.submit-btn {
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

.submit-btn:hover:not(:disabled) {
  background: #45a049;
}

.submit-btn:disabled {
  background: #ccc;
  cursor: not-allowed;
}

/* Ensure Vuetify buttons' content is vertically centered with our legacy classes */
.v-btn.submit-btn,
.header :deep(.v-btn) {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  line-height: 1;
}

@media (max-width: 768px) {
  .order-container {
    padding: 15px;
  }

  .order-item {
    padding: 15px;
  }

  .item-emoji {
    font-size: 2rem;
  }

  .header h1 {
    font-size: 1.5rem;
  }
}
</style>
