export class Timer {

  timer_id: number
  start: Date
  remaining: number;
  callback: Function;

  constructor(delay: number, callback: Function) {
    this.remaining = delay;
    this.callback = callback;

    this.resume();
  }

  pause = () => {
    clearTimeout(this.timer_id);
    this.remaining -= (new Date()).valueOf() - this.start.valueOf();
  }

  resume = () => {
    this.start = new Date();
    clearTimeout(this.timer_id);
    this.timer_id = setTimeout(this.callback, this.remaining);
  }
}
