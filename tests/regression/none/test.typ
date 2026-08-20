#import "../../../src/lib.typ": shadow

#set page(width: 60pt, height: 60pt, margin: 5pt)

#shadow(blur: 8pt, spread: 2pt, fill: none)[
  #block(width: 50pt, height: 50pt, fill: red)
]

// Ensure that no shadow is rendered when `fill: none`
#context {
  assert(
    query(<shadowed-shadow>).len() == 0,
    message: "Expected no shadow to be rendered when fill is none.",
  )
}
