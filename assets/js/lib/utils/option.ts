// @ts-check
import union from "~js/lib/utils/union";

const OptionPrototype = {
  map: function(f) {
    return this.match({
      Some: value => Option.Some(f(value)),
      None: () => Option.None
    })
  }
}

let Option = union("Option", {
  Some: ["value"],
  None: []
}, OptionPrototype);

export default Option;
