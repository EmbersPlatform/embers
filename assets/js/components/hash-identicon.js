const GRID = 5;
const SQUARE = 5;
const SIZE = SQUARE * GRID;
const GAP = 2;

customElements.define(
  "emb-hash-identicon",
  class extends HTMLElement {
    connectedCallback() {
      const range = document.createRange();
      range.selectNodeContents(this);
      range.deleteContents();
      this.svg = document.createElementNS("http://www.w3.org/2000/svg", "svg");
      this.svg.setAttribute("xmlns:xlink", "http://www.w3.org/1999/xlink");
      this.svg.setAttribute("height", SIZE.toString());
      this.svg.setAttribute("width", SIZE.toString());
      this.svg.setAttribute("viewBox", `0 0 ${SIZE} ${SIZE}`);
      range.insertNode(this.svg);
      this.update();
    }

    static get observedAttributes() {
      return ["data-text"];
    }

    attributeChangedCallback() {
      this.update();
    }

    update() {
      this.generate_hash();
    }

    async generate_hash() {
      let squares = [];
      const text = this.dataset.text || "";
      const hash = await hash_text(text);

      let chance = Math.min(text.length / 16, 0.5);

      for (let x = 0; x < GRID; x++) {
        for (let y = 0; y < GRID; y++) {
          let pos = GRID * x + y;
          if (pos > hash.length) pos -= hash.length;

          const is_filled = parseInt(hash[pos], 16) < chance * 16;
          squares.push({ x, y, filled: is_filled });
        }
      }

      let content = new DocumentFragment();
      for (let coords of squares) {
        const cell = document.createElementNS(
          "http://www.w3.org/2000/svg",
          "rect"
        );
        cell.setAttribute("x", (coords.x * SQUARE).toString());
        cell.setAttribute("y", (coords.y * SQUARE).toString());
        cell.setAttribute("width", (SQUARE - GAP).toString());
        cell.setAttribute("height", (SQUARE - GAP).toString());

        const color = coords.filled ? "currentColor" : "#00000033";

        cell.setAttribute("fill", color);
        content.appendChild(cell);
      }
      const range = document.createRange();
      range.selectNodeContents(this.svg);
      range.deleteContents();
      range.insertNode(content);
    }
  }
);

async function hash_text(text) {
  const msgUint8 = new TextEncoder().encode(text);
  const hash_buffer = await crypto.subtle.digest("SHA-1", msgUint8);
  const hash_array = Array.from(new Uint8Array(hash_buffer));
  const hash_hex = hash_array
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
  return hash_hex;
}
