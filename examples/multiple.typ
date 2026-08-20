// This example demonstrates how to create an inner and outer shadow.

#import "../src/lib.typ": shadow

#set page(margin: 15pt, height: auto, width: auto)

#shadow(spread: 2pt, blur: 4pt, fill: red)[
  #shadow(inset: true, spread: 2pt, blur: 4pt, fill: blue)[
    #block(inset: 4pt, fill: white)[
      #text(size: 24pt)[
        This box has an inner and outer shadow
      ]
    ]
  ]
]
