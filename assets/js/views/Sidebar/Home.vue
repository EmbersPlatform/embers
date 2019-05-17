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
        <li class="n_item" v-for="tag in tags" :key="tag.id">
          <router-link class="n_i_wrap" :to="`/search/in:${tag.name}`" exact>
            <span class="n_i_w_content"># {{tag.name}}</span>
          </router-link>
        </li>
        <li v-if="!tags.length" class="no-results">
          <p>Aún no sigues ningún tag.</p>
        </li>
      </ul>
    </li>
    <li class="nav_">
      <h3>amigos</h3>
    </li>
    <Mutuals :online="true"></Mutuals>
  </ul>
</template>

<script>
import axios from "axios";
import Mutuals from "@/components/Mutuals";
import { mapGetters } from "vuex";

export default {
  components: { Mutuals },
  data() {
    return {};
  },
  computed: {
    ...mapGetters("tag", ["tags"])
  },
  created() {
    axios.get(`/api/v1/subscriptions/tags/list`).then(res => {
      this.tags = res.data.tags;
    });
  }
};
</script>

<style lang="scss">
.tag {
  color: gray;
  margin-left: 1.5em;
}
</style>

