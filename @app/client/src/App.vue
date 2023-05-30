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

<style>
* {
  padding: 0;
  margin: 0;
  box-sizing: border-box;
}

body,
html,
#app {
  padding: 0.01px;
  height: 100vh;
  width: 100vw;
}
</style>
