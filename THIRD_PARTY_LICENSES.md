# Third-party software

## KaTeX

- Project: KaTeX
- Bundled version: **0.18.9**
- License: MIT
- Upstream: https://github.com/KaTeX/KaTeX

This plugin redistributes a browser-runtime subset of KaTeX 0.18.9:
`katex.min.js`, `katex.min.css`, `auto-render.min.js`, `mhchem.min.js`, and all
KaTeX font families in WOFF2 format.

The full KaTeX MIT license is included at `vendor/katex/LICENSE`.
Source provenance and SHA-256 hashes are recorded in `vendor/katex/SOURCE.md`.

For size reduction, the bundled CSS has been modified only to remove WOFF and
TTF fallback font URLs from `@font-face` rules. The corresponding WOFF and TTF
files and other unused distribution artifacts are omitted. This modification
and redistribution are permitted under the MIT License.
