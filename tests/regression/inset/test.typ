#import "../../../src/lib.typ": shadow

#set page(width: 210pt, height: auto, margin: 5pt)

#let radius = 8pt
#let box-fill = rgb(255, 255, 255, 150)
#let shadow-fill = rgb(0, 0, 0, 180)

#grid(
  columns: 3,
  align: center,
  gutter: 5pt,
  [
    #shadow(
      inset: true,
      dx: 3pt,
      dy: 3pt,
      blur: 4pt,
      spread: 2pt,
      radius: radius,
      fill: shadow-fill,
    )[
      #block(width: 40pt, height: 40pt, fill: box-fill, radius: radius)
    ]
  ],
  [
    #shadow(
      inset: true,
      dx: -3pt,
      dy: -3pt,
      blur: 4pt,
      spread: 2pt,
      radius: radius,
      fill: shadow-fill,
    )[
      #block(width: 40pt, height: 40pt, fill: box-fill, radius: radius)
    ]
  ],
  [
    #shadow(
      inset: true,
      blur: 4pt,
      spread: -2pt,
      radius: radius,
      fill: shadow-fill,
    )[
      #block(width: 40pt, height: 40pt, fill: box-fill, radius: radius)
    ]
  ],

  [
    #shadow(
      inset: true,
      dx: 3pt,
      dy: 3pt,
      blur: 4pt,
      spread: 2pt,
      radius: radius,
      fill: gradient.linear(red, blue),
    )[
      #block(width: 40pt, height: 40pt, fill: box-fill, radius: radius)
    ]
  ],
  [
    #shadow(
      inset: true,
      dx: 3pt,
      dy: 3pt,
      blur: 4pt,
      spread: 2pt,
      fill: shadow-fill,
    )[
      #block(width: 40pt, height: 40pt, fill: box-fill)
    ]
  ],
)
