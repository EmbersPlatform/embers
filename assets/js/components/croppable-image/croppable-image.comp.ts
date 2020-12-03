import { Component } from "../component";
import Croppie from "croppie";

export default class extends Component(HTMLElement) {
  static component = "CroppableImage";

  static mappedAttributes = ["editing"];

  image: HTMLImageElement;
  editing = false;
  croppie: Croppie;
  resize_timeout = null;
  url: string;
  size_w;
  size_h;

  onconnected() {
    this.url = this.dataset.src;
    this.size_w = this.dataset.size_w;
    this.size_h = this.dataset.size_h;
    this._recalculate_sizes();
    this.refresh();

    this._resize_cropper = this._resize_cropper.bind(this);

    window.addEventListener("resize", this._resize_cropper);
  }

  ondisconnected() {
    window.removeEventListener("resize", this._resize_cropper);
  }

  set_image(url) {
    this.url = url;
    if(this.croppie)
      this.croppie.bind({url});
  }

  result(options) {
    if(!options) options = {type: 'base64'};
    return this.croppie.result(options, {circle: false});
  }

  refresh() {
    if(this.croppie) this.croppie.destroy();
    this._build_croppie();
    if(this.url) {
      this.set_image(this.url);
    }
  }

  _build_croppie() {
    this.croppie = new Croppie(this, {
      viewport: {
        width: this.size_w,
        height: this.size_h,
        type: this.dataset.shape
      },
      boundary: {
        width: this.size_w,
        height: this.size_h
      }
    });
  }

  _resize_cropper() {
    if (this.resize_timeout) return;
    this.resize_timeout = setTimeout(() => {
      clearTimeout(this.resize_timeout);
      this.resize_timeout = null;
    }, 50);

    this._recalculate_sizes();

    setTimeout(() => this.refresh(), 100);
  }

  _recalculate_sizes() {
    let initial_w = parseInt(this.dataset.size_w);
    let initial_h = parseInt(this.dataset.size_h);
    let parentW = this.offsetWidth;
    let w = parentW < initial_w ? parentW : initial_w;
    let h = parentW < initial_w ? Math.round(parentW * 0.33) : initial_h;

    this.size_w = w.toString();
    this.size_h = h.toString();
  }
}
