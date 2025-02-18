#import "../../src/lib.typ": shadowed

#set page(margin: 10pt, width: 180pt, height: auto)

#let content = ```rs
fn main() {
    println!("Hello, world!");
}
```

#shadowed(radius: 4pt, inset: 10pt)[
  #content
]
