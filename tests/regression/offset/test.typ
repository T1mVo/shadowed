#import "../../../src/lib.typ": shadow

#set page(margin: 10pt, width: 200pt, height: auto)

#let item(dx, dy, text) = [
  #let blur = 4pt
  #let spread = 1pt
  #let radius = 4pt
  #pad(blur + spread)[
    #shadow(dx: dx, dy: dy, blur: blur, spread: spread, fill: rgb(89, 85, 101, 25%), radius: radius)[
      #block(width: 100%, fill: white, inset: 10pt, radius: radius)[
        #text
      ]
    ]
  ]
]

#grid(
  columns: 2,
  rows: 2,
  align: center,
  item(-1pt, -1pt, "Top left"), item(1pt, -1pt, "Top right"),
  item(-1pt, 1pt, "Bottom left"), item(1pt, 1pt, "Bottom right"),
)
