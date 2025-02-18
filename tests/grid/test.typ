#import "../../src/lib.typ": shadowed

#set page(margin: 20pt, height: auto)

#set par(justify: true)

#let content = shadowed(radius: 4pt, inset: 12pt, shadow: 10pt)[
  #lorem(40)
]

#grid(
  columns: 2,
  content, content,
  grid.cell(colspan: 2, content),
)
