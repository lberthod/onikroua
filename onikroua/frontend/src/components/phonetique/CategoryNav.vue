<script setup lang="ts">
interface Category {
  id: string
  name: string
  icon: string
  count?: number
}

interface Props {
  categories: Category[]
  activeCategory: string
}

defineProps<Props>()

const emit = defineEmits<{
  (e: 'select', categoryId: string): void
}>()
</script>

<template>
  <nav class="category-nav">
    <button 
      v-for="cat in categories"
      :key="cat.id"
      :class="['category-btn', { active: activeCategory === cat.id }]"
      @click="emit('select', cat.id)"
    >
      <span class="cat-icon">{{ cat.icon }}</span>
      <span class="cat-name">{{ cat.name }}</span>
      <span v-if="cat.count" class="cat-count">{{ cat.count }}</span>
    </button>
  </nav>
</template>

<style scoped>
.category-nav {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
  padding: 1rem;
  background: #f8f9fa;
  border-radius: 12px;
  margin-bottom: 1.5rem;
}

.category-btn {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.6rem 1rem;
  background: white;
  border: 2px solid transparent;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s;
  font-size: 0.95rem;
}

.category-btn:hover {
  border-color: #9b59b6;
}

.category-btn.active {
  background: #9b59b6;
  color: white;
  border-color: #9b59b6;
}

.cat-icon {
  font-size: 1.1rem;
}

.cat-name {
  font-weight: 500;
}

.cat-count {
  background: rgba(0, 0, 0, 0.1);
  padding: 0.1rem 0.4rem;
  border-radius: 10px;
  font-size: 0.8rem;
}

.category-btn.active .cat-count {
  background: rgba(255, 255, 255, 0.2);
}
</style>
