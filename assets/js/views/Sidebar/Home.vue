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
        <li class="n_item tag" v-for="tag in tags" :key="tag.id">#{{tag.name}}</li>
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
import Mutuals from "../../components/Mutuals.vue";
export default {
  components: { Mutuals },
  data() {
    return {
      tags: []
    };
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

