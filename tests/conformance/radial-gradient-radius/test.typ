/// [max-delta: 19]
/// [max-deviations: 45]

#import "../../../src/lib.typ": shadow

#let page-layout = (width: 100pt, height: 100pt, margin: 0pt)
#let radii = range(1, 150, step: 50).map(i => i * 1%)
#let test-gradients = radii.map(radius => gradient.radial(..color.map.rainbow, radius: radius))

#set page(..page-layout)

#for test-gradient in test-gradients [
  #page[
    #shadow(fill: test-gradient)[
      #block(width: 100%, height: 100%)
    ]
  ]
]
