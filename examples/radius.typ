// This example demonstrates custom per-corner radius control.

#import "../src/lib.typ": shadow

#set page(margin: 15pt, height: auto, width: auto)

#let custom-radius = (
  top-left: 0pt,
  top-right: 8pt,
  bottom-right: 0pt,
  bottom-left: 8pt,
)

#grid(
  columns: 2,
  align: center + horizon,
  inset: 10pt,
  // Uniform radius
  shadow(blur: 4pt, radius: 8pt)[
    #block(width: 100pt, height: 100pt, fill: white, radius: 8pt)
  ],
  // Custom per-corner radius
  shadow(
    blur: 4pt,
    radius: custom-radius,
  )[
    #block(
      width: 100pt,
      height: 100pt,
      fill: white,
      radius: custom-radius,
    )
  ],
  "Uniform radius",

  "Custom radius",
)
