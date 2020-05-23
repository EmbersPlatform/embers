import {taggedSum} from "daggy";

export default function union(...args) {
  const tagged = taggedSum(...args);

  tagged.prototype.match = function(clauses) { return this.cata(clauses)}

  return tagged;
}
