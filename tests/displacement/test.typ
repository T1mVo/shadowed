#import "../../src/lib.typ": shadowed

#set page(margin: 10pt, width: 200pt, height: auto)

#grid(
  columns: 2,
  rows: 2,
  align: center,
  shadowed(radius: 4pt, inset: 10pt, shadow: 6pt, dx: -1.5pt, dy: -1.5pt)[
    #block(width: 100%)[Top left]
  ],
    shadowed(radius: 4pt, inset: 10pt, shadow: 6pt, dx: 1.5pt, dy: -1.5pt)[
    #block(width: 100%)[Top right]
  ],
    shadowed(radius: 4pt, inset: 10pt, shadow: 6pt, dx: -1.5pt, dy: 1.5pt)[
    #block(width: 100%)[Bottom left]
  ],
    shadowed(radius: 4pt, inset: 10pt, shadow: 6pt, dx: 1.5pt, dy: 1.5pt)[
    #block(width: 100%)[Bottom right]
  ],
)
