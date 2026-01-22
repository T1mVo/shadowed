#import "../../src/lib.typ": shadow

#set page(margin: 20pt, height: auto)

#set par(justify: true)

#let radius = 6pt
#let spread = 2pt
#let blur = 4pt
#let padding = spread + blur

#let content = pad(padding)[
  #shadow(radius: radius, spread: spread, blur: blur, fill: rgb(89, 85, 101, 25%))[
    #block(radius: radius, inset: 12pt, fill: white)[
      #lorem(40)
    ]
  ]
]

#grid(
  columns: 2,
  content, content,
  grid.cell(colspan: 2, content),
)
