import { html } from "heresy";
import { UserData } from "~js/lib/application";
import ModalDialog from "../dialog/dialog.comp";
import * as Fetch from "~js/lib/utils/fetch";
import { gettext, dgettext } from "~js/lib/gettext";
import back_icon from "/static/svg/generic/icons/angle-left.svg";
import { reactive } from "../component";

type ReportReason = {
  reporter: UserData,
  comments: string[]
}

export default class ReportReasonsDialog extends ModalDialog {
  static component = "ReportReasonsDialog";

  state = reactive(
    {
      reasons: <ReportReason[]>[],
      last_page: false,
      next: <string>null,
      loading_more: false
    },
    () => this.render()
  )

  onconnected = () => {
    this.state.reasons.map(() => this.render());
  }

  showModal = () => {
    super.showModal();
    if(this.state.reasons.length <= 0)
      this.fetch_comments();
  }

  close = () => super.close();

  fetch_comments = async () => {
    const res = await Fetch.get(`/moderation/reports/post/${this.dataset.postId}/comments`);
    switch(res.tag) {
      case "Success": {
        const {reasons, next, last_page} = await res.value.json();
        this.state.next = next;
        this.state.last_page = last_page;
        this.state.reasons = reasons;
      }
    }
  }

  load_more = async () => {
    if(this.state.last_page) return;
    if(this.state.loading_more) return;

    this.state.loading_more = true;

    const params = {before: this.state.next};
    const res = await Fetch.get(`/moderation/reports/post/${this.dataset.postId}/comments`, {params})
    switch(res.tag) {
      case "Success": {
        const {reasons, next, last_page} = await res.value.json();
        this.state.next = next;
        this.state.last_page = last_page;
        this.state.reasons = [...this.state.reasons, ...reasons];
      }
    }

    this.state.loading_more = false;
  }

  render() {
    const load_more_section = !this.state.last_page
      ? html`
        <button class="button" onclick=${this.load_more} .disabled=${this.state.loading_more}>
          ${this.state.loading_more ? gettext("Loading more...") : gettext("Load more")}
        </button>
      `
      : ``

    const contents = html`
      <header>
        <button class="plain-button" onclick=${this.close}>${{html: back_icon}}</button>
        <span>${dgettext("moderation", "Report reasons")}</span>
      </header>
      <section class="dialog-content">
        ${this.state.reasons.map(render_reason_block)}
        ${load_more_section}
      </section>
    `

    this.html`${this.render_dialog(contents)}`
  }
}

const render_reason_block = reason => html`
  <div class="report-reasons">
    <strong>${reason.reporter.username}:</strong>
    <div class="report-reasons-comments">
      ${render_reason_comments(reason.comments)}
    </div>
  </div>
`

const render_reason_comments = comments => comments.map(comment => comment
  ?html`
    <p>- ${comment}</p>
  `
  : html`<p>- <em>${dgettext("moderation", "Reason not specified")}</em></p>`
)
