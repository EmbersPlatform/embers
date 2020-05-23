import union from "/js/lib/utils/union";

let Result = union("Result", {
  Ok: ["value"],
  Err: ["error"]
});

Result.prototype.match = function(clauses) { return this.cata(clauses) }

export default Result;
