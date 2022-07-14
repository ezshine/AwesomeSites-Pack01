let isRunning = false;
let timeO = null;

self.addEventListener('message', (e) => {
  const _ = e.data;

  if (isRunning) {
    clearTimeout(timeO);
  }

  let scrollOffset = _.scrollOffset;
  const selectedTeam = _.selectedTeam;
  const scrollgap = _.scrollgap;
  const teamsLength = _.teamsLength;

  const loop = () => {
    const halfScroll = scrollOffset - selectedTeam * scrollgap;
    scrollOffset -= halfScroll / 6;

    const introPlayerRotationY = -scrollOffset / scrollgap * Math.PI * 2 - Math.PI / 2;
    const localSelectedTeam = selectedTeam % teamsLength;

    for (let s = 0; s < teamsLength; s += 1) {
      // const z = s === localSelectedTeam ? 25 : -10;
      const ol = 10;
      const py =
        (-s * scrollgap + scrollOffset + scrollgap * ol) % (teamsLength * scrollgap) -
        scrollgap * ol;
      const z = Math.max(-10, 25 - Math.abs(py * 2));
      const matOpacity = Math.max(0, 1 - Math.abs(py / 40));

      self.postMessage({
        s,
        z,
        ol,
        py,
        matOpacity,
        introPlayerRotationY,
        scrollOffset,
      });
    }

    if (Math.abs(halfScroll) > 0.1) {
      timeO = setTimeout(loop, 20);
    } else {
      isRunning = false;
    }
  };

  isRunning = true;
  setTimeout(loop, 20);
});
