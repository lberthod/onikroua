<script setup lang="ts">
import { ref, onMounted, onUnmounted, watch } from 'vue'

const props = withDefaults(defineProps<{
  isActive: boolean
  color?: string
}>(), {
  color: '#9b59b6'
})

const canvasRef = ref<HTMLCanvasElement | null>(null)
let animationId: number
let ctx: CanvasRenderingContext2D | null = null

// Simuler des barres audio
const bars = 20
const barWidth = 4
const gap = 2

const draw = () => {
  if (!canvasRef.value || !ctx) return

  ctx.clearRect(0, 0, canvasRef.value.width, canvasRef.value.height)
  
  if (!props.isActive) {
    // État inactif: ligne plate
    ctx.fillStyle = '#ddd'
    for (let i = 0; i < bars; i++) {
      const x = i * (barWidth + gap)
      const height = 4
      const y = (canvasRef.value.height - height) / 2
      ctx.fillStyle = '#e0e0e0'
      ctx.fillRect(x, y, barWidth, height)
    }
    return
  }

  // Animation active
  const time = Date.now() / 100
  ctx.fillStyle = props.color
  
  for (let i = 0; i < bars; i++) {
    const x = i * (barWidth + gap)
    // Hauteur basée sur une onde sinusoïdale + bruit pour effet naturel
    const height = 10 + Math.abs(Math.sin(time + i * 0.5)) * 20 + Math.random() * 8
    const y = (canvasRef.value.height - height) / 2
    
    // Dessin barre
    ctx.fillRect(x, y, barWidth, height)
  }

  animationId = requestAnimationFrame(draw)
}

onMounted(() => {
  if (canvasRef.value) {
    ctx = canvasRef.value.getContext('2d')
    draw()
  }
})

onUnmounted(() => {
  cancelAnimationFrame(animationId)
})

watch(() => props.isActive, (newVal) => {
  if (newVal) {
    draw()
  } else {
    setTimeout(() => {
      cancelAnimationFrame(animationId)
      draw()
    }, 100)
  }
})
</script>

<template>
  <canvas 
    ref="canvasRef" 
    width="120" 
    height="40" 
    class="audio-visualizer"
  ></canvas>
</template>

<style scoped>
.audio-visualizer {
  display: block;
}
</style>
