#!/bin/sh
set -eu

# Optional vendor refresh helper. It downloads the official KaTeX release,
# vendors only the browser runtime used by this plugin, and keeps WOFF2 fonts.
katexVersion=0.18.9
katexURL="https://github.com/KaTeX/KaTeX/releases/download/v${katexVersion}/katex.tar.gz"

root_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT INT TERM

rm -rf "$root_dir/assets/javascripts/katex" \
       "$root_dir/assets/stylesheets/katex" \
       "$root_dir/vendor/katex"
mkdir -p "$root_dir/assets/javascripts/katex" \
         "$root_dir/assets/stylesheets/katex/fonts" \
         "$root_dir/vendor/katex"

wget -O "$tmp_dir/katex.tar.gz" "$katexURL"
tar xzf "$tmp_dir/katex.tar.gz" -C "$tmp_dir" --strip-components=1

cp "$tmp_dir/katex.min.js" "$root_dir/assets/javascripts/katex/"
cp "$tmp_dir/contrib/auto-render.min.js" "$root_dir/assets/javascripts/katex/"
cp "$tmp_dir/contrib/mhchem.min.js" "$root_dir/assets/javascripts/katex/"
cp "$tmp_dir/katex.min.css" "$root_dir/assets/stylesheets/katex/"
cp "$tmp_dir"/fonts/*.woff2 "$root_dir/assets/stylesheets/katex/fonts/"
cp "$tmp_dir/LICENSE" "$root_dir/vendor/katex/LICENSE"
printf '%s\n' "$katexVersion" > "$root_dir/vendor/katex/VERSION"

ruby - "$root_dir/assets/stylesheets/katex/katex.min.css" <<'RUBY_INNER'
path = ARGV.fetch(0)
css = File.binread(path)
pattern = /src:url\(([^)]*\.woff2)\) format\("woff2"\),url\([^)]*\.woff\) format\("woff"\),url\([^)]*\.ttf\) format\("truetype"\)/
count = 0
css = css.gsub(pattern) do
  count += 1
  "src:url(#{$1}) format(\"woff2\")"
end
abort "expected 20 KaTeX font-face rewrites, got #{count}" unless count == 20
File.binwrite(path, css)
RUBY_INNER

echo "KaTeX ${katexVersion} slim runtime vendored successfully."
