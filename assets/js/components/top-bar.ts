import { define } from "wicked-elements";

define("#top-bar input[type=search]", {

  // @ts-ignore
  onKeyup(event: KeyboardEvent) {
    if(event.key === "Enter") {
      const query = (event.target as HTMLInputElement).value;
      window.pjax.assign(`/search/${query}`);
    }
  }
})
