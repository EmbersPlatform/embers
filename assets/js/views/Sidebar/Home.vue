<template>
  <ul id="column">
    <li class="nav_">
      <h2>inicio</h2>
    </li>
    <li class="nav_">
      <ul>
        <li class="n_item">
          <router-link class="n_i_wrap" to="/" exact>
            <span class="n_i_w_clip">
              <svgicon name="s_activity"></svgicon>
            </span>
            <span class="n_i_w_content">actividad</span>
          </router-link>
        </li>
        <li class="n_item">
          <router-link class="n_i_wrap" to="/favorites">
            <span class="n_i_w_clip">
              <svgicon name="s_sponsored"></svgicon>
            </span>
            <span class="n_i_w_content">Favoritos</span>
          </router-link>
        </li>
        <li class="n_item">
          <router-link class="n_i_wrap" to="/subscriptions/users">
            <span class="n_i_w_clip">
              <svgicon name="s_subs"></svgicon>
            </span>
            <span class="n_i_w_content">Subscripciones</span>
          </router-link>
        </li>
      </ul>
    </li>
    <li class="nav_">
      <h2>mis tags</h2>
    </li>
    <li class="nav_">
      <ul>
        <li class="no-results" v-if="tags.length < 1">
          <p>Aún no sigues ningún tag.</p>
        </li>
        <li class="n_item__tag" v-for="tag in tags" :key="tag.id">#{{tag.name}}</li>
      </ul>
    </li>
    <li class="nav_">
      <h3>amigos</h3>
    </li>
    <Mutuals :online="true"></Mutuals>
  </ul>
</template>

<script>
import Mutuals from "../../components/Mutuals";

import { mapGetters } from "vuex";

export default {
  components: { Mutuals },
  computed: {
    ...mapGetters("tag", ["tags"])
  }
};
</script>

<style lang="scss">
.n_item__tag {
  color: gray;
  margin-left: 1.5em;
}
</style>

