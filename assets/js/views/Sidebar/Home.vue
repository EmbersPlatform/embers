<template>
  <ul id="column">
    <li class="nav_">
      <h2>inicio</h2>
    </li>
    <li class="nav_ sub_">
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
              <i class="far fa-star"/>
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
      <h2>tags seguidos</h2>
    </li>
    <li class="nav_ sub_">
      <ul>
        <li class="n_item tag-item" v-for="tag in tags" :key="tag.id">
          <router-link class="n_i_wrap" :to="`/tag/${tag.name}`" exact>
            <span class="n_i_w_clip">
              <i class="fas fa-hashtag"/>
            </span>
            <span class="n_i_w_content">{{tag.name}}</span>
            <button class="button unsub-tag" @click.prevent="unsub_tag(tag)">
              <i class="far fa-trash-alt"/>
            </button>
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
  computed: {
    ...mapGetters("tag", ["tags"])
  },
  methods: {
    async unsub_tag(tag) {
      await axios.delete(`/api/v1/subscriptions/tags/${tag.id}`);
      this.$store.dispatch("tag/delete", tag.name);
    }
  },
  created() {
    axios.get(`/api/v1/subscriptions/tags/list`).then(res => {
      this.$store.dispatch("tag/update", res.items.map(x => x.name));
    });
  }
};
</script>

<style lang="scss">
.tag-item {
  display: flex;
  align-items: center;
  .n_i_w_content {
    flex-grow: 1;
  }
  .unsub-tag {
    justify-self: flex-end;
    visibility: hidden;
  }

  &:hover {
    .unsub-tag {
      visibility: visible;
    }
  }
}
</style>
