#import "../lib.typ": shadowed

#set par(justify: true)

#for _ in range(100) [
  #page[
    #for _ in range(6) [
      #shadowed(inset: 12pt, radius: 4pt)[
        #lorem(50)
      ]
    ]
  ]
]
