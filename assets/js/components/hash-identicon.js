const GRID = 5;
const SQUARE = 5;
const SIZE = SQUARE * GRID;

customElements.define(
  "emb-hash-identicon",
  class extends HTMLElement {
    connectedCallback() {
      this.svg = document.createElementNS("http://www.w3.org/2000/svg", "svg");
      this.svg.setAttribute("xmlns:xlink", "http://www.w3.org/1999/xlink");
      this.svg.setAttribute("height", SIZE.toString());
      this.svg.setAttribute("width", SIZE.toString());
      this.appendChild(this.svg);
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
      let filled = [];
      const text = this.dataset.text || "";
      const hash = await hash_text(text);

      let chance = Math.min(text.length / 16, 0.5);

      for (let x = 0; x < GRID; x++) {
        for (let y = 0; y < GRID; y++) {
          let pos = GRID * x + y;
          if (pos > hash.length) pos -= hash.length;

          if (parseInt(hash[pos], 16) < chance * 16) filled.push({ x, y });
        }
      }

      let content = new DocumentFragment();
      for (let coords of filled) {
        const cell = document.createElementNS(
          "http://www.w3.org/2000/svg",
          "rect"
        );
        cell.setAttribute("x", (coords.x * SQUARE).toString());
        cell.setAttribute("y", (coords.y * SQUARE).toString());
        cell.setAttribute("width", (SQUARE - 2).toString());
        cell.setAttribute("height", (SQUARE - 2).toString());
        cell.setAttribute("fill", "currentColor");
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
