let wid = null;
let x = 0;
let y = 0;
let mx = 0;
let my = 0;
let mvel = 0;
const lerp = 1.2;

const loop = () => {
  const dx = mx - x;
  const dy = my - y;
  const vel = Math.sqrt(dx * dx + dy * dy) / 70;
  const rot = Math.atan2(dy, dx);
  mvel -= (mvel - vel) / 2;
  mx -= (mx - x) / lerp;
  my -= (my - y) / lerp;

  const styleLeft = `${mx - 8}px`;
  const styleTop = `${my - 8}px`;
  const styleTransform = `rotate(${rot + Math.PI / 2}rad) scaleY(${1 + mvel})`;

  self.postMessage({
    styleLeft,
    styleTop,
    styleTransform,
  });
  setTimeout(loop, 25);
};

self.addEventListener('message', (e) => {
  const cmd = e.data.cmd;
  switch (cmd) {
    case 'start':
      wid = Math.round(Math.random() * 1000);
      setTimeout(loop, 25);
      break;
    case 'update':
      x = e.data.x;
      y = e.data.y;
      break;
    default:
      break;
  }
});
