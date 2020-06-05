import "./modernizr";
import "./soft_keyboard";
import "./polyfills/dialog";
import "./lib/socket";

import * as Constrollers from "./controllers";
import * as Components from "./components";
import Turbolinks from "turbolinks";

Turbolinks.start();
Constrollers.init();
Components.init();
