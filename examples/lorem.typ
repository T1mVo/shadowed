#import "../src/lib.typ": shadow

#set page(margin: 15pt, height: auto)
#set par(justify: true)

#shadow(blur: 8pt, fill: rgb(89, 85, 101, 25%), radius: 4pt)[
  #block(fill: white, radius: 4pt, inset: 12pt)[
    #lorem(50)
  ]
]
