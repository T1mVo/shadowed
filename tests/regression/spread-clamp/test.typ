#import "../../../src/lib.typ": shadow

#set page(margin: 15pt, height: auto, width: auto)

#grid(
  columns: 2,
  align: center + horizon,
  inset: 10pt,
  // Exceeds the width, so it is clamped to keep the shadow at least the box size.
  shadow(blur: 4pt, spread: (top: -40pt, bottom: -40pt))[
    #block(width: 120pt, height: 40pt, fill: white)
  ],
  // Exceeds the width, so the left and right spread are clamped proportionally.
  shadow(blur: 4pt, spread: (left: -100pt, right: -50pt))[
    #block(width: 80pt, height: 80pt, fill: white)
  ],
  "Clamped vertically",

  "Clamped horizontally",
)
