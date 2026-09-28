# Redmine KaTeX

KaTeX math rendering for **Redmine 7** without modifying Redmine's built-in
`common_mark` formatter.

## Design

The plugin registers a separate text formatter:

- Redmine standard: `common_mark`
- This plugin: `common_mark_katex` (**CommonMark Markdown + KaTeX**)

The built-in CommonMark `PIPELINE_CONFIG`, `SANITIZER`, `ApplicationHelper`, and
other Redmine core classes are not monkey-patched.

`common_mark_katex` enables CommonMarker's `math_dollars` extension and uses a
private sanitizer instance that preserves only the generated
`data-math-style` attribute on `span` elements. The browser renders these spans
directly with KaTeX.

Pages such as Activity that bypass the CommonMark formatter may still contain
raw `$...$` / `$$...$$`; the bundled auto-render script handles those separately.

## Installation

Copy the directory to:

```text
plugins/redmine_katex
```

and restart/rebuild Redmine normally. No database migration is provided or
required.

Then open:

```text
Administration -> Settings -> General -> Text formatting
```

and choose:

```text
CommonMark Markdown + KaTeX
```

The only database change made by enabling the formatter is Redmine's normal
`Setting.text_formatting` value. Issue, journal, and wiki source text is not
rewritten.

### Removing the plugin

1. Change **Text formatting** back to `CommonMark Markdown (GitHub Flavored)`.
2. Restart Redmine.
3. Remove `plugins/redmine_katex`.

Do not remove the plugin while `Setting.text_formatting` still points to
`common_mark_katex`.

## Math syntax

Inline:

```text
Activation energy $E_{\mathrm{a}}$ was evaluated.
```

Display:

```text
$$ A \rightleftharpoons B $$
```

Spacing commands are preserved by CommonMarker's math parser, for example:

```text
$$ A\,B $$
```

and:

```text
$$ \mathrm{Si{-}NH_2 + HCOOH \rightleftharpoons Si{-}NH_3^+\,HCOO^-} $$
```

## KaTeX assets and license

This package is self-contained; it does not use a CDN. It bundles KaTeX
**0.18.9** from the supplied distribution archive.

The runtime vendor subset contains:

- `katex.min.js`
- `katex.min.css`
- `contrib/auto-render.min.js`
- `contrib/mhchem.min.js`
- all KaTeX font families as WOFF2

The WOFF and TTF duplicates, non-minified/ESM builds, alternate CSS, and unused
contrib modules are not bundled. The KaTeX CSS differs from the supplied
0.18.9 CSS only in its `@font-face` declarations: WOFF/TTF fallback URLs are
removed so the plugin is WOFF2-only. This is suitable for current Chrome,
Edge, Firefox, and Safari; keep the full font-format set if legacy-browser
support is required.

`mhchem.min.js` is retained because the original plugin supported it and it
adds chemistry commands such as `\ce{...}` and `\pu{...}` at modest size
cost.

KaTeX is distributed under the MIT License. The full license text and source
provenance are included at:

- `vendor/katex/LICENSE`
- `vendor/katex/SOURCE.md`

See `THIRD_PARTY_LICENSES.md` for the package-level notice.

## Diagnostics

On boot, a successful registration logs:

```text
[redmine_katex] formatter common_mark_katex registered
```

In a page using the KaTeX formatter, CommonMarker-generated math should remain
as:

```html
<span data-math-style="display">...</span>
```

until `redmine_katex_init.js` renders it.

Useful browser check:

```javascript
document.querySelectorAll('[data-math-style]').length
```

After KaTeX runs, the outer semantic spans remain but also have class
`redmine-katex-rendered`.
