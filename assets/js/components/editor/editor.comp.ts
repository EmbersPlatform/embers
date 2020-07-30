// @ts-ignore
import { html, ref } from "heresy";

import PubSub from "pubsub-js";

import { dgettext } from "~js/lib/gettext";

import { Component } from "~js/components/component";

import * as Posts from "~js/lib/posts";
import * as PostValidations from "~js/lib/posts/validations";
import * as Links from "~js/lib/links";
import * as Medias from "~js/lib/medias";

import add_image_icon from "/static/svg/generic/image.svg";
import publish_icon from "~static/svg/generic/inbox.svg";

import AutosizeTextarea from "../textarea/textarea.comp";
import TagInput from "./tag_input";
import MediaZone from "./medias/zone";
import LinkZone from "./link_zone";

import type {FileOrMedia} from "./medias/zone"

export default class PostEditor extends Component(HTMLElement) {
  static component = "PostEditor";

  static tagName = "element";

  static includes = { AutosizeTextarea, TagInput, MediaZone, LinkZone };
  static booleanAttributes = ["compact", "notags", "noactions", "nomedia", "as_thread"];

  compact = this["compact"] as boolean;
  notags = this["notags"] as boolean;
  noactions = this["noactions"] as boolean;
  nomedia = this["nomedia"] as boolean;
  as_thread = this["as_thread"] as boolean;

  placeholder: string

  textarea
  tag_input
  media_zone
  link_zone
  nsfw_switch

  cancel
  publish
  show
  hide
  addReply

  onconnected() {
    super.initialize();
    if(this._in_preview) return;

    this.textarea = ref();
    this.tag_input = ref();
    this.media_zone = ref();
    this.link_zone = ref();
    this.nsfw_switch = ref();

    this.placeholder =
      this.getAttribute("placeholder")
      || dgettext("editor", "Share something with your followers!")
  }

  render({useState}: Hooks) {
    if(this._in_preview) return;
    const [body, setBody] = useState("");
    const [tags, setTags] = useState<string[]>([]);
    const [medias, setMedias] = useState<FileOrMedia[]>([]);
    const [links, setLinks] = useState([]);
    const [publishing, setPublishing] = useState<boolean>(false);
    const [nsfw, setNsfw] = useState(false);
    const [errors, setErrors] = useState<string[]>([]);

    const post_attrs = {
      body,
      tags,
      medias: medias.map(m => m.value),
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
      this.nsfw_switch.current.reset();
    }

    this.cancel = () => {
      reset();
    }

    this.publish = async () => {
      if (publishing) return;
      if (this.compact) this.textarea.current.focus();

      let options: Posts.CreatePostOptions = {params: {}};

      if(this.as_thread) {
        options.params.as_thread = true;
      }

      if(nsfw && !post_attrs.tags.includes("nsfw")) {
        post_attrs.tags.push("nsfw");
      }

      setPublishing(true);
      setErrors([]);
      const res = await Posts.create(post_attrs, options)
      setPublishing(false)
      switch(res.tag) {
        case "Success": {
          this.dispatch("publish", res.value);
          PubSub.publish("post.created", res.value);
          reset();
          break;
        }
        case "Error": {
          let errs = [];
          for(let e in res.value.errors) {
            errs = [...errs, ...res.value.errors[e]]
          }
          setErrors(errs);
          break;
        }
        case "NetworkError": {
          alert("No se pudo conectar con el servidor");
          break;
        }
      }
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

    const add_file = (file: File) => {
      remove_link();
      this.media_zone.current.add_file(file);
    }

    const select_media = (event: Event) => {
      const target = event.target as HTMLInputElement;
      let files = Array.from(target.files);
      files.forEach(file => add_file(file));
      target.files= null;
    }

    const handle_paste = (event: ClipboardEvent) => {
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

    const handle_media_change = (event: CustomEvent) => {
      setMedias(event.detail)
    }

    const tag_input = !(this.notags || this.compact)
      ? html`
        <TagInput
          ref=${this.tag_input}
          onupdate=${e => setTags(e.detail)}
        />
        `
      : ``

    const toggle_nsfw = event => {
      console.log(event)
      setNsfw(event.detail);
    }

    const publish_buttons = (!this.compact && !this.noactions)
      ? html`
        <div class="editor-actions">
          <switch-input
            class="vertical"
            onchange=${toggle_nsfw}
            ref=${this.nsfw_switch}
          >NSFW</switch-input>
          ${!this.nomedia
            ? html`
              <label class="plain-button" tabindex="0" title=${dgettext("editor", "Add image")}>
                ${{ html: add_image_icon }}
                <input
                  type="file"
                  style="display: none;"
                  onchange=${select_media}
                  multiple
                  disabled=${publishing}
                  accept=${Medias.allowed_media_types.join(",")}
                >
              </label>
              `
            : ``}
          <button
            class="button"
            onclick=${this.cancel}
            disabled=${publishing}
            title=${dgettext("editor", "Cancel")}
            aria-label=${dgettext("editor", "Cancel")}
            tabindex="0"
          >${dgettext("editor", "Cancel")}</button>
          <button
            class="button primary"
            onclick=${this.publish}
            disabled=${!can_publish}
            title=${dgettext("editor", "Publish")}
            aria-label=${dgettext("editor", "Publish")}
            tabindex="0"
          >${dgettext("editor", "Publish")}</button>
        </div>
        `
      : ``

    const compact_buttons = this.compact
      ? html`
        ${!this.nomedia
          ? html`
            <label class="plain-button" tabindex="0" title=${dgettext("editor", "Add image")}>
              ${{ html: add_image_icon }}
              <input
                type="file"
                style="display: none;"
                onchange=${select_media}
                multiple
                disabled=${publishing}
                accept=${Medias.allowed_media_types.join(",")}
              >
            </label>
            `
          : ``}
        <button
          class="plain-button"
          onclick=${this.publish}
          ontouchend=${this.publish}
          disabled=${!can_publish}
          title=${dgettext("editor", "Publish")}
          aria-label=${dgettext("editor", "Publish")}
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
      <MediaZone ref=${this.media_zone} onmediachange=${handle_media_change} />
      <LinkZone ref=${this.link_zone} onprocess=${e => setLinks([e.detail])} />
      ${tag_input}
      ${publish_buttons}
      ${(errors.length > 0)
        ? html`
          <ul class="editor-errors">
            ${errors.map(error => html`<li>${dgettext("editor", error)}</li>`)}
          </ul>
          `
        : ``
      }

    </form>
    `;
  }
};
