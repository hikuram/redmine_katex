# Third-party software

## KaTeX

- Project: KaTeX
- Bundled version: **0.18.9**
- License: **MIT**
- Upstream project: https://github.com/KaTeX/KaTeX

This plugin redistributes a browser-runtime subset of KaTeX v0.18.9:

- `katex.min.js`
- `katex.min.css`
- `contrib/auto-render.min.js`
- `contrib/mhchem.min.js`
- all KaTeX font families in WOFF2 format

The full KaTeX MIT License is included at:

```text
vendor/katex/LICENSE
```

Source provenance, the bundled version, and SHA-256 hashes are recorded in:

```text
vendor/katex/SOURCE.md
vendor/katex/VERSION
```

For package-size reduction, the bundled CSS has been modified only to remove
WOFF and TTF fallback font URLs from `@font-face` rules. The corresponding WOFF
and TTF files, non-minified/ESM builds, and unused distribution artifacts are
not redistributed. No KaTeX JavaScript source behavior is modified by this
packaging step.
