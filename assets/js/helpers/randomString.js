export default function generateRandomString() {
  if (window.crypto) {
    var a = window.crypto.getRandomValues(new Uint32Array(3)),
      token = '';
    for (var i = 0, l = a.length; i < l; i++) token += a[i].toString(36);
    return token;
  } else {
    return (Math.random() * new Date().getTime()).toString(36).replace( /\./g , '');
  }
}