# Redmine KaTeX

**Version 1.0.0**

Self-contained KaTeX math rendering for **Redmine 7.0+** using an isolated
CommonMark formatter. The plugin does not modify Redmine's built-in
`common_mark` formatter and does not require a CDN or additional server-side
Ruby gems.

## Features

- Inline math with `$...$`
- Display math with `$$...$$`
- KaTeX rendering for issue descriptions, wiki pages, and other formatted text
- Auto-render support for views that bypass the CommonMark formatter, such as
  Activity
- `mhchem` support for chemistry notation such as `\ce{...}` and `\pu{...}`
- Local KaTeX assets; no external CDN dependency
- No database migration and no rewriting of issue, journal, or wiki source text
- Redmine's standard `common_mark` formatter remains untouched

## Requirements

- Redmine **7.0 or later**
- A current browser with WOFF2 support

The bundled KaTeX runtime is **v0.18.9**.

## Installation

1. Copy this directory to Redmine as:

   ```text
   plugins/redmine_katex
   ```

2. Restart Redmine or rebuild/restart the Redmine container as appropriate for
   your installation.

3. Confirm that the Redmine log contains:

   ```text
   [redmine_katex] formatter common_mark_katex registered
   ```

4. Open:

   ```text
   Administration -> Settings -> General -> Text formatting
   ```

5. Select:

   ```text
   CommonMark Markdown + KaTeX
   ```

No plugin migration is required.

### Database impact

Registering the formatter does not change the database schema. Selecting the
formatter stores Redmine's normal `Setting.text_formatting` value as
`common_mark_katex`.

The plugin does **not** rewrite existing issue descriptions, journal entries,
or wiki source text.

## Usage

### Inline math

```markdown
Activation energy $E_{\mathrm{a}}$ was evaluated.
```

### Display math

```markdown
$$ A \rightleftharpoons B $$
```

TeX spacing commands are preserved by the KaTeX-aware CommonMark formatter:

```markdown
$$ A\,B $$
```

For example:

```markdown
$$ \mathrm{Si{-}NH_2 + HCOOH \rightleftharpoons Si{-}NH_3^+\,HCOO^-} $$
```

### Chemistry notation

The bundled `mhchem` extension enables syntax such as:

```markdown
$$ \ce{CO2 + H2 -> HCOOH} $$
```

## Safe removal

> **Important:** Do not remove the plugin while Redmine's Text formatting
> setting is still `CommonMark Markdown + KaTeX`.

Before removing or disabling the plugin:

1. Open `Administration -> Settings -> General`.
2. Change **Text formatting** back to Redmine's standard
   `CommonMark Markdown (GitHub Flavored)` formatter.
3. Save the setting.
4. Restart Redmine if required by your deployment.
5. Remove `plugins/redmine_katex` and rebuild/restart the image or container as
   appropriate.

If the plugin is removed while `Setting.text_formatting` still points to
`common_mark_katex`, Redmine does not automatically switch the saved setting
back to standard CommonMark. Restore the standard formatter before removal.

## How it works

The plugin registers a separate formatter:

```text
common_mark        Redmine standard formatter
common_mark_katex  CommonMark Markdown + KaTeX
```

The standard Redmine formatter is left unchanged.

For `common_mark_katex`, CommonMarker's `math_dollars` extension identifies
`$...$` and `$$...$$` before ordinary Markdown escaping can alter TeX commands
such as `\,`. The formatter uses its own sanitizer instance to preserve the
resulting `data-math-style` marker. Browser-side code then renders these
semantic math nodes directly with KaTeX.

Views that do not pass through the CommonMark formatter may still contain raw
math delimiters. KaTeX auto-render handles those separately.

Because the formatter name differs from Redmine's standard `common_mark`,
Redmine also keeps its formatted-text cache separate for the two formatters.

## Bundled KaTeX assets

This distribution includes a reduced browser-runtime subset of **KaTeX
v0.18.9**:

```text
katex.min.js
katex.min.css
auto-render.min.js
mhchem.min.js
KaTeX WOFF2 fonts
```

The package intentionally omits artifacts that are not used by this plugin,
including:

- non-minified JavaScript and CSS builds
- ESM builds
- unused contrib modules
- duplicate WOFF and TTF font files

All KaTeX font families are retained; only the font **format** is reduced to
WOFF2. The bundled KaTeX CSS differs from the supplied v0.18.9 distribution
only by removing WOFF and TTF fallback URLs from its `@font-face` rules.

This keeps the browser assets at roughly **0.6 MB uncompressed** while retaining
KaTeX's normal math font coverage.

## KaTeX license and provenance

KaTeX is distributed under the **MIT License**.

The full upstream license is included at:

```text
vendor/katex/LICENSE
```

Additional package-level license information is in:

```text
THIRD_PARTY_LICENSES.md
```

The exact bundled KaTeX version, source archive provenance, retained runtime
subset, and SHA-256 hashes are recorded in:

```text
vendor/katex/VERSION
vendor/katex/SOURCE.md
```

The KaTeX assets are bundled locally; normal plugin operation does not contact
KaTeX.org or a public CDN.

## Diagnostics

### Formatter registration

A successful Redmine startup should log:

```text
[redmine_katex] formatter common_mark_katex registered
```

### CommonMark math nodes

Before browser-side rendering, formatted pages using this formatter may contain
semantic elements such as:

```html
<span data-math-style="display">...</span>
```

To inspect them in the browser console:

```javascript
document.querySelectorAll('[data-math-style]').length
```

After rendering, semantic nodes rendered directly by the plugin receive the
class:

```text
redmine-katex-rendered
```

### Asset version

The vendored KaTeX version is also recorded in:

```text
vendor/katex/VERSION
```

## Notes and limitations

- KaTeX supports a large subset of TeX/LaTeX math syntax, not every MathJax or
  full LaTeX command.
- The bundled fonts are WOFF2-only. This targets current Chrome, Edge, Firefox,
  and Safari rather than legacy browsers.
- JavaScript must be enabled for math rendering.
- This plugin intentionally avoids monkey-patching Redmine's standard
  `common_mark` formatter, global sanitizer, or `ApplicationHelper`.

## Release history

### v1.0.0

Initial release of the Redmine 7 independent-formatter edition.

- Added isolated `common_mark_katex` formatter
- Added CommonMarker `math_dollars` handling
- Added local KaTeX v0.18.9 runtime assets
- Added `mhchem` support
- Added WOFF2-only KaTeX font packaging
- Added explicit KaTeX MIT license and source provenance
