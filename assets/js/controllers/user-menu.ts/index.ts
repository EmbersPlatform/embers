import { BaseController } from "~js/lib/controller";

import * as Fetch from "~js/lib/utils/fetch";

export const name = "user-menu";

export default class UserMenu extends BaseController {
  async log_out() {
    const _res = await Fetch.delet("/logout");
    // TODO Handle errors
    window.location.reload();
  }
}
