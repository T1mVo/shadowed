// This example demonstrates different fill styles for shadows.

#import "../src/lib.typ": shadow

#set page(margin: 15pt, height: auto, width: auto)

#let shadow = shadow.with(blur: 3pt, block(width: 120pt, height: 120pt))
#let solid-color = color.teal
#let linear-gradient = gradient.linear(..color.map.rainbow, angle: 45deg)
#let radial-gradient = gradient.radial(..color.map.plasma, center: (40%, 40%))

#grid(
  columns: 3,
  align: center + horizon,
  inset: 5pt,
  shadow(fill: solid-color),
  shadow(fill: linear-gradient),
  shadow(fill: radial-gradient),

  "Solid color", "Linear gradient", "Radial gradient",
)
