# Inkscape Postscript Export in 2022

A lot of older guides using Inkscape to convert SVG images to PostScript
use a `-E` CLI flag that no longer exists in the Inkscape CLI:
~~`inkscape input.svg -E out.eps`~~.

**The correct way to do this in the *current* year:**
```
inkscape --export-type=eps -o out.eps in.svg
```

If you want to automatically convert all of the `.svg` files in your current
working directory to `.eps` files, you can use something like this script:
```bash
#!/usr/bin/env bash
for svg in *.svg; do
    bname=$(basename "$svg" | sed 's/\.svg$//g')
    echo "Converting \""$bname"\"..."
    echo -e "\tinkscape --export-type=eps -o \"$bname.eps\" \"$svg\""
    inkscape --export-type=eps -o "$bname.eps" "$svg"
done
```
