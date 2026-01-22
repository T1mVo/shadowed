#import "../../src/lib.typ": shadow

#set page(margin: 10pt, width: auto, height: auto)

#let content = ```rs
fn main() {
    println!("Hello, world!");
}
```

#let radius = 4pt
#let spread = 2pt
#let blur = 4pt
#let padding = spread + blur

#pad(padding)[
  #shadow(radius: radius, spread: spread, blur: blur, fill: rgb(89, 85, 101, 25%))[
    #block(radius: radius, inset: 12pt, fill: white)[
      #content
    ]
  ]
]
