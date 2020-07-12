/*! modernizr 3.6.0 (Custom Build) | MIT *
		 * https://modernizr.com/download/?-touchevents !*/
! function (e, n, t) {
  function o(e, n) {
    return typeof e === n
  }

  function s() {
    var e, n, t, s, i, a, r;
    for (var l in f)
      if (f.hasOwnProperty(l)) {
        if (e = [], n = f[l], n.name && (e.push(n.name.toLowerCase()), n.options && n.options.aliases && n.options
          .aliases.length))
          for (t = 0; t < n.options.aliases.length; t++) e.push(n.options.aliases[t].toLowerCase());
        for (s = o(n.fn, "function") ? n.fn() : n.fn, i = 0; i < e.length; i++) a = e[i], r = a.split("."), 1 === r
          .length ? Modernizr[r[0]] = s : (!Modernizr[r[0]] || Modernizr[r[0]] instanceof Boolean || (Modernizr[r[
            0]] = new Boolean(Modernizr[r[0]])), Modernizr[r[0]][r[1]] = s), d.push((s ? "" : "no-") + r.join("-"))
      }
  }

  function i() {
    return "function" != typeof n.createElement ? n.createElement(arguments[0]) : p ? n.createElementNS.call(n,
      "http://www.w3.org/2000/svg", arguments[0]) : n.createElement.apply(n, arguments)
  }

  function a() {
    var e = n.body;
    return e || (e = i(p ? "svg" : "body"), e.fake = !0), e
  }

  function r(e, t, o, s) {
    var r, f, l, d, u = "modernizr",
      p = i("div"),
      h = a();
    if (parseInt(o, 10))
      for (; o--;) l = i("div"), l.id = s ? s[o] : u + (o + 1), p.appendChild(l);
    return r = i("style"), r.type = "text/css", r.id = "s" + u, (h.fake ? h : p).appendChild(r), h.appendChild(p), r
      .styleSheet ? r.styleSheet.cssText = e : r.appendChild(n.createTextNode(e)), p.id = u, h.fake && (h.style
        .background = "", h.style.overflow = "hidden", d = c.style.overflow, c.style.overflow = "hidden", c
          .appendChild(h)), f = t(p, e), h.fake ? (h.parentNode.removeChild(h), c.style.overflow = d, c.offsetHeight) :
        p.parentNode.removeChild(p), !!f
  }
  var f = [],
    l = {
      _version: "3.6.0",
      _config: {
        classPrefix: "",
        enableClasses: !0,
        enableJSClass: !0,
        usePrefixes: !0
      },
      _q: [],
      on: function (e, n) {
        var t = this;
        setTimeout(function () {
          n(t[e])
        }, 0)
      },
      addTest: function (e, n, t) {
        f.push({
          name: e,
          fn: n,
          options: t
        })
      },
      addAsyncTest: function (e) {
        f.push({
          name: null,
          fn: e
        })
      }
    },
    Modernizr = function () { };
  Modernizr.prototype = l, Modernizr = new Modernizr;
  var d = [],
    u = l._config.usePrefixes ? " -webkit- -moz- -o- -ms- ".split(" ") : ["", ""];
  l._prefixes = u;
  var c = n.documentElement,
    p = "svg" === c.nodeName.toLowerCase(),
    h = l.testStyles = r;
  Modernizr.addTest("touchevents", function () {
    var t;
    if ("ontouchstart" in e || e.DocumentTouch && n instanceof DocumentTouch) t = !0;
    else {
      var o = ["@media (", u.join("touch-enabled),("), "heartz", ")", "{#modernizr{top:9px;position:absolute}}"]
        .join("");
      h(o, function (e) {
        t = 9 === e.offsetTop
      })
    }
    return t
  }), s(), delete l.addTest, delete l.addAsyncTest;
  for (var m = 0; m < Modernizr._q.length; m++) Modernizr._q[m]();
  e.Modernizr = Modernizr
}(window, document);
