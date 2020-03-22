import * as Posts from "../../lib/posts";

const PostEditor = {
  name: "PostEditor",
  extends: "element",

  render({ useState }) {
    const { parent_id } = this.dataset;
    const [body, setBody] = useState("");

    const cancel = e => {
      e.preventDefault();
      setBody("")
    };

    const publish = e => {
      e.preventDefault();

      Posts.create({ body, parent_id })
        .then(res => res.text())
        .then(html => {
          this.dispatchEvent(new CustomEvent("publish", {detail: html}))
        })
    };

    this.html`
    <form onsubmit=${publish}>
      <fieldset>
        <legend>Post body</legend>
        <textarea
          oninput=${event => setBody(event.target.value)}
          value=${body}
        ></textarea>
      </fieldset>
      <fieldset>
        <button class="button" onclick=${cancel}>Cancel</button>
        <button class="button primary" onclick=${publish}>Publish</button>
      </fieldset>
    </form>
    `;
  }
};

export default PostEditor;
