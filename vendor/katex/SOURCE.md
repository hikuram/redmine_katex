# KaTeX vendor source

Bundled KaTeX version: **0.18.9**

Source for this package: user-supplied `katex.zip` used for this rebuild.
The supplied distribution identifies itself as KaTeX 0.18.9.

SHA-256:

- archive `katex.zip`: `33510a881c2e436535f4a09d58ff2fb5efbb3fa708aad8db9c8e1cf0a7ae442b`
- `katex.min.js`: `155f6c2d673c5912e3b48f45d8830eaad18ae1953915939ceb648ea8b9c3e7e2`
- upstream `katex.min.css`: `b9ce0e8ce93f0c18c4986fe1f1c3c269d921b56a69e6c97f83a507916b38aab5`
- `contrib/auto-render.min.js`: `e5372d199bcdae8b4de71d0f7ceba72a4ba12774a27c60a6f1f77d03b3228ee4`
- `contrib/mhchem.min.js`: `aaf20145c0b8ecd450ccf6eb0cebece2f77d8e6a02c30d291f28c1167b57b2df`

## Runtime subset retained

- `katex.min.js`
- `katex.min.css`
- `contrib/auto-render.min.js`
- `contrib/mhchem.min.js`
- all 20 KaTeX font families in WOFF2 format
- KaTeX MIT license

The bundled CSS is derived from the supplied 0.18.9 `katex.min.css` only by
removing the WOFF and TTF fallback entries from each `@font-face` `src` list.
All other CSS is unchanged. This makes the package WOFF2-only.

Excluded as unnecessary for this Redmine plugin: unminified JS/CSS, ESM builds,
`katex-swap*`, `copy-tex`, `render-a11y-string`, `mathtex-script-type`, WOFF,
and TTF font copies.
