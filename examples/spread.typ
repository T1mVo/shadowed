// This example demonstrates the spread parameter.

#import "../src/lib.typ": shadow

#set page(margin: 15pt, height: auto, width: auto)

#grid(
  columns: 3,
  align: center + horizon,
  inset: 10pt,
  // Positive spread makes the shadow larger
  shadow(blur: 4pt, spread: 2pt)[
    #block(width: 100pt, height: 100pt, fill: white)
  ],
  // No spread
  shadow(blur: 4pt, spread: 0pt)[
    #block(width: 100pt, height: 100pt, fill: white)
  ],
  // Negative spread makes the shadow smaller
  shadow(blur: 4pt, spread: -2pt)[
    #block(width: 100pt, height: 100pt, fill: white)
  ],
  "Positive spread", "No spread", "Negative spread",
)