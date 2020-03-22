import * as Stimulus from "./stimulus";
import * as Components from "./components";
const Turbolinks = require("turbolinks");

Turbolinks.start();
Stimulus.init();
Components.init();
