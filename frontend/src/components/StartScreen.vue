<script setup>
import {ref} from 'vue';
import loginAuthorization from './loginAuthorization.vue';
defineProps({
  topics: {
    type: Array,
    required: true,
  },
  selectedTopicId: {
    type: Number,
    default: null,
  },
  disabled: {
    type: Boolean,
    default: false,
  },
  isAuthenticated: {
    type: Boolean,
    default: false,
  },
  currentUser: {
    type: Object,
    default: null,
  }
})

const handleLoginSuccess = (userData) => {
  currentUser.value = userData;
  isAuthenticated.value = true;
  showLoginPopup.value = false;
  screen.value = 'home';
}

const showLoginPopup = ref(false);

defineEmits(['start', 'topic-change', 'register', 'logout', 'login-succes'])
</script>

<template>
  <section class="welcome panel" aria-labelledby="welcome-title">
    <div class="welcome-copy">
      <p class="eyebrow"><span aria-hidden="true">✦</span> Dags för en tidsresa!</p>
      <h1 id="welcome-title">{{ isAuthenticated ? `Välkommen, ${currentUser?.displayName || 'historiedetektiv'}!` : 'Hej, historiedetektiv!' }}</h1>
      <p class="intro">
        Följ med på en rolig resa bakåt i tiden. Svara på historiefrågor och upptäck spännande saker
        från förr. Du kan ta det precis i din egen takt!
      </p>
      <div class="topic-picker">
        <label for="topic-select">Välj en kategori i listan:</label>

        <select
          id="topic-select"
          :value="selectedTopicId ?? ''"
          :disabled="disabled || topics.length === 0"
          @change="$emit('topic-change', Number($event.target.value))"
        >
          <option disabled value="">Välj ett ämne</option>

          <option
            v-for="topic in topics"
            :key="topic.id"
            :value="topic.id"
          >
            {{ topic.name }}
          </option>
        </select>
      </div>

      <button
        class="button button-primary start-button"
        type="button"
        :disabled="disabled || selectedTopicId === null || topics.length === 0"
        @click="$emit('start')"
      >
        Börja spela <span aria-hidden="true">→</span>
      </button>
      <section class="login_container">
        <section class="login_actions">
        <template v-if="!isAuthenticated">
          <button
              class="back-button register-link"
              type="button"
              :disabled="disabled"
              @click="showLoginPopup = !showLogin"
            >
              {{ showLogin ? 'Stäng' : 'Logga in' }}
            </button>
            <section v-if="showLoginPopup" class="login-popup">
              <button class="close_btn" @click="showLoginPopup = false">×</button>
              <loginAuthorization @login-success="handleLoginSuccess" />
            </section>
            <button
              class="back-button register-link"
              type="button"
              :disabled="disabled"
              @click="$emit('register')"
            >
              Skapa konto (valfritt)
            </button>
        </template>
        <button
          v-else
          class="back-button register-link"
          type="button"
          @click="$emit('logout')"
        >
          Logga ut
        </button>
        
        </section>
      </section>
      <p class="reassurance"><span aria-hidden="true">☀</span> Ingen tidspress – här lär vi oss tillsammans.</p>
    </div>
    <div class="welcome-art" aria-hidden="true">
      <span class="art-spark spark-one">✦</span>
      <span class="art-spark spark-two">✧</span>
      <div class="sun">☼</div>
      <div class="art-book">📜</div>
      <div class="art-caption">En liten resa<br />genom historien</div>
    </div>
  </section>
</template>

<style scoped>
.topic-picker {
  display: grid;
  gap: 8px;
  margin: 24px 0;
}

.topic-picker select {
  width: 100%;
  min-width: 0;
  padding: 12px;
  border: 1px solid #999;
  border-radius: 8px;
  color: inherit;
  background: #fff;
  font: inherit;
}

.topic-picker select:focus-visible {
  outline: 3px solid #e5a33c;
  outline-offset: 3px;
}

.start-button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
  transform: none;
}

.register-link {
  display: block;
  margin-top: 20px;
}
</style>
