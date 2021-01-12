customElements.define("emb-password-input", class extends HTMLElement {
  connectedCallback() {
    setTimeout(() => {
      const input = /** @type {HTMLInputElement} */(this.querySelector("input[type=password]"));
      const identicon = document.createElement("emb-hash-identicon");

      this.appendChild(identicon);

      input.addEventListener("keyup", () => {
        identicon.dataset.text = input.value;
      })
    })
  }
})
