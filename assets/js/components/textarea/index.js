import autosize from "autosize";

const AutosizeTextarea = {
  name: "AutosizeTextarea",
  extends: "textarea",

  onconnected() {
    autosize(this);
  },

  ondisconnected() {
    autosize.destroy(this);
  },

  update() {
    autosize.update(this);
  }
}

export default AutosizeTextarea;
