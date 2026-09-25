#!/bin/sh
katexVersion=0.16.9
katexURL=https://github.com/KaTeX/KaTeX/releases/download/v$katexVersion/katex.tar.gz

mkdir -p assets/javascripts/katex
mkdir -p assets/stylesheets/katex

mkdir katexTmp
cd katexTmp

wget -O katex.tar.gz $katexURL
tar xzf katex.tar.gz --strip-components=1

cp katex.min.js ../assets/javascripts/katex/
cp contrib/auto-render.min.js ../assets/javascripts/katex/
cp contrib/mhchem.min.js ../assets/javascripts/katex/
cp -R fonts ../assets/stylesheets/katex/
cp katex.min.css ../assets/stylesheets/katex/

cd ..
rm -rf katexTmp
echo "KaTeX downloaded successfully."
