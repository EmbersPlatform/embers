import Pjax from "pjax-api";

declare global {
  interface Window { pjax: Pjax; }
}
