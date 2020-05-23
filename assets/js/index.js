import "./modernizr";
import "./soft_keyboard";
import "./polyfills/dialog";

import * as Constrollers from "./controllers";
import * as Components from "./components";
const Turbolinks = require("turbolinks");

Turbolinks.start();
Constrollers.init();
Components.init();
