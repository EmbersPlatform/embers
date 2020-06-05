import union from "~js/lib/utils/union";

let Result = union("Result", {
  Ok: ["value"],
  Err: ["error"]
});

export default Result;
