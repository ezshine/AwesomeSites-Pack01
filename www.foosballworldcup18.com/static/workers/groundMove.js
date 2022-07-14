self.addEventListener('message', () => {
  let time = 0;

  const loop = () => {
    time += 0.04;
    self.postMessage({
      time,
    });
    setTimeout(loop, 25);
  };

  setTimeout(loop, 25);
});
