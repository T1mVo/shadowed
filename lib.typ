#import "@preview/oxifmt:0.2.1": strfmt

#let shadowed(
  dx: 0pt,
  dy: 0pt,
  outset: 8pt,
  inset: 12pt,
  radius: 4pt,
  fill: white,
  color: rgb(89, 85, 101),
  opacity: 0.2,
  blur: 4.0,
  body,
) = layout(size => {
  let template = read("shadow.svg")

  let shadow_inset = (
    right: calc.max(outset + dx, 0pt),
    left: calc.max(outset + -dx, 0pt),
    top: calc.max(outset + dy, 0pt),
    bottom: calc.max(outset + -dy, 0pt),
  )

  let dims = measure[
    #block(inset: shadow_inset)[
      #block(inset: inset)[
        #body
      ]
    ]
  ]

  let width = calc.min(size.width, dims.width)

  let height = measure[
    #block(inset: shadow_inset, width: width)[
      #block(inset: inset)[
        #body
      ]
    ]
  ].height

  let replacements = (
    canvas-width: width,
    canvas-height: height,
    rect-width: width - (shadow_inset.left + shadow_inset.right),
    rect-height: height - (shadow_inset.top + shadow_inset.bottom),
    rect-x-offset: shadow_inset.left,
    rect-y-offset: shadow_inset.bottom,
    radius: radius,
    opacity: opacity,
    blur: blur,
    color: strfmt("rgb({}, {}, {})", ..black.rgb().components().map(el => el / 100% * 255)),
  )

  let shadow = strfmt(template, ..replacements)

  place(dx: shadow_inset.right - outset, dy: shadow_inset.top - outset)[
    #image.decode(shadow)
  ]

  block(inset: shadow_inset)[
    #block(inset: inset, radius: radius, fill: fill)[
      #body
    ]
  ]
})
