import "./modernizr";
import "./soft_keyboard";
import "./polyfills/dialog";
import "./lib/socket";
import "./unpoly";

import * as Constrollers from "./controllers";
import * as Components from "./components";

// Turbolinks.start();
Constrollers.init();
Components.init();

