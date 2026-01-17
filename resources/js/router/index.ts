import { createRouter, createWebHistory } from 'vue-router'
import StockCatalog from '@/components/StockCatalog.vue'
import OrderSummary from '@/components/OrderSummary.vue'
import StockItemForm from '@/components/StockItemForm.vue'
import ReportView from '@/components/ReportView.vue'
import { useUserStore } from '@/stores/user'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/:role(admin|mech)',
      name: 'catalog',
      component: StockCatalog,
    },
    {
      path: '/',
      redirect: '/mech',
    },
    {
      path: '/order',
      name: 'order',
      component: OrderSummary,
    },
    {
      path: '/report',
      name: 'report',
      component: ReportView,
    },
    {
      path: '/items/:id',
      name: 'item-form',
      component: StockItemForm,
      meta: { requiresWarehouse: true },
    },
  ],
})

router.beforeEach((to, _from, next) => {
  const user = useUserStore()
  // Sync role from route to store for catalog and related pages
  if (to.name === 'catalog' && typeof to.params.role === 'string') {
    const roleParam = to.params.role as 'admin' | 'mech'
    const mappedRole = roleParam === 'admin' ? 'warehouse' : 'mechanic'
    if (user.role !== mappedRole) {
      user.setRole(mappedRole)
    }
  }

  const requiresWarehouse = (to.meta as { requiresWarehouse?: boolean }).requiresWarehouse === true
  if (requiresWarehouse && user.role !== 'warehouse') {
    return next({ name: 'catalog', params: { role: 'mech' } })
  }
  next()
})

export default router
