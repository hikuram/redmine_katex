function renderRedmineKatex() {
  document.querySelectorAll('span[data-math-style]').forEach(function(el) {
    var isDisplay = el.getAttribute('data-math-style') === 'display';
    try {
      katex.render(el.textContent, el, {
        displayMode: isDisplay,
        throwOnError: false
      });
    } catch(e) { console.error(e); }
  });

  if (typeof renderMathInElement !== "undefined") {
    renderMathInElement(document.body, {
      delimiters: [
        {left: "$$", right: "$$", display: true},
        {left: "$", right: "$", display: false},
        {left: "\\[", right: "\\]", display: true},
        {left: "\\(", right: "\\)", display: false}
      ],
      throwOnError: false
    });
  }
}

document.addEventListener("DOMContentLoaded", renderRedmineKatex);

if (typeof jQuery !== "undefined") {
  jQuery(document).ajaxComplete(renderRedmineKatex);
}
