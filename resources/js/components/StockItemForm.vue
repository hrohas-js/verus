<template>
  <v-container class="pa-4" fluid>
    <v-row justify="center">
      <v-col cols="12" sm="10" md="8" lg="6">
        <v-card elevation="2">
          <v-card-title class="text-h6 text-md-h5">
            {{ isEdit ? 'Редактировать товар' : 'Добавить товар' }}
          </v-card-title>
          <v-divider />
          <v-card-text>
            <form @submit.prevent="onSubmit" aria-label="Форма товара">
              <v-row class="g-4" dense>
                <v-col cols="12">
                  <v-text-field
                    v-model.trim="title"
                    label="Название"
                    :aria-label="'Название товара'"
                    variant="outlined"
                    color="primary"
                    required
                    autocomplete="off"
                    :hint="'Например: Домкрат'"
                    persistent-hint
                  />
                </v-col>

                <v-col cols="12" sm="6">
                  <v-text-field
                    v-model.number="quantity"
                    label="Количество"
                    :aria-label="'Количество на складе'"
                    type="number"
                    variant="outlined"
                    color="primary"
                    min="0"
                    required
                    inputmode="numeric"
                  />
                </v-col>

                <v-col cols="12" sm="6">
                  <v-text-field
                    v-model.trim="image"
                    label="Иконка (эмоджи)"
                    :aria-label="'Эмоджи иконка товара'"
                    variant="outlined"
                    color="primary"
                    required
                    :hint="'Например: 🔧'"
                    persistent-hint
                  />
                </v-col>
              </v-row>

              <v-row class="mt-4" justify="end" align="center" no-gutters>
                <v-col class="d-flex ga-2" cols="12" sm="auto">
                  <v-btn
                    type="button"
                    variant="text"
                    color="secondary"
                    @click="goBack"
                    v-ripple
                    :aria-label="'Отмена и вернуться назад'"
                  >
                    Отмена
                  </v-btn>

                  <v-btn
                    type="submit"
                    color="primary"
                    variant="flat"
                    v-ripple
                    :aria-label="isEdit ? 'Сохранить изменения' : 'Добавить товар'"
                    :disabled="isSubmitDisabled"
                    :loading="stock.loading"
                  >
                    {{ isEdit ? 'Сохранить' : 'Добавить' }}
                  </v-btn>
                </v-col>
              </v-row>
            </form>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>

<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { useStockStore } from '@/stores/stock'

const route = useRoute()
const router = useRouter()
const stock = useStockStore()
const user = useUserStore()

const isEdit = computed(() => route.params.id !== 'new' && !!route.params.id)

const title = ref('')
const quantity = ref<number>(0)
const image = ref('')

onMounted(async () => {
  if (isEdit.value) {
    const id = Number(route.params.id)
    try {
      const item = await stock.getItem(id)
      if (item) {
        title.value = item.title
        quantity.value = item.quantity
        image.value = item.image
      }
    } catch (error) {
      console.error('Failed to load item for editing:', error)
      // Redirect back if item not found
      goBack()
    }
  }
})

const goBack = () => {
  const roleParam = user.isWarehouse ? 'admin' : 'mech'
  router.push({ name: 'catalog', params: { role: roleParam } })
}

const isSubmitDisabled = computed(() => {
  const hasTitle = title.value.trim().length > 0
  const qty = Number(quantity.value) || 0
  const hasImage = image.value.trim().length > 0
  return !(hasTitle && qty >= 0 && hasImage) || stock.loading
})

const onSubmit = async () => {
  const payload = {
    title: title.value,
    quantity: Number(quantity.value) || 0,
    image: image.value || '📦',
  }

  try {
    if (isEdit.value) {
      await stock.updateItem({ id: Number(route.params.id), ...payload })
    } else {
      await stock.createItem(payload)
    }
    const roleParam = user.isWarehouse ? 'admin' : 'mech'
    router.push({ name: 'catalog', params: { role: roleParam } })
  } catch (error) {
    console.error('Failed to save item:', error)
    // You might want to show an error message to the user here
    alert('Ошибка сохранения товара. Попробуйте еще раз.')
  }
}
</script>

<style scoped>
/* Vuetify provides states and responsive spacing. Keep style minimal. */
.v-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  line-height: 1;
}
</style>
