<script setup lang="ts">
import { RouterView } from 'vue-router'
</script>

<template>
  <v-app>
    <RouterView v-slot="{ Component, route }">
      <transition name="route-slide-fade" mode="out-in">
        <component :is="Component" :key="route.fullPath" />
      </transition>
    </RouterView>
  </v-app>
</template>

<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family:
    -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
}

#app {
  min-height: 100vh;
}

/* Set global app background (Vuetify app root included) */
:root,
#app,
:deep(.v-application) {
  background-color: #f5f5f5;
}

/* Route transitions */
.route-slide-fade-enter-active,
.route-slide-fade-leave-active {
  transition:
    opacity 200ms ease,
    transform 200ms ease;
}
.route-slide-fade-enter-from {
  opacity: 0;
  transform: translateY(8px);
}
.route-slide-fade-leave-to {
  opacity: 0;
  transform: translateY(-8px);
}
</style>
