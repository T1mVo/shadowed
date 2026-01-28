# shadowed

Box shadows for [Typst](https://typst.app/).

## Usage

```typ
#import "@preview/shadowed:0.3.0": shadow

#set par(justify: true)

#shadow(blur: 8pt, fill: rgb(89, 85, 101, 25%), radius: 4pt)[
  #block(fill: white, radius: 4pt, inset: 12pt)[
    #lorem(50)
  ]
]
```

![Example](examples/lorem.png)

## Parameters

```typ
/// A drop shadow.
/// -> content
#let shadow(
  /// The horizontal offset.
  /// -> length
  dx: 0pt,
  /// The vertical offset.
  /// -> length
  dy: 0pt,
  /// How strong to blur the shadow.
  /// 
  /// Must be equal to or greater than 0pt.
  /// 
  /// -> length
  blur: 0pt,
  /// How far to spread the length of the shadow.
  /// -> length
  spread: 0pt,
  /// How to fill the shadow.
  /// 
  /// Currently only supports linear or radial gradients.
  /// 
  /// -> color | gradient | none
  fill: black,
  /// How much to round the shadow's corners.
  /// 
  /// Can be either:
  /// - A relative length for a uniform corner radius.
  /// 
  /// - A dictionary: With a dictionary, the stroke for each side can be set individually.
  ///   The dictionary can contain the following keys in order of precedence:
  ///   - top-left: The top-left corner radius.
  ///   - top-right: The top-right corner radius.
  ///   - bottom-right: The bottom-right corner radius.
  ///   - bottom-left: The bottom-left corner radius.
  ///   - left: The top-left and bottom-left corner radii.
  ///   - top: The top-left and top-right corner radii.
  ///   - right: The top-right and bottom-right corner radii.
  ///   - bottom: The bottom-left and bottom-right corner radii.
  ///   - rest: The radii for all corners except those for which the dictionary explicitly sets a size.
  /// 
  /// -> length | dictionary
  radius: 0pt,
  /// The content to place in front of the shadow.
  /// -> content
  body,
) = { ... }
```

## Credits

This project was inspired by [Harbinger](https://github.com/typst-community/harbinger).
