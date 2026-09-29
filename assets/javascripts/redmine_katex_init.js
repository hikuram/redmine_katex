(function () {
  "use strict";

  const katexOptions = {
    throwOnError: false,
    strict: "warn",
    trust: false,
    output: "htmlAndMathml",
    maxExpand: 1000,
    maxSize: 50
  };

  function renderRawDelimitedMath(root) {
    if (typeof window.renderMathInElement !== "function") return;

    window.renderMathInElement(root, Object.assign({}, katexOptions, {
      delimiters: [
        {left: "$$", right: "$$", display: true},
        {left: "\\[", right: "\\]", display: true},
        {left: "\\(", right: "\\)", display: false}
      ],
      ignoredTags: ["script", "noscript", "style", "textarea", "pre", "code", "option"],
      ignoredClasses: ["katex", "katex-display", "redmine-katex-rendered"]
    }));
  }

  function renderSemanticMath(root) {
    if (!window.katex || typeof window.katex.render !== "function") return;

    root.querySelectorAll('span[data-math-style]:not(.redmine-katex-rendered)').forEach(function (element) {
      const source = element.textContent || "";
      const displayMode = element.getAttribute("data-math-style") === "display";

      try {
        window.katex.render(source, element, Object.assign({}, katexOptions, {
          displayMode: displayMode
        }));
        element.classList.add("redmine-katex-rendered");
      } catch (error) {
        console.warn("[redmine_katex] KaTeX render failed", error);
      }
    });
  }

  function renderRedmineKatex(root) {
    if (!root || !window.katex) return;
    renderRawDelimitedMath(root);
    renderSemanticMath(root);
  }

  document.addEventListener("DOMContentLoaded", function() {
    renderRedmineKatex(document.body);

    // MutationObserver
    const observer = new MutationObserver(function(mutations) {
      mutations.forEach(function(mutation) {
        mutation.addedNodes.forEach(function(node) {
          if (node.nodeType === Node.ELEMENT_NODE) {
            renderRedmineKatex(node);
          }
        });
      });
    });
    observer.observe(document.body, { childList: true, subtree: true });
  });
})();
