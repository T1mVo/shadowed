#let renderer = plugin("renderer.wasm")

#let render(
  svg-height,
  svg-width,
  deviation,
  color,
  rect-height,
  rect-width,
  x-offset,
  y-offset,
  radius,
) = {
  assert(type(svg-height) == length, message: "svg-height must be of type: length")
  assert(type(svg-width) == length, message: "svg-width must be of type: length")
  assert(type(deviation) == length, message: "deviation must be of type: length")
  assert(type(color) == std.color, message: "color must be of type: color")
  assert(type(rect-height) == length, message: "rect-height must be of type: length")
  assert(type(rect-width) == length, message: "rect-width must be of type: length")
  assert(type(x-offset) == length, message: "x-offset must be of type: length")
  assert(type(y-offset) == length, message: "y-offset must be of type: length")
  assert(type(radius) == length, message: "radius must be of type: length")

  let image-height = svg-height
  let image-width = svg-width

  let svg-height = svg-height.pt().to-bytes()
  let svg-width = svg-width.pt().to-bytes()
  let deviation = deviation.pt().to-bytes()
  let color = bytes(color.rgb().to-hex())
  let rect-height = rect-height.pt().to-bytes()
  let rect-width = rect-width.pt().to-bytes()
  let x-offset = x-offset.pt().to-bytes()
  let y-offset = y-offset.pt().to-bytes()
  let radius = radius.pt().to-bytes()

  let buffer = renderer.render(
    svg-height,
    svg-width,
    deviation,
    color,
    rect-height,
    rect-width,
    x-offset,
    y-offset,
    radius,
  )

  if sys.version == version(0, 12, 0) {
    image.decode(buffer, format: "svg", height: image-height, width: image-width, alt: "shadow")
  } else {
    image(buffer, format: "svg", height: image-height, width: image-width, alt: "shadow")
  }
}

/// Apply box shadows to inner content.
///
/// - fill (color): The block's background color.
/// - radius (length): How much to round the block's corners.
/// - inset (length): How much to pad the block's content.
/// - clip (bool): Whether to clip the content inside the block.
/// - shadow (length): Blur radius of the shadow. Also adds a padding of the same size.
/// - color (color): Color of the shadow.
/// - dx (relative): The horizontal displacement of the shadow. Does not alter the block's padding.
/// - dy (relative): The vertical displacement of the shadow. Does not alter the block's padding.
/// - body (content): The contents of the block.
/// -> content
#let shadowed(
  fill: white,
  radius: 0pt,
  inset: 0pt,
  clip: false,
  shadow: 8pt,
  color: rgb(89, 85, 101, 30%),
  dx: 0% + 0pt,
  dy: 0% + 0pt,
  padding: auto,
  body,
) = layout(size => [
  #let (width, height) = measure(width: size.width, height: size.height)[
    #block(inset: shadow, breakable: false)[
      #block(inset: inset)[
        #body
      ]
    ]
  ]

  #block(breakable: false)[
    #place(dx: dx, dy: dy)[
      #render(
        height, // svg-height
        width, // svg-width
        shadow / 2.5, // deviation
        color, // color
        height - shadow * 2, // rect-height
        width - shadow * 2, // rect-width
        shadow, // x-offset
        shadow, // y-offset
        radius, // radius
      )
    ]

    #block(inset: shadow, breakable: false)[
      #block(fill: fill, radius: radius, inset: inset, clip: clip)[
        #body
      ]
    ]
  ]
])

#let format(template, ..replacements) = {
  let replacements = replacements.named()

  return template.replace(regex("\{([^{} ]+)\}"), match => {
    let index = match.at("captures").at(0)

    assert(index in replacements, message: "format: Missing argument \"" + index + "\"")

    return str(replacements.at(index))
  })
}

