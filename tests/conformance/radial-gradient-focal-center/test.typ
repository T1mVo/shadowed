/// [max-delta: 40]
/// [max-deviations: 100]

#import "../../../src/lib.typ": shadow

#let page-layout = (width: 100pt, height: 100pt, margin: 0pt)
#let focal-center-x = range(27, 73, step: 15).map(i => i * 1%)
#let focal-center-y = range(27, 73, step: 15).map(i => i * 1%)
#let test-gradients = focal-center-x.zip(focal-center-y).map(focal-center => gradient.radial(..color.map.rainbow, focal-center: focal-center))

#set page(..page-layout)

#for test-gradient in test-gradients [
  #page[
    #shadow(fill: test-gradient)[
      #block(width: 100%, height: 100%)
    ]
  ]
]
