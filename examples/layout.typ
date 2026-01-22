// This example shows how to apply a padding around the shadow so that it affects the layout.
// Rule of thumb is padding = blur + spread.

#import "../src/lib.typ": shadow

#set page(margin: 15pt, height: auto, width: auto)

// Visualize padding around shadow. This is not part of the example.
#show: it => [
  #block(stroke: (paint: black, thickness: 0.3pt, dash: "densely-dashed"))[
    #it
  ]
]

#let blur = 4pt
#let spread = 2pt

// Padding has to consist of the blur + the spread.
#pad(blur + spread)[
  #shadow(blur: blur, spread: spread)[
    #block(height: 20pt, width: 20pt, fill: white)
  ]
]
