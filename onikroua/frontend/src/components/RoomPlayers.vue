<script setup lang="ts">
import { computed } from 'vue'
import { useRoomStore } from '../stores/room'
import { useAuthStore } from '../stores/auth'

const roomStore = useRoomStore()
const authStore = useAuthStore()

const playersList = computed(() => {
  return Object.entries(roomStore.players).map(([uid, data]) => ({
    uid,
    isMe: uid === authStore.user?.uid,
    isHost: uid === roomStore.room?.hostUid,
    score: data.score || 0,
    ready: data.ready || false,
    name: data.name || 'Joueur'
  }))
})
</script>

<template>
  <div class="players-panel card">
    <h3>👥 Joueurs</h3>
    <ul class="players-list">
      <li
        v-for="player in playersList"
        :key="player.uid"
        :class="['player-item', { 'is-me': player.isMe }]"
      >
        <div class="player-info">
          <span class="player-name">
            {{ player.name }}
            <span v-if="player.isMe" class="me-badge">(vous)</span>
            <span v-if="player.isHost" class="host-badge">👑</span>
          </span>
          <span class="player-score">{{ player.score }} pts</span>
        </div>
      </li>
      <li v-if="playersList.length < 2" class="player-item waiting">
        <span class="player-name">En attente d'un joueur...</span>
      </li>
    </ul>
  </div>
</template>

<style scoped>
.players-panel {
  height: 100%;
}

.players-panel h3 {
  margin: 0 0 1rem 0;
  color: #2c3e50;
  font-size: 1rem;
}

.players-list {
  list-style: none;
  padding: 0;
  margin: 0;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.player-item {
  padding: 0.75rem;
  background: #f8f9fa;
  border-radius: 6px;
  transition: background 0.2s;
}

.player-item.is-me {
  background: #e8f4fc;
  border: 1px solid #3498db;
}

.player-item.waiting {
  background: #fef9e7;
  color: #7f8c8d;
  font-style: italic;
}

.player-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.player-name {
  font-weight: 500;
}

.host-badge {
  margin-left: 0.25rem;
}

.me-badge {
  margin-left: 0.25rem;
  font-size: 0.8rem;
  color: #3498db;
  font-weight: normal;
}

.player-score {
  font-size: 0.85rem;
  color: #27ae60;
  font-weight: 600;
}
</style>
