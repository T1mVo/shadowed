// This example demonstrates how to create an inner shadow.

#import "../src/lib.typ": shadow

#set page(margin: 15pt, height: auto, width: auto)

#shadow(inset: true, spread: 2pt, blur: 4pt)[
  #block(inset: 4pt)[
    #text(size: 24pt)[
      This box has an inner shadow
    ]
  ]
]
