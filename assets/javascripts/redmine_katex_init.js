
function renderRedmineKatex() {
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
