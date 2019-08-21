<template>
  <div id="new-post-modal" @click="click_outside" ref="root">
    <div class="new-post-modal__content">
      <Editor data-editor-style="normal" rel="editor" @update="update_body"></Editor>
      <Card
        :post="related"
        v-if="related"
        :with_related="false"
        :tools="false"
        :footer="false"
        class="related"
      ></Card>
      <div class="m_block">
        <button
          @click.prevent="close"
          class="button"
          data-button-size="medium"
          data-button-font="medium"
        >cancelar</button>
        <button
          :disabled="!can_publish"
          @click.prevent="add_post"
          class="button"
          data-button-size="medium"
          data-button-font="medium"
          data-button-important
        >publicar</button>
      </div>
    </div>
  </div>
</template>

<script>
import post from "@/api/post";

import ToolBox from "@/components/ToolBox/_ToolBox";
import Card from "@/components/Card/_Card";
import Editor from "@/components/Editor";

import EventBus from "@/lib/event_bus";

let data = {
  post: {
    body: null,
    related_to_id: null
  }
};

export default {
  name: "new-post-modal",
  props: {
    related: {
      type: Object,
      default: null
    }
  },
  data: () => ({
    body: null,
    loading: false
  }),
  components: { Editor, Card },
  computed: {
    can_publish() {
      return !this.loading;
    }
  },
  methods: {
    update_body(body) {
      this.body = body;
    },
    close() {
      this.$emit("reset");
      EventBus.$emit("close_new_post_modal");
    },
    click_outside(event) {
      if (event.target == this.$refs.root) this.close();
    },
    async add_post() {
      let requestData = {
        body: this.body,
        related_to_id: this.related.id
      };

      this.loading = true;

      try {
        let res = await post.create(requestData);

        this.$store.dispatch("addFeedPost", res);
        this.$notify({
          group: "top",
          text: "Post compartido con éxito :)",
          type: "success"
        });
        this.close();
      } catch (error) {
        switch (error.status) {
          case 422:
            let key = Object.keys(error.res.errors)[0];
            let text = error.res.errors[key][0];
            if (text === "rate limited") text = "Ya compartiste este post. Espera 5 minutos para volver a hacerlo.";
            this.$notify({
              group: "top",
              text: text,
              type: "error"
            });
            break;
          case 500:
            this.$notify({
              group: "top",
              text: "hay un error en el servidor, por favor intenta en unos minutos o contacta con un administrador.",
              type: "error"
            });
            break;
          default:
            this.$notify({
              group: "top",
              text: error.message,
              type: "error"
            });
        }
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style lang="scss">
@keyframes slidefade {
  0% {
    opacity: 0;
    transform: translateY(10%);
  }
  100% {
    opacity: 1;
    transform: translateY(0);
  }
}

#new-post-modal {
  position: fixed;
  top: 0;
  left: 0;
  z-index: 100;
  width: 100vw;
  height: 100vh;
  background-color: #000000b5;
  display: flex;
  flex-direction: row;
  justify-content: center;
  align-items: end;
  overflow-y: auto;

  .new-post-modal__content {
    max-width: 80%;
    width: 600px;
    background: #222327;
    border: 1px solid rgba(255, 255, 255, 0.05);
    box-sizing: border-box;
    border-radius: 3px;
    box-shadow: 0 0 15px rgba(0, 0, 0, 0.25);
    margin: 20px 0;
    animation: slidefade 0.5s ease;

    .editor {
      margin: 20px;
    }

    .card {
      margin-bottom: 0;
      z-index: 0;
    }

    .m_block {
      display: flex;
      flex-direction: row;
      justify-content: flex-end;
      padding: 10px 15px;

      & > * {
        margin-left: 15px;
      }
    }
  }
}
</style>
