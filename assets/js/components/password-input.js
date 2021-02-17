customElements.define(
  "emb-password-input",
  class extends HTMLElement {
    connectedCallback() {
      setTimeout(() => {
        const input = /** @type {HTMLInputElement} */ (this.querySelector(
          "input[type=password]"
        ));
        const identicon = /** @type {HTMLElement} */ (this.querySelector(
          "emb-hash-identicon"
        ) || document.createElement("emb-hash-identicon"));
        identicon.setAttribute(
          "title",
          "Your password has a unique figure, if you memorize it you can tell if you wrote it wrong :)"
        );
        identicon.setAttribute("aria-hidden", "true");
        identicon.dataset.text = input.value;

        this.appendChild(identicon);

        ["keyup", "change"].forEach((event) =>
          input.addEventListener(event, () => {
            identicon.dataset.text = input.value;
          })
        );
      });
    }
  }
);
