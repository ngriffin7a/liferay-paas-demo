  document.addEventListener('mousemove', function(e) {
    const flyout = document.querySelector('.menu-flyout');

    if (e.clientX <= 10) {
      flyout.style.left = '0';
    } else if (e.clientX > 250) {
      flyout.style.left = '-250px';
    }
  });