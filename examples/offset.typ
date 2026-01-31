// This example demonstrates shadow offset using dx and dy parameters.

#import "../src/lib.typ": shadow

#set page(margin: 15pt, height: auto, width: auto)

#grid(
  columns: 2,
  align: center + horizon,
  inset: 10pt,
  // Shadow offset to the bottom-right
  shadow(dx: 1pt, dy: 1pt, blur: 4pt)[
    #block(width: 100pt, height: 100pt, fill: white)
  ],
  // Shadow offset to the top-left
  shadow(dx: -1pt, dy: -1pt, blur: 4pt)[
    #block(width: 100pt, height: 100pt, fill: white)
  ],
  "Bottom-right offset",

  "Top-left offset",
)
