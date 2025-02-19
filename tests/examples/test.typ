#import "../../src/lib.typ": shadowed

#show heading: it => [
  #set align(center)
  #it
  #v(1em)
]

#let code(body) = [
  #block(fill: luma(230), inset: 1em, width: 100%)[
    #body
  ]
]

= Examples

This document contains example usages for `shadowed` with the following contents:

- *Text*
- *Image*
- *Code*
- *Grid*

== Text

The following code...

#code[
  ```typ
  #set par(justify: true)

  #shadowed(inset: 1em, radius: 6pt)[
    #lorem(50)
  ]
  ```
]

...results in:

#set par(justify: true)

#shadowed(inset: 1em, radius: 6pt)[
  #lorem(50)
]

#pagebreak()

== Images

The following code...

#code[
  ```typ
  #shadowed(shadow: 12pt, radius: 8pt, clip: true)[
    #image("image.jpg")
  ]
  ```
]

...results in:

#shadowed(shadow: 12pt, radius: 8pt, clip: true)[
  #image("../../examples/image.jpg")
]

#pagebreak()

== Code

The following code...

#code[
  ````typ
    #shadowed(inset: 1em, radius: 4pt)[
    #block(width: 100%)[
      ```py
      def fibonacci(n):
        if n < 0:
            print("Incorrect input")
        elif n == 0:
            return 0
        elif n == 1 or n == 2:
            return 1
        else:
            return Fibonacci(n-1) + Fibonacci(n-2)
      ```
    ]
  ]
  ````
]

..results in:

#shadowed(inset: 1em, radius: 4pt)[
  #block(width: 100%)[
    ```py
    def fibonacci(n):
      if n < 0:
          print("Incorrect input")
      elif n == 0:
          return 0
      elif n == 1 or n == 2:
          return 1
      else:
          return Fibonacci(n-1) + Fibonacci(n-2)
    ```
  ]
]

#pagebreak()

== Grid

The following code...

#code[
  ```typ
  #let content = shadowed(radius: 4pt, inset: 12pt, shadow: 6pt)[
    #lorem(40)
  ]

  #grid(
    columns: 2,
    content, content,
    grid.cell(colspan: 2, content),
  )
  ```
]

...results in:

#let content = shadowed(radius: 4pt, inset: 12pt, shadow: 6pt)[
  #lorem(40)
]

#grid(
  columns: 2,
  content, content,
  grid.cell(colspan: 2, content),
)
