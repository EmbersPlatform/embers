import { define } from "wicked-elements";
import { html } from "uhtml";

define('.ban-summary', {
  init() {
    const onunban = () => this.element.remove();

    this.ban_details = html.node`
      <ban-details-dialog padded onunban=${onunban}/>
    `
    this.ban_details.ban = {
      reason: this.element.dataset.reason,
      expires_at: this.element.dataset.expiresAt,
      user: this.element.dataset.user,
      user_id: this.element.dataset.userId
    }

    this.element.append(this.ban_details);
  },
  // @ts-ignore
  onClick(event) {
    const target = event.target as HTMLElement;
    if(target !== this.ban_details && !this.ban_details.contains(target))
      this.ban_details.showModal();
  }
})
