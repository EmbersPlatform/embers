import ephemeris from "./ephemeris";

export const get_ephemeris = () => {
  const current_date = new Date();
  const current_day = current_date.getDate();
  const current_month = current_date.getMonth() + 1;

  const matching = ephemeris.filter(x => {
    return x.day == current_day && x.month == current_month
  });
  return matching[0];
}
