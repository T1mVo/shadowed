/// [skip]

#import "../../../src/lib.typ": shadow

#let page-layout = (width: 100pt, height: 100pt, margin: 0pt)
#let focal-radius = range(1, 50, step: 10).map(i => i * 1%)
#let test-gradients = focal-radius.map(radius => gradient.radial(..color.map.rainbow, focal-radius: radius))

#set page(..page-layout)

#for test-gradient in test-gradients [
  #page[
    #shadow(fill: test-gradient)[
      #block(width: 100%, height: 100%)
    ]
  ]
]
