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

  const displayMathSelector = 'span[data-math-style="display"]:not(.redmine-katex-rendered)';
  const editorExclusionSelector = '.monaco-editor-container, .monaco-editor';

  function isEditorDom(node) {
    if (!node || node.nodeType !== Node.ELEMENT_NODE) return false;

    return node.matches(editorExclusionSelector) ||
      (typeof node.closest === "function" && node.closest(editorExclusionSelector) !== null);
  }

  function renderRawDelimitedMath(root) {
    if (typeof window.renderMathInElement !== "function") return;

    window.renderMathInElement(root, Object.assign({}, katexOptions, {
      delimiters: [
        {left: "$$", right: "$$", display: true}
      ],
      ignoredTags: ["script", "noscript", "style", "textarea", "pre", "code", "option"],
      ignoredClasses: ["katex", "katex-display", "redmine-katex-rendered", "monaco-editor-container", "monaco-editor"]
    }));
  }

  function renderSemanticElement(element) {
    if (isEditorDom(element)) return;

    const source = element.textContent || "";

    try {
      window.katex.render(source, element, Object.assign({}, katexOptions, {
        displayMode: true
      }));
      element.classList.add("redmine-katex-rendered");
    } catch (error) {
      console.warn("[redmine_katex] KaTeX render failed", error);
    }
  }

  function renderSemanticMath(root) {
    if (!window.katex || typeof window.katex.render !== "function") return;

    if (root.nodeType === Node.ELEMENT_NODE && root.matches(displayMathSelector) && !isEditorDom(root)) {
      renderSemanticElement(root);
    }

    if (typeof root.querySelectorAll === "function") {
      root.querySelectorAll(displayMathSelector).forEach(function (element) {
        if (!isEditorDom(element)) renderSemanticElement(element);
      });
    }
  }

  function renderRedmineKatex(root) {
    if (!root || !window.katex) return;
    if (isEditorDom(root)) return;

    // Activity and other views that bypass CommonMark may contain raw $$...$$.
    renderRawDelimitedMath(root);

    // The isolated formatter emits semantic display-math spans. Preview HTML
    // added after page load is handled by the same function via MutationObserver.
    renderSemanticMath(root);
  }

  document.addEventListener("DOMContentLoaded", function () {
    renderRedmineKatex(document.body);

    const observer = new MutationObserver(function (mutations) {
      mutations.forEach(function (mutation) {
        mutation.addedNodes.forEach(function (node) {
          if (node.nodeType === Node.ELEMENT_NODE && !isEditorDom(node)) {
            renderRedmineKatex(node);
          }
        });
      });
    });

    observer.observe(document.body, {childList: true, subtree: true});
  });
})();