#let shadow(dx: 0pt, dy: 0pt, blur: 0pt, spread: 0pt, color: black, radius: 0pt, body) = layout(
  size => {
    assert(type(dx) == length, message: "shadow: dx must be of type length")
    assert(type(dy) == length, message: "shadow: dy must be of type length")
    assert(type(blur) == length, message: "shadow: blur must be of type length")
    assert(type(spread) == length, message: "shadow: spread must be of type length")
    assert(type(color) == std.color, message: "shadow: color must be of type color")
    assert(type(radius) == length, message: "shadow: radius must be of type length")

    assert(blur >= 0pt, message: "shadow: blur must be greater or equal to zero")
    assert(radius >= 0pt, message: "shadow: radius must be greater or equal to zero")

    let (width, height) = measure(width: size.width, height: size.height)[
      #body
    ]

    let outset = calc.max(blur + spread, 0pt)

    let svg-height = height + outset * 2
    let svg-width = width + outset * 2
    let blur-deviation = blur / 2.6
    let spread-operator = if spread.pt() >= 0 { "dilate" } else { "erode" }

    let template = read("./shadow.svg.template", encoding: "utf8")
    let svg-source = format(
      template,
      svg-height: svg-height.pt(),
      svg-width: svg-width.pt(),
      blur-deviation: blur-deviation.pt(),
      spread-operator: spread-operator,
      spread-radius: spread.pt(),
      flood-color: color.to-hex(),
      rect-height: height.pt(),
      rect-width: width.pt(),
      rect-dx: outset.pt(),
      rect-dy: outset.pt(),
      rect-radius: radius.pt(),
    )
    let svg = image(bytes(svg-source), height: svg-height, width: svg-width, format: "svg", alt: "box-shadow")

    block(breakable: false)[
      #place(center + horizon, dx: dx, dy: dy)[
        #svg
      ]

      #body
    ]
  },
)

#let outset = 10pt
#let height = 200pt
#let width = 200pt
#let radius = (
  "top-left": 100pt,
  "top-right": 100pt,
  "bottom-left": 100pt,
  "bottom-right": 100pt,
)


#let svg-height = height + outset * 2
#let svg-width = width + outset * 2
#let rect-height = height
#let rect-width = width
#let spread-operator = "dilate"
#let rect-dx = outset
#let rect-dy = outset
#let radius-tl = radius.at("top-left")
#let radius-tr = radius.at("top-right")
#let radius-br = radius.at("bottom-right")
#let radius-bl = radius.at("bottom-left")

#let template = read("./shadow.svg.template2", encoding: "utf8")
#let svg-source = format(
  template,
  svg-height: svg-height.pt(),
  svg-width: svg-width.pt(),
  blur-deviation: 10 / 2.6,
  spread-operator: spread-operator,
  spread-radius: 0,
  flood-color: black.to-hex(),
  rect-height: height.pt(),
  rect-width: width.pt(),
  rect-dx: rect-dx.pt(),
  rect-dy: rect-dy.pt(),
  rect-dx-p-radius-tl: (rect-dx + radius-tl).pt(),
  rect-dx-p-rect-width-m-radius-tr: (rect-dx + rect-width - radius-tr).pt(),
  radius-tr: radius-tr.pt(),
  rect-dx-p-rect-width: (rect-dx + rect-width).pt(),
  rect-dy-p-radius-tr: (rect-dy + radius-tr).pt(),
  rect-dy-p-rect-height-m-radius-br: (rect-dy + rect-height - radius-br).pt(),
  radius-br: radius-br.pt(),
  rect-dx-p-rect-width-m-radius-br: (rect-dx + rect-width - radius-br).pt(),
  rect-dy-p-rect-height: (rect-dy + rect-height).pt(),
  rect-dx-p-radius-bl: (rect-dx + radius-bl).pt(),
  radius-bl: radius-bl.pt(),
  rect-dy-p-rect-height-m-radius-bl: (rect-dy + rect-height - radius-bl).pt(),
  rect-dy-p-radius-tl: (rect-dy + radius-tl).pt(),
  radius-tl: radius-tl.pt(),
)

#image(bytes(svg-source), height: svg-height, width: svg-width, format: "svg", alt: "box-shadow")

#let template = plugin("templating.wasm")
#import "./typed/src-typst/lib.typ" as typed

#let options = (
  "svg-height": 200pt,
  "svg-width": 200pt,
  "blur": 10pt,
  "spread": 0pt,
  "fill": red,
  "rect-height": 180pt,
  "rect-width": 180pt,
  "outset": 10pt,
  "radius": 20pt,
)

#let encoded = typed.cbor.encode(options)

#cbor(template.template(encoded))
