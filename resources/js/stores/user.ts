import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export type UserRole = 'warehouse' | 'mechanic'

const STORAGE_KEY = 'user-role'

export const useUserStore = defineStore('user', () => {
  const initialRole = (localStorage.getItem(STORAGE_KEY) as UserRole) || 'warehouse'
  const role = ref<UserRole>(initialRole)

  const isWarehouse = computed(() => role.value === 'warehouse')
  const isMechanic = computed(() => role.value === 'mechanic')

  const setRole = (newRole: UserRole) => {
    role.value = newRole
    localStorage.setItem(STORAGE_KEY, newRole)
  }

  return { role, isWarehouse, isMechanic, setRole }
})
