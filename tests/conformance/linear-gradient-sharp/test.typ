/// [max-delta: 34]
/// [max-deviations: 1000]
#import "../../../src/lib.typ": shadow

#let page-layout = (width: 100pt, height: 100pt, margin: 0pt)
#let steps = range(2, 7)
#let smoothness-ratios = range(0, 25, step: 5).map(i => i * 1%)
#let test-gradients = steps.zip(smoothness-ratios.rev()).map(i => gradient.linear(red, green).sharp(i.at(0), smoothness: i.at(1)))

#set page(..page-layout)

#for test-gradient in test-gradients [
  #page[
    #shadow(fill: test-gradient)[
      #block(width: 100%, height: 100%)
    ]
  ]
]
