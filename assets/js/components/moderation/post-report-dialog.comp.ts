import { html, ref } from "heresy";
import ModalDialog from "~js/components/dialog/dialog.comp";
import { report_post } from "~js/lib/moderation/reports";
import { gettext, dgettext } from "~js/lib/gettext";

const predefined_reasons = [
  dgettext("reports", "No tiene filtro NSFW"),
  dgettext("reports", "Contenido pornográfico"),
  dgettext("reports", "Gore"),
  dgettext("reports", "Representacion sexual de un/a menor de edad"),
  dgettext("reports", "Viola derechos de autor"),
  dgettext("reports", "Viola leyes locales según se describe en las Reglas")
]

export default class extends ModalDialog {
  static component = "PostReportDialog";

  post_id: string;
  reason = "";
  custom_reason: Ref<HTMLTextAreaElement>;
  has_custom_reason = false;

  oninit() {
    super.oninit();
    this.custom_reason = ref();
    this.setAttribute("padded", "");
  }

  //@ts-ignore
  showModal = (post_id: string) => {
    this.post_id = post_id;
    super.showModal();
  }

  close = () => {
    this.post_id = undefined;
    super.close();
  }

  get_reason = () => {
    if(this.reason == "other") {
      return this.custom_reason.current.value;
    } else {
      return this.reason;
    }
  }

  send_report = async () => {
    const res = await report_post(this.post_id)
    switch(res.tag) {
      case "Success":
        window["status_toasts"].add({content: "Reporte enviado!"})
        this.close();
    }
  }

  render() {
    const contents = html`
      <header><p class="dialog-title">${gettext("Send post report")}</p></header>
      <section class="modal-content">
        <div class="form-fields">
          ${predefined_reasons.map(this.render_reason)}
          <label>
            <input type="radio" name="post-report-reason" value="other" onchange=${this.select_reason}>
            <span>Otra</span>
          </label>
        </div>
        <textarea is="autosize-textarea" placeholder=${gettext("What's the report reason?")} ref=${this.custom_reason} class=${!this.has_custom_reason ? `hidden` : ``}></textarea>
      </section>
      <footer>
        <button class="button" onclick=${this.close}>${gettext("Cancel")}</button>
        <button class="button primary" onclick=${this.send_report}>${gettext("Send report")}</button>
      </footer>
    `

    this.html`${this.render_dialog(contents)}`
  }

  select_reason = event => {
    this.reason = event.target.value;
    this.has_custom_reason = this.reason == "other";
    this.render();
    this.custom_reason.current.focus();
  }

  render_reason = reason => html`
    <label>
      <input name="post-report-reason" type="radio" value=${reason} onchange=${this.select_reason}>
      <span>${reason}</span>
    </label>
  `
}

let registered = false;

export const register_modal = () => {
  if(registered) return;
  const report_post_modal = document.createElement("post-report-dialog");
  window["report_post_modal"] = report_post_modal;
  document.body.append(report_post_modal);
  registered = true;
}
