/// [max-delta: 21]

#import "../../../src/lib.typ": shadow

#let page-layout = (width: 100pt, height: 100pt, margin: 0pt)
#let center-x = range(-25, 150, step: 25).map(i => i * 1%)
#let center-y = range(-25, 150, step: 25).map(i => i * 1%)
#let test-gradients = center-x.zip(center-y).map(center => gradient.radial(..color.map.rainbow, center: center))

#set page(..page-layout)

#for test-gradient in test-gradients [
  #page[
    #shadow(fill: test-gradient)[
      #block(width: 100%, height: 100%)
    ]
  ]
]
