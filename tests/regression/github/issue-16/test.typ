#import "../../../../src/lib.typ": shadow

#set page(width: 50em, height: auto, margin: 2em)

#shadow(
  inset: true,
  dx: -4pt,
  dy: 4pt,
  blur: 8pt,
  fill: rgb(89, 85, 101, 25%),
  radius: 4pt,
)[
  #block(inset: 10pt, radius: 4pt)[
    #shadow(
      dx: -4pt,
      dy: 4pt,
      blur: 8pt,
      fill: rgb(89, 85, 101, 25%),
      radius: 4pt,
    )[
      #block(radius: 4pt, fill: luma(255), inset: 10pt, lorem(40))
    ]
    #shadow(
      dx: -4pt,
      dy: 4pt,
      blur: 8pt,
      fill: rgb(89, 85, 101, 25%),
      radius: 4pt,
    )[
      #block(radius: 4pt, fill: luma(255), inset: 10pt, lorem(40))
    ]
  ]]
