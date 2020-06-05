import autosize from "autosize";
import { Component } from "~js/components/component";

class AutosizeTextarea extends Component(HTMLTextAreaElement) {
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

export default AutosizeTextarea;
