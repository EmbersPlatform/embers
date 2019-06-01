// Concatena shared post que se siguen el uno al otro
// TODO concatenar post entre peticiones loadmore y vista actual
export const concat_post = (items) => {
  outer: for (var i = 0; i < items.length; i++) {
    if (items[i].isShared) {
      var sharers = [items[i].user];
      inner: for (var o = i + 1; o < items.length; o++) {
        if (items[o].isShared) {
          if (items[o].source.id == items[i].source.id) {
            //is another shared from same post, save and delete
            sharers.push(items[o].user);
            items.splice(o, 1);
            o -= 1;
          }
        } else {
          if (items[o].id == items[i].source.id) {
            //is original post
            items.splice(o, 1);
            break inner;
          }
        }
      }
      items[i]["sharers"] = sharers;
    }
  }
  return items;
}
