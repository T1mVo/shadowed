#import "@preview/oxifmt:0.2.1": strfmt

#let __template = read("renderer/templates/shadow.svg.jinja")

#let __render(
  svg-height,
  svg-width,
  blur,
  color,
  rect-height,
  rect-width,
  x-offset,
  y-offset,
  radius,
) = {
  assert(type(svg-height) == type(0pt), message: "svg-height must be of type: Length")
  assert(type(svg-width) == type(0pt), message: "svg-width must be of type: Length")
  assert(type(blur) == type(0pt), message: "blur must be of type: Length")
  assert(type(color) == type(rgb(0, 0, 0)), message: "color must be of type: Color")
  assert(type(rect-height) == type(0pt), message: "rect-height must be of type: Length")
  assert(type(rect-width) == type(0pt), message: "rect-width must be of type: Length")
  assert(type(x-offset) == type(0pt), message: "x-offset must be of type: Length")
  assert(type(y-offset) == type(0pt), message: "y-offset must be of type: Length")
  assert(type(radius) == type(0pt), message: "radius must be of type: Length")

  let replacements = (
    svg-height: svg-height.pt(),
    svg-width: svg-width.pt(),
    blur: blur.pt() / 2.5,
    color: color.rgb().to-hex(),
    rect-height: rect-height.pt(),
    rect-width: rect-width.pt(),
    x-offset: x-offset.pt(),
    y-offset: y-offset.pt(),
    radius: radius.pt(),
  )

  let svg = strfmt(__template, ..replacements)

  image.decode(svg, format: "svg", alt: "shadow")
}

#let shadowed(
  blur: 8pt,
  radius: 0pt,
  color: rgb(89, 85, 101, 30%),
  inset: 0pt,
  fill: white,
  body,
) = layout(size => [
  #let dims = measure[
    #block(breakable: false)[
      #block(radius: radius, inset: blur)[
        #block(inset: inset)[
          #body
        ]
      ]
    ]
  ]

  #let width = calc.min(size.width, dims.width)

  #let height = measure[
    #block(breakable: false)[
      #block(radius: radius, inset: blur, width: width)[
        #block(inset: inset)[
          #body
        ]
      ]
    ]
  ].height

  #block()[
    #place[
      #__render(
        height, // svg-height
        width, // svg-width
        blur, // blur
        color, // color
        height - blur * 2, // rect-height
        width - blur * 2, // rect-width
        blur, // x-offset
        blur, // y-offset
        radius, // radius
      )
    ]

    #block(inset: blur, breakable: false)[
      #block(radius: radius, inset: inset, fill: fill)[
        #body
      ]
    ]
  ]
])
