customElements.define(
  "emb-password-confirm",
  class extends HTMLFieldSetElement {
    connectedCallback() {
      setTimeout(() => {
        const pwd = /** @type {HTMLInputElement} */ (this.querySelector(
          "[new-password]"
        ));
        const confirm = /** @type {HTMLInputElement} */ (this.querySelector(
          "[new-password-confirmation]"
        ));

        [pwd, confirm].forEach((input) =>
          input.addEventListener("keyup", () => {
            this.classList.remove("password-match");
            this.classList.remove("password-mismatch");

            if (!pwd.value || !confirm.value) return;

            if (pwd.value !== confirm.value) {
              this.classList.add("password-mismatch");
              this.classList.remove("password-match");
            } else {
              this.classList.add("password-match");
              this.classList.remove("password-mismatch");
            }
          })
        );
      });
    }
  },
  { extends: "fieldset" }
);
