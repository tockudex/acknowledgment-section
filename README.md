acknowledgments-section
==================================================================

Filter that ensures that "Acknowledgments" sections are handled as expected.


Acknowledgments in a dedicated section
------------------------------------------------------------------

This filter allows to write document acknowledgments as normal sections in the main text. It moves any section titled "acknowledgments" from the main text into the metadata. Most output format templates expect the thanks section (acknowledgments) to be given as part of the metadata, but writing body text is easier and more natural. This extension is also written with `typst` in mind and allows for a personalised placement of the acknowledgments section where ever in the paper or report.

``` markdown
# Acknowledgments

Place acknowledgments here.

Multiple paragraphs are possible.
```

Without this filter, the acknowledgments would need to be placed in the document's metadata. The additional indentation and formatting requirements in YAML headers are frequently perceived as confusing or annoying, especially when writing longer texts.

``` yaml
---
acknowledgments: |
  Place acknowledgments here.

  Multiple paragraphs are possible.
---
```


This filter modifies the document such that the acknowledgments section behaves as if it was passed as metadata. It does so by looking for a top-level header whose ID is `acknowledgments`. Pandoc auto-creates IDs based on header contents, so a header titled *Acknowledgment* will satisfy this condition.^[1]

[1]: This requires the `auto_identifier` extension. It is
     enabled by default.

The Acknowledgments can be placed anywhere in the document.

The filter assumes that the acknowledgments runs up until the next heading.


Usage
------------------------------------------------------------------

The filter modifies the internal document representation; it can
be used with many publishing systems that are based on pandoc.

### Plain pandoc

Pass the filter to pandoc via the `--lua-filter` (or `-L`) command
line option.

    pandoc --lua-filter acknowledgments-section.lua ...

### Quarto

Users of Quarto can install this filter as an extension with

    quarto install extension tockudex/acknowledgments-section

and use it by adding `acknowledgments-section` to the `filters` entry in their YAML header.

``` yaml
---
filters:
  - acknowledgments-section
---
```

### R Markdown

Use `pandoc_args` to invoke the filter. See the [R Markdown
Cookbook](https://bookdown.org/yihui/rmarkdown-cookbook/lua-filters.html)
for details.

``` yaml
---
output:
  word_document:
    pandoc_args: ['--lua-filter=acknowledgments-section.lua']
---
```


License
------------------------------------------------------------------

This pandoc Lua filter is published under the MIT license, see
file `LICENSE` for details.
