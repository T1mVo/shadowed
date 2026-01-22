/// [max-delta: 18]
/// [max-deviations: 600]
#import "../../../src/lib.typ": shadow

#let page-layout = (width: 100pt, height: 100pt, margin: 0pt)
#let color-spaces = (
  color.luma,
  color.oklab,
  color.oklch,
  color.linear-rgb,
  color.rgb,
  color.cmyk,
  color.hsl,
  color.hsv,
)
#let test-gradients = color-spaces.map(space => gradient.linear(red, green, space: space))

#set page(..page-layout)

#for test-gradient in test-gradients [
  #page[
    #shadow(fill: test-gradient)[
      #block(width: 100%, height: 100%)
    ]
  ]
]
