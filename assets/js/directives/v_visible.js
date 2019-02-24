const v_visible = {
  install(Vue) {
    Vue.directive("visible", (el, binding) => {
      var value = binding.value;

      if (!!value) {
        el.style.visibility = "visible";
      } else {
        el.style.visibility = "hidden";
      }
    });
  }
};

if (typeof window !== "undefined" && window.Vue) {
  window.Vue.use(v_visible);
}

export default v_visible;
