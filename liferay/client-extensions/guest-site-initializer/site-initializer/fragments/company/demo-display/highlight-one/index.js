var highlightOneElements = document.querySelectorAll("." + configuration.itemClassName);

highlightOneElements.forEach(function(highlightOne) {
  highlightOne.addEventListener("click", function() {
    highlightOneElements.forEach(function(element) {
      element.style.opacity = configuration.opacity;
    });

    this.style.opacity = 1;
  });
});