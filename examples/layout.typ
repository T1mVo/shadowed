// This example shows how to apply a padding around the shadow so that it affects the layout.
// Rule of thumb is padding = blur + spread.

#import "../src/lib.typ": shadow

#set page(margin: 15pt, height: auto, width: auto)

// Visualize layout around shadow. This is not part of the example.
#let visualize-layout(it) = block(
  stroke: (paint: red, thickness: 4pt),
  inset: 2pt,
)[
  #it
]

#let blur = 4pt
#let spread = 2pt

#let with-affecting-layout = pad(blur + spread)[
  #shadow(blur: blur, spread: spread)[
    #block(height: 120pt, width: 120pt, fill: white)
  ]
]

#let without-affecting-layout = shadow(blur: blur, spread: spread)[
  #block(height: 120pt, width: 120pt, fill: white)
]


#grid(
  columns: 2,
  align: center + horizon,
  inset: 5pt,
  visualize-layout(with-affecting-layout),
  visualize-layout(without-affecting-layout),

  "With affecting layout", "Without affecting layout",
)

