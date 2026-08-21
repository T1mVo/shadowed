#import "../../../src/lib.typ": shadow

#set page(margin: 20pt, height: auto)

#let item(spread: 0pt) = pad(14pt)[
  #shadow(spread: spread, blur: 4pt, fill: rgb(89, 85, 101, 25%), radius: 4pt)[
    #block(width: 100pt, height: 100pt, fill: white, radius: 4pt)
  ]
]

#grid(
  columns: 2,
  align: center + horizon,
  item(spread: (bottom: 10pt)), item(spread: (right: 10pt)),
  item(spread: (top: 2pt, right: 8pt, bottom: 10pt, left: -4pt)),
  item(spread: (top: -30pt, bottom: -30pt)),

  item(spread: (x: 6pt, y: 2pt)), item(spread: (left: 4pt, x: 8pt)),
)
