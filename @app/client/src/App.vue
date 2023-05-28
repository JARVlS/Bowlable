<script setup lang="ts">
// about combining <suspense> with <router-view>: https://vuejs.org/guide/built-ins/suspense.html#combining-with-other-components
</script>

<template>
  <router-view v-slot="{ Component }">
    <keep-alive>
      <suspense>
        <component :is="Component" />
        <template #fallback> Loading... </template>
      </suspense>
    </keep-alive>
  </router-view>
</template>

