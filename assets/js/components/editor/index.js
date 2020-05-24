import { html, ref } from "heresy";

import i18n from "#/lib/gettext";

import { Base } from "#/components/component";

import * as Posts from "#/lib/posts";
import * as PostValidations from "#/lib/posts/validations";
import * as Links from "#/lib/links";

import add_image_icon from "/static/svg/generic/image.svg";
import publish_icon from "/static/svg/generic/inbox.svg";

import AutosizeTextarea from "../textarea";
import TagInput from "./tag_input";
import MediaZone from "./medias/zone";
import LinkZone from "./link_zone";

const PostEditor = {
  ...Base,
  name: "PostEditor",
  extends: "element",
  includes: { AutosizeTextarea, TagInput, MediaZone, LinkZone },

  booleanAttributes: ["compact", "notags", "noactions", "nomedia", "as_thread"],

  oninit() {
    this.textarea = ref();
    this.tag_input = ref();
    this.media_zone = ref();
    this.link_zone = ref();

    this.placeholder =
      this.getAttribute("placeholder")
      || i18n.dgettext("editor", "Share something with your followers!")
  },

  render({ useState }) {
    const [body, setBody] = useState("");
    const [tags, setTags] = useState([]);
    const [medias, setMedias] = useState([]);
    const [links, setLinks] = useState([]);
    const [publishing, setPublishing] = useState(false)

    const post_attrs = {
      body,
      tags,
      medias,
      links,
      parent_id: this.dataset.parent_id,
      related_to_id: this.dataset.related_to_id
    }

    const can_publish = !publishing && PostValidations.valid_post(post_attrs)

    const reset = () => {
      setBody("");
      setTags([]);
      setMedias([]);
      setLinks([]);
      if(this.tag_input.current)
        this.tag_input.current.value = "";
      this.textarea.current.update();
      this.media_zone.current.reset();
      this.link_zone.current.reset();
    }

    this.cancel = () => {
      reset();
    }

    this.publish = async () => {
      if (publishing) return;
      if (this.compact) this.textarea.current.focus();

      let options = {params: {}};

      if(this.as_thread) {
        options.params.as_thread = true;
      }

      setPublishing(true);
      Posts.create(post_attrs, options)
      .then(result => {
        setPublishing(false)
        result.match({
          Success: html => {
            this.dispatch("publish", html);
            reset();
          },
          Error: errors => {
            alert("Error al publicar el post");
          },
          NetworkError: () => {
            alert("No se pudo conectar con el servidor")
          }
        })
      })
    }

    this.show = () => {
      this.classList.remove("hidden");
    }

    this.hide = () => {
      this.classList.add("hidden");
    }

    this.addReply = username => {
      if(username)
        setBody(`@${username} `);
      this.textarea.current.focus();
    }

    const remove_link = () => {
      setLinks([]);
      this.link_zone.current.reset();
    }

    const add_file = file => {
      remove_link();
      this.media_zone.current.add_file(file);
    }

    const select_media = event => {
      let files = Array.from(event.target.files);
      files = files.map(file => { file.id = Math.random(); return file});
      files.forEach(file => add_file(file));
      event.target.files = null;
    }

    const handle_paste = event => {
      let files = event.clipboardData.files;
      if(files.length) {
        Array.from(files).forEach(file => add_file(file));
      }

      const text = event.clipboardData.getData("text");
      if(Links.text_has_link(text)) {
        const link = Links.extract_links(text)[0];
        this.link_zone.current.add_link(link);
      }
    }

    const tag_input = !(this.notags || this.compact)
      ? html`
        <TagInput
          ref=${this.tag_input}
          onupdate=${e => setTags(e.detail)}
        />
        `
      : ``

    const publish_buttons = (!this.compact && !this.noactions)
      ? html`
        <div class="editor-actions">
          ${!this.nomedia
            ? html`
              <label class="plain-button" tabindex="0" title=${i18n.dgettext("editor", "Add image")}>
                ${{ html: add_image_icon }}
                <input
                  type="file"
                  style="display: none;"
                  onchange=${select_media}
                  multiple
                  disabled=${publishing}
                >
              </label>
              `
            : ``}
          <button
            class="button"
            onclick=${this.cancel}
            disabled=${publishing}
            title=${i18n.dgettext("editor", "Cancel")}
            aria-label=${i18n.dgettext("editor", "Cancel")}
            tabindex="0"
          >${i18n.dgettext("editor", "Cancel")}</button>
          <button
            class="button primary"
            onclick=${this.publish}
            disabled=${!can_publish}
            title=${i18n.dgettext("editor", "Publish")}
            aria-label=${i18n.dgettext("editor", "Publish")}
            tabindex="0"
          >${i18n.dgettext("editor", "Publish")}</button>
        </div>
        `
      : ``

    const compact_buttons = this.compact
      ? html`
          ${!this.nomedia
            ? html`
              <label class="plain-button" tabindex="0" title=${i18n.dgettext("editor", "Add image")}>
                ${{ html: add_image_icon }}
                <input
                  type="file"
                  style="display: none;"
                  onchange=${select_media}
                  multiple
                  disabled=${publishing}
                >
              </label>
              `
            : ``}
          <button
            class="plain-button"
            onclick=${this.publish}
            ontouchend=${this.publish}
            disabled=${!can_publish}
            title=${i18n.dgettext("editor", "Publish")}
            aria-label=${i18n.dgettext("editor", "Publish")}
            tabindex="0"
          >
            ${{ html: publish_icon }}
          </button>
        `
      : ``

    this.html`
    <form onsubmit=${e => e.preventDefault()}>
      <div class="editor-body">
        <AutosizeTextarea
          oninput=${e => setBody(e.target.value)}
          onpaste=${handle_paste}
          .value=${body}
          placeholder=${this.placeholder}
          rows=${this.compact ? 1 : 3}
          ref=${this.textarea}
        />
        ${compact_buttons}
      </div>
      <MediaZone ref=${this.media_zone} onmediachange=${e => setMedias(e.detail)} />
      <LinkZone ref=${this.link_zone} onprocess=${e => setLinks([e.detail])} />
      ${tag_input}
      ${publish_buttons}
    </form>
    `;
  }
};

export default PostEditor;
