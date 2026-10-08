<script setup>
defineEmits(['start'])
</script>

<template>
  <section class="welcome panel" aria-labelledby="welcome-title">
    <div class="welcome-copy">
      <p class="eyebrow"><span aria-hidden="true">✦</span> Dags för en tidsresa!</p>
      <h1 id="welcome-title">Hej, historiedetektiv!</h1>
      <p class="intro">
        Följ med på en rolig resa bakåt i tiden. Svara på fem frågor och upptäck spännande saker
        från förr. Du kan ta det precis i din egen takt!
      </p>
      <button class="button button-primary start-button" type="button" @click="$emit('start')">
        Börja spela <span aria-hidden="true">→</span>
      </button>
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
