/// [skip]

#import "../../../src/lib.typ": shadow

#let page-layout = (width: 100pt, height: 100pt, margin: 15pt)
#let radius = (
  "top-left": 4pt,
  "top-right": 4%,
  "bottom-left": 4% + 4pt,
  "rest": 0% - 4pt,
)

#set page(..page-layout)

#shadow(radius: radius)[
  #block(width: 100%, height: 100%)
]
