let mx = 0;
let my = 0;
let mxr = 0;
let myr = 0;
let style = '';
let started = false;
let perspective = 70;

const toPrecise = x => Math.round(x * 1000) / 1000;

const loop = () => {
  if (mx !== undefined && mx !== undefined) {
    mxr -= (mxr - mx) / 5;
    myr -= (myr - my) / 5;
    style = `perspective(${perspective}px) 
              rotateX(${toPrecise(myr)}deg) 
              rotateY(${toPrecise(mxr)}deg)`;
  }
  self.postMessage({
    style,
  });
  setTimeout(loop, 25);
};

self.addEventListener('message', (e) => {
  const _ = e.data;
  perspective = _.perspective;
  mx = Math.round((_.offsetX - _.offsetWidth / 2) / 8);
  my = -Math.round((_.offsetY - _.offsetHeight / 2) / 6);
  if (!started) {
    started = true;
    setTimeout(loop, 25);
  }
});
