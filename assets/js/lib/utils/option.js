import union from "/js/lib/utils/union";

let Option = union("Option", {
  Some: ["value"],
  None: []
});

Option.prototype.map = function(f) {
  return this.match({
    Some: value => Option.Some(f(value)),
    None: () => Option.None
  })
};

export default Option;
