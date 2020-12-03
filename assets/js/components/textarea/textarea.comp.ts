import autosize from "autosize";
import { Component } from "~js/components/component";

export default class AutosizeTextarea extends Component(HTMLTextAreaElement) {
  static component = "AutosizeTextarea";
  static tagName = "textarea";

  onconnected() {
    autosize(this);
  }

  ondisconnected() {
    autosize.destroy(this);
  }

  update() {
    autosize.update(this);
  }
}

