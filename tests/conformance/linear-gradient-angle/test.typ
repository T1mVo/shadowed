/// [max-delta: 8]

#import "../../../src/lib.typ": shadow

#let page-layout = (width: 100pt, height: 100pt, margin: 0pt)
#let angles = range(-720, 720, step: 135).map(i => i * 1deg)
#let test-gradients = angles.map(angle => gradient.linear(..color.map.rainbow, angle: angle))

#set page(..page-layout)

#for test-gradient in test-gradients [
  #page[
    #shadow(fill: test-gradient)[
      #block(width: 100%, height: 100%)
    ]
  ]
]
