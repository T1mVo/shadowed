/// [max-delta: 21]

#import "../../../src/lib.typ": shadow

#let page-layout = (width: 100pt, height: 100pt, margin: 0pt)
#let test-gradient = gradient.radial(..color.map.rainbow)

#set page(..page-layout)

#shadow(fill: test-gradient)[
  #block(width: 100%, height: 100%)
]
