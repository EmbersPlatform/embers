<template>
	<nav id="sticky">
		<h1>
			<a href="/">
				<svgicon name="elogo"></svgicon>
			</a>
		</h1>
		<ul :class="{'active' : isHamburguer}">
			<li>
				<button :class="{'active' : isHamburguer}" data-button-size="medium" data-button-font="medium" class="button" @click.prevent="tgr_hamburguer">
					<svgicon name="n_hamburguer"></svgicon>
				</button>
			</li>
			<li>
				<router-link to="/faq">
					faq
				</router-link>
			</li>
			<li>
				<router-link to="/rules">
					reglas
				</router-link>
			</li>
			<li>
				<router-link to="/acknowledgment">
					agradecimientos
				</router-link>
			</li>
			<template v-if="!user">
				<li>
					<a href="/register" class="button" data-button-size="medium" data-button-font="medium" data-button-uppercase>
						registrate
					</a>
				</li>
				<li>
					<a href="/login">
						inicia sesion
					</a>
				</li>
			</template>
		</ul>
	</nav>
</template>
<script>
import { mapGetters } from "vuex";

export default {
  data() {
    return {
      isHamburguer: false
    };
  },
  computed: {
    ...mapGetters({
      user: "user"
    })
  },
  methods: {
    tgr_hamburguer() {
      this.isHamburguer = !this.isHamburguer;
    }
  }
};
</script>
