#let blur-to-deviation-factor = 1 / 2.6

/// Converts a value to a string.
///
/// Alternative str constructor that renders negative numbers
/// with a ASCII minus sign.
///
/// -> str
#let to-str(
  /// The value to convert.
  /// -> str | int | float
  value,
) = {
  assert(
    type(value) == str or type(value) == int or type(value) == float,
    message: "to-str: value must be of type str, int or float, got "
      + str(type(value)),
  )

  if type(value) == str {
    value
  } else {
    if value < 0 {
      "-" + str(-value)
    } else {
      str(value)
    }
  }
}

/// Convert a radius to a length.
///
/// -> length
#let convert-radius(
  /// The radius to convert.
  /// -> length | ratio | relative
  radius,
  /// The objects width.
  /// -> length
  width,
  /// The objects height.
  /// -> length
  height,
) = {
  let radius = if type(radius) == length {
    radius
  } else if type(radius) == ratio {
    calc.min(width, height) * radius
  } else if type(radius) == relative {
    calc.min(width, height) * radius.ratio + radius.length
  }

  // Prevent negative values
  calc.max(radius, 0pt)
}

/// Normalize a radius.
///
/// Returns a dictionary that contains the radius of each corner at
/// "top-left", "top-right", "bottom-left", and "bottom-right".
///
/// -> dictionary
#let normalize-radius(
  /// The radius to normalize.
  /// -> length | ratio | relative | dictionary
  radius,
  /// The length of the shadow.
  /// -> length
  width,
  /// The height of the shadow.
  /// -> length
  height,
) = {
  assert(
    type(radius) == length
      or type(radius) == ratio
      or type(radius) == relative
      or type(radius) == dictionary,
    message: "normalize-radius: radius must be of type length, ratio, relative or dictionary, got "
      + str(type(radius)),
  )

  if type(radius) != dictionary {
    let radius = convert-radius(radius, width, height)

    (
      "top-left": radius,
      "top-right": radius,
      "bottom-left": radius,
      "bottom-right": radius,
    )
  } else {
    let top-left = radius.at("rest", default: 0pt)
    let top-right = radius.at("rest", default: 0pt)
    let bottom-left = radius.at("rest", default: 0pt)
    let bottom-right = radius.at("rest", default: 0pt)

    bottom-left = radius.at("bottom", default: bottom-left)
    bottom-right = radius.at("bottom", default: bottom-right)

    top-right = radius.at("right", default: top-right)
    bottom-right = radius.at("right", default: bottom-right)

    top-left = radius.at("top", default: top-left)
    top-right = radius.at("top", default: top-right)

    top-left = radius.at("left", default: top-left)
    bottom-left = radius.at("left", default: bottom-left)

    bottom-left = radius.at("bottom-left", default: bottom-left)

    bottom-right = radius.at("bottom-right", default: bottom-right)

    top-right = radius.at("top-right", default: top-right)

    top-left = radius.at("top-left", default: top-left)

    (
      "top-left": convert-radius(top-left, width, height),
      "top-right": convert-radius(top-right, width, height),
      "bottom-left": convert-radius(bottom-left, width, height),
      "bottom-right": convert-radius(bottom-right, width, height),
    )
  }
}

/// Interpolates the gradient stops based on the color space.
///
/// -> array
#let interpolate-stops(
  /// The gradient.
  /// -> gradient
  gradient,
) = {
  let in-stops = gradient.stops()
  let stop-count = in-stops.len()

  // Avoid `windows(2)` returning nothing for degenerate gradients
  if stop-count < 2 {
    return in-stops
  }

  let default-len = calc.max(int(256 / stop-count), 2)
  let stops = ()

  for (from, to) in in-stops.windows(2) {
    let from-color = from.at(0)
    let to-color = to.at(0)
    let from-offset = from.at(1)
    let to-offset = to.at(1)
    let delta = to-offset - from-offset

    // No interpolation needed for identical colors
    let len = if from-color == to-color { 1 } else { default-len }

    stops.push((from-color, from-offset))

    for i in range(1, len - 1) {
      let t0 = i / (len - 1)
      let offset = from-offset + delta * t0
      let color = gradient.sample(offset)

      stops.push((color, offset))
    }

    stops.push((to-color, to-offset))
  }

  stops
}

/// Get the quadrant of the Cartesian plane that this angle lies in.
///
/// The angle is automatically normalized to the range `0deg..=360deg`.
///
/// The quadrants are defined as follows:
/// - 1: `0deg..=90deg` (top-right)
/// - 2: `90deg..=180deg` (top-left)
/// - 3: `180deg..=270deg` (bottom-left)
/// - 4: `270deg..=360deg` (bottom-right)
///
/// -> int
#let angle-quadrant(
  /// The angle.
  /// -> angle
  angle,
) = {
  let normalized-angle = calc.rem-euclid(angle.deg(), 360) * 1deg

  if normalized-angle <= 90deg {
    1
  } else if normalized-angle <= 180deg {
    2
  } else if normalized-angle <= 270deg {
    3
  } else {
    4
  }
}

/// Corrects the angle for gradient vector calculation based on the aspect ratio.
///
/// -> angle
#let correct-angle(
  /// The angle.
  /// -> angle
  angle,
  /// The ratio.
  /// -> int | float
  ratio,
) = {
  let rad = calc
    .atan(calc.tan(calc.rem-euclid(angle.rad(), calc.tau)) / ratio)
    .rad()
  let quadrant = angle-quadrant(angle)

  // rad stays the same in quadrant 1
  if quadrant == 2 or quadrant == 3 {
    rad += calc.pi
  } else {
    rad += calc.tau
  }

  calc.rem-euclid(rad, calc.tau) * 1rad
}

/// Calculate the gradient vector for a linear gradient.
///
/// Returns the vector coordinates in form of (x1, y1, x2, y2).
///
/// -> array
#let calculate-gradient-vector(
  /// The angle.
  /// -> angle
  angle,
  /// The width.
  /// -> int | float | length
  width,
  /// The height.
  /// -> int | float | length
  height,
) = {
  let ratio = width / height
  let angle = correct-angle(angle, ratio)

  let (sin, cos) = (calc.sin(angle), calc.cos(angle))
  let length = calc.abs(sin) + calc.abs(cos)
  let quadrant = angle-quadrant(angle)

  if quadrant == 1 {
    (0, 0, cos * length, sin * length)
  } else if quadrant == 2 {
    (1, 0, cos * length + 1, sin * length)
  } else if quadrant == 3 {
    (1, 1, cos * length + 1, sin * length + 1)
  } else {
    (0, 1, cos * length, sin * length + 1)
  }
}

/// Renders a gradient stop.
///
/// -> str
#let stop-template(
  /// The stop in the form of (color, ratio).
  /// -> list
  stop,
) = {
  let stop-color = stop.at(0).to-hex()
  let offset = stop.at(1) / 1%

  // begin templates/stop.svg.template
  (
    "<stop offset=\"",
    to-str(offset),
    "%\" stop-color=\"",
    to-str(stop-color),
    "\" />",
  ).join()
  // end templates/stop.svg.template
}

/// Renders a linear gradient.
///
/// -> str
#let linear-gradient-template(
  /// The gradient of kind gradient.linear.
  /// -> gradient
  gradient,
  /// The width of the gradient.
  /// -> int | float
  gradient-width,
  /// The height of the gradient.
  /// -> int | float
  gradient-height,
) = {
  let interpolated-stops = interpolate-stops(gradient)
  let stops = interpolated-stops.map(stop => stop-template(stop)).join()

  let (x1, y1, x2, y2) = calculate-gradient-vector(
    gradient.angle(),
    gradient-width,
    gradient-height,
  )

  // begin templates/linear-gradient.svg.template
  (
    "<linearGradient id=\"gradient\" gradientUnits=\"userSpaceOnUse\" x1=\"",
    to-str(x1),
    "\" y1=\"",
    to-str(y1),
    "\" x2=\"",
    to-str(x2),
    "\" y2=\"",
    to-str(y2),
    "\" gradientTransform=\"matrix(",
    to-str(gradient-width),
    " 0 0 ",
    to-str(gradient-height),
    " 0 0)\"> ",
    to-str(stops),
    " </linearGradient>",
  ).join()
  // end templates/linear-gradient.svg.template
}

/// Renders a radial gradient.
///
/// -> str
#let radial-gradient-template(
  /// The gradient of kind gradient.radial.
  /// -> gradient
  gradient,
  /// The width of the gradient.
  /// -> int | float
  gradient-width,
  /// The height of the gradient.
  /// -> int | float
  gradient-height,
) = {
  let center-x = gradient.center().at(0) / 100%
  let center-y = gradient.center().at(1) / 100%
  let focal-center-x = gradient.focal-center().at(0) / 100%
  let focal-center-y = gradient.focal-center().at(1) / 100%
  let radius = gradient.radius() / 100%
  let focal-radius = gradient.focal-radius() / 100%
  let stops = gradient.stops().map(stop => stop-template(stop)).join()

  // begin templates/radial-gradient.svg.template
  (
    "<radialGradient id=\"gradient\" gradientUnits=\"userSpaceOnUse\" cx=\"",
    to-str(center-x),
    "\" cy=\"",
    to-str(center-y),
    "\" fx=\"",
    to-str(focal-center-x),
    "\" fy=\"",
    to-str(focal-center-y),
    "\" r=\"",
    to-str(radius),
    "\" fr=\"",
    to-str(focal-radius),
    "\" gradientTransform=\"matrix(",
    to-str(gradient-width),
    " 0 0 ",
    to-str(gradient-height),
    " 0 0)\"> ",
    to-str(stops),
    " </radialGradient>",
  ).join()
  // end templates/radial-gradient.svg.template
}

/// Renders a gradient based on its kind.
///
/// -> str
#let gradient-template(
  /// The gradient of kind gradient.linear or gradient.radial.
  /// -> gradient
  gradient,
  /// The gradient width.
  /// -> int | float
  gradient-width,
  /// The gradient height.
  /// -> int | float
  gradient-height,
) = {
  if gradient.kind() == std.gradient.linear {
    linear-gradient-template(gradient, gradient-width, gradient-height)
  } else if gradient.kind() == std.gradient.radial {
    radial-gradient-template(gradient, gradient-width, gradient-height)
  } else {
    panic("gradient-template: gradient must be of kind linear or radial")
  }
}

/// Resolves a fill to its string representation and optional gradient definition.
///
/// -> array
#let resolve-fill(
  /// The fill to resolve.
  /// -> color | gradient
  fill,
  /// The SVG width.
  /// -> int | float
  svg-width,
  /// The SVG height.
  /// -> int | float
  svg-height,
) = {
  let gradient = if type(fill) == gradient {
    gradient-template(fill, svg-width, svg-height)
  } else {
    ""
  }
  let fill = if type(fill) == color { fill.to-hex() } else { "url(#gradient)" }

  (fill, gradient)
}

/// Returns the feMorphology operator for a spread radius.
///
/// -> str
#let spread-operator(
  /// The spread radius.
  /// -> int | float
  spread-radius,
) = if spread-radius >= 0 {
  "dilate"
} else {
  "erode"
}

/// Renders the path of a rounded rectangle.
///
/// -> str
#let box-path(
  /// The x position of the rectangle.
  /// -> int | float
  rect-dx: none,
  /// The y position of the rectangle.
  /// -> int | float
  rect-dy: none,
  /// The width of the rectangle.
  /// -> int | float
  rect-width: none,
  /// The height of the rectangle.
  /// -> int | float
  rect-height: none,
  /// The top-left radius.
  /// -> int | float
  radius-tl: none,
  /// The top-right radius.
  /// -> int | float
  radius-tr: none,
  /// The bottom-left radius.
  /// -> int | float
  radius-bl: none,
  /// The bottom-right radius.
  /// -> int | float
  radius-br: none,
) = {
  // begin templates/box-path.svg.template
  (
    "M ",
    to-str(rect-dx + radius-tl),
    ", ",
    to-str(rect-dy),
    " H ",
    to-str(rect-dx + rect-width - radius-tr),
    " A ",
    to-str(radius-tr),
    " ",
    to-str(radius-tr),
    " 0 0 1 ",
    to-str(rect-dx + rect-width),
    ", ",
    to-str(rect-dy + radius-tr),
    " V ",
    to-str(rect-dy + rect-height - radius-br),
    " A ",
    to-str(radius-br),
    " ",
    to-str(radius-br),
    " 0 0 1 ",
    to-str(rect-dx + rect-width - radius-br),
    ", ",
    to-str(rect-dy + rect-height),
    " H ",
    to-str(rect-dx + radius-bl),
    " A ",
    to-str(radius-bl),
    " ",
    to-str(radius-bl),
    " 0 0 1 ",
    to-str(rect-dx),
    ", ",
    to-str(rect-dy + rect-height - radius-bl),
    " V ",
    to-str(rect-dy + radius-tl),
    " A ",
    to-str(radius-tl),
    " ",
    to-str(radius-tl),
    " 0 0 1 ",
    to-str(rect-dx + radius-tl),
    ", ",
    to-str(rect-dy),
    " Z",
  ).join()
  // end templates/box-path.svg.template
}

/// Renders a SVG box shadow.
///
/// -> str
#let shadow-template(
  /// The SVG width.
  /// -> int | float
  svg-width: none,
  /// The SVG height.
  /// -> int | float
  svg-height: none,
  /// The blur deviation.
  /// -> int | float
  blur-deviation: none,
  /// The spread radius.
  /// -> int | float
  spread-radius: none,
  /// The fill color or gradient.
  /// -> color | gradient
  fill: none,
  /// The horizontal offset.
  /// -> int | float
  dx: none,
  /// The vertical offset.
  /// -> int | float
  dy: none,
  /// The gradient x position.
  /// -> int | float
  rect-dx: none,
  /// The gradient y position.
  /// -> int | float
  rect-dy: none,
  /// The gradient width.
  /// -> int | float
  rect-width: none,
  /// The gradient height.
  /// -> int | float
  rect-height: none,
  /// The top-left radius.
  /// -> int | float
  radius-tl: none,
  /// The top-right radius.
  /// -> int | float
  radius-tr: none,
  /// The bottom-left radius.
  /// -> int | float
  radius-bl: none,
  /// The bottom-right radius.
  /// -> int | float
  radius-br: none,
) = {
  let (fill, gradient) = resolve-fill(fill, svg-width, svg-height)
  let spread-operator = spread-operator(spread-radius)
  // A radius of 0 causes rendering issues: https://github.com/typst/typst/issues/7794
  let spread-radius = calc.max(calc.abs(spread-radius), 0.001)

  // begin templates/shadow.svg.template
  (
    "<svg viewBox=\"0 0 ",
    to-str(svg-width),
    " ",
    to-str(svg-height),
    "\" height=\"",
    to-str(svg-height),
    "pt\" width=\"",
    to-str(svg-width),
    "pt\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\"> <defs> ",
    to-str(gradient),
    " <filter id=\"shadow\" filterUnits=\"userSpaceOnUse\" primitiveUnits=\"userSpaceOnUse\" x=\"-10%\" y=\"-10%\" width=\"120%\" height=\"120%\"> <feGaussianBlur in=\"SourceGraphic\" stdDeviation=\"",
    to-str(blur-deviation),
    "\" result=\"blur\" /> <feMorphology operator=\"",
    to-str(spread-operator),
    "\" radius=\"",
    to-str(spread-radius),
    "\" in=\"blur\" result=\"spread\" /> </filter> </defs> <g transform=\"translate(",
    to-str(dx + calc.abs(dx)),
    ",",
    to-str(dy + calc.abs(dy)),
    ")\"> <path d=\"",
    to-str(box-path(
      rect-dx: rect-dx,
      rect-dy: rect-dy,
      rect-width: rect-width,
      rect-height: rect-height,
      radius-tl: radius-tl,
      radius-tr: radius-tr,
      radius-bl: radius-bl,
      radius-br: radius-br,
    )),
    "\" fill=\"",
    to-str(fill),
    "\" filter=\"url(#shadow)\" /> </g> </svg>",
  ).join()
  // end templates/shadow.svg.template
}

/// Renders a SVG inner box shadow.
///
/// -> str
#let inset-shadow-template(
  /// The SVG width.
  /// -> int | float
  svg-width: none,
  /// The SVG height.
  /// -> int | float
  svg-height: none,
  /// The blur deviation.
  /// -> int | float
  blur-deviation: none,
  /// The spread radius.
  /// -> int | float
  spread-radius: none,
  /// The fill color or gradient.
  /// -> color | gradient
  fill: none,
  /// The horizontal offset.
  /// -> int | float
  dx: none,
  /// The vertical offset.
  /// -> int | float
  dy: none,
  /// The gradient x position.
  /// -> int | float
  rect-dx: none,
  /// The gradient y position.
  /// -> int | float
  rect-dy: none,
  /// The gradient width.
  /// -> int | float
  rect-width: none,
  /// The gradient height.
  /// -> int | float
  rect-height: none,
  /// The top-left radius.
  /// -> int | float
  radius-tl: none,
  /// The top-right radius.
  /// -> int | float
  radius-tr: none,
  /// The bottom-left radius.
  /// -> int | float
  radius-bl: none,
  /// The bottom-right radius.
  /// -> int | float
  radius-br: none,
) = {
  let (fill, gradient) = resolve-fill(fill, svg-width, svg-height)
  let spread-operator = spread-operator(spread-radius)
  // A radius of 0 causes rendering issues: https://github.com/typst/typst/issues/7794
  let spread-radius = calc.max(calc.abs(spread-radius), 0.001)

  // begin templates/inset-shadow.svg.template
  (
    "<svg viewBox=\"0 0 ",
    to-str(svg-width),
    " ",
    to-str(svg-height),
    "\" height=\"",
    to-str(svg-height),
    "pt\" width=\"",
    to-str(svg-width),
    "pt\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\"> <defs> ",
    to-str(gradient),
    " <path id=\"box-shape\" d=\"",
    to-str(box-path(
      rect-dx: rect-dx,
      rect-dy: rect-dy,
      rect-width: rect-width,
      rect-height: rect-height,
      radius-tl: radius-tl,
      radius-tr: radius-tr,
      radius-bl: radius-bl,
      radius-br: radius-br,
    )),
    "\" /> <filter id=\"inset-shadow\" filterUnits=\"userSpaceOnUse\" primitiveUnits=\"userSpaceOnUse\" x=\"0\" y=\"0\" width=\"",
    to-str(svg-width),
    "\" height=\"",
    to-str(svg-height),
    "\"> <feOffset in=\"SourceAlpha\" dx=\"",
    to-str(dx),
    "\" dy=\"",
    to-str(dy),
    "\" result=\"displaced\" /> <feComponentTransfer in=\"displaced\" result=\"inverted\"> <feFuncA type=\"table\" tableValues=\"1 0\" /> </feComponentTransfer> <feGaussianBlur in=\"inverted\" stdDeviation=\"",
    to-str(blur-deviation),
    "\" result=\"blurred\" /> <feMorphology operator=\"",
    to-str(spread-operator),
    "\" radius=\"",
    to-str(spread-radius),
    "\" in=\"blurred\" result=\"spread\" /> <feFlood flood-color=\"white\" result=\"white\" /> <feComposite in=\"white\" in2=\"spread\" operator=\"in\" result=\"shadow-ring\" /> <feComposite in=\"SourceAlpha\" in2=\"displaced\" operator=\"out\" result=\"gap\" /> <feGaussianBlur in=\"gap\" stdDeviation=\"",
    to-str(blur-deviation),
    "\" result=\"gap-blur\" /> <feComposite in=\"white\" in2=\"gap-blur\" operator=\"in\" result=\"gap-mask\" /> <feMerge> <feMergeNode in=\"shadow-ring\" /> <feMergeNode in=\"gap-mask\" /> </feMerge> </filter> <mask id=\"inset-shadow-mask\" maskUnits=\"userSpaceOnUse\" x=\"0\" y=\"0\" width=\"",
    to-str(svg-width),
    "\" height=\"",
    to-str(svg-height),
    "\"> <use href=\"#box-shape\" fill=\"white\" filter=\"url(#inset-shadow)\" /> </mask> <clipPath id=\"box-clip\"> <use href=\"#box-shape\" /> </clipPath> </defs> <g clip-path=\"url(#box-clip)\"> <rect x=\"0\" y=\"0\" width=\"",
    to-str(svg-width),
    "\" height=\"",
    to-str(svg-height),
    "\" fill=\"",
    to-str(fill),
    "\" mask=\"url(#inset-shadow-mask)\" /> </g> </svg>",
  ).join()
  // end templates/inset-shadow.svg.template
}

/// A box shadow.
///
/// ```example
/// #shadow(blur: 6pt, spread: 2pt)[
///   #block(inset: 4pt, fill: white)[
///    #text("This block has a shadow!")
///  ]
/// ]
/// ```
///
/// -> content
#let shadow(
  /// Whether to draw the shadow inside the box instead of outside.
  ///
  /// -> bool
  inset: false,
  /// The horizontal offset.
  /// -> length
  dx: 0pt,
  /// The vertical offset.
  /// -> length
  dy: 0pt,
  /// How strong to blur the shadow.
  ///
  /// Must be equal to or greater than 0pt.
  ///
  /// -> length
  blur: 0pt,
  /// How far to spread the length of the shadow.
  /// -> length
  spread: 0pt,
  /// How to fill the shadow.
  ///
  /// Currently only supports linear or radial gradients.
  ///
  /// -> color | gradient | none
  fill: black,
  /// How much to round the shadow's corners.
  ///
  /// Can be either:
  /// - A relative length for a uniform corner radius,
  ///   relative to the minimum of the width and height divided by two.
  ///
  /// - A dictionary: With a dictionary, the stroke for each side can be set
  ///   individually.
  ///   The dictionary can contain the following keys in order of precedence:
  ///   - top-left: The top-left corner radius.
  ///   - top-right: The top-right corner radius.
  ///   - bottom-right: The bottom-right corner radius.
  ///   - bottom-left: The bottom-left corner radius.
  ///   - left: The top-left and bottom-left corner radii.
  ///   - top: The top-left and top-right corner radii.
  ///   - right: The top-right and bottom-right corner radii.
  ///   - bottom: The bottom-left and bottom-right corner radii.
  ///   - rest: The radii for all corners except those for which the dictionary
  ///     explicitly sets a size.
  ///
  /// -> relative | dictionary
  radius: 0pt,
  /// The content to place in front of the shadow.
  /// -> content
  body,
) = layout(
  size => {
    // Type checks
    assert(type(dx) == length, message: "shadow: dx must be of type length")
    assert(type(dy) == length, message: "shadow: dy must be of type length")
    assert(type(blur) == length, message: "shadow: blur must be of type length")
    assert(
      type(spread) == length,
      message: "shadow: spread must be of type length",
    )
    assert(
      type(fill) == color or type(fill) == gradient or fill == none,
      message: "shadow: fill must be of type color or gradient or none",
    )
    assert(
      type(radius) == length
        or type(radius) == ratio
        or type(radius) == relative
        or type(radius) == dictionary,
      message: "shadow: radius must be of type length, ratio, relative or dictionary",
    )

    // Type-dependent type checks
    if type(radius) == dictionary {
      for r in radius.values() {
        assert(
          type(r) == length or type(r) == ratio or type(r) == relative,
          message: "shadow: radius must be of type length, ratio or relative",
        )
      }
    }

    // Value checks
    assert(
      blur >= 0pt,
      message: "shadow: blur must be greater or equal to zero",
    )

    // Return only the body if no fill is specified
    if (fill == none) {
      return body
    }

    let (width, height) = measure(width: size.width, height: size.height)[
      #body
    ]

    // Return empty block if width or height are zero to avoid issues with dividing by zero
    if (width == 0pt or height == 0pt) {
      return block()
    }

    let outset = calc.max(blur + spread, 0pt)

    let radius = normalize-radius(radius, width, height)

    // Grow the SVG size by the outset to ensure that the shadow is not clipped
    let svg-height = height + outset * 2
    let svg-width = width + outset * 2

    // Grow the SVG size by the offset to ensure that the shadow is not clipped
    let svg-height = if inset {
      svg-height
    } else {
      svg-height + calc.abs(dy) * 2
    }
    let svg-width = if inset {
      svg-width
    } else {
      svg-width + calc.abs(dx) * 2
    }

    let blur-deviation = blur * blur-to-deviation-factor

    let svg-source = if inset {
      inset-shadow-template(
        svg-width: svg-width.pt(),
        svg-height: svg-height.pt(),
        blur-deviation: blur-deviation.pt(),
        spread-radius: spread.pt(),
        fill: fill,
        dx: dx.pt(),
        dy: dy.pt(),
        rect-dx: outset.pt(),
        rect-dy: outset.pt(),
        rect-width: width.pt(),
        rect-height: height.pt(),
        radius-tl: radius.top-left.pt(),
        radius-tr: radius.top-right.pt(),
        radius-bl: radius.bottom-left.pt(),
        radius-br: radius.bottom-right.pt(),
      )
    } else {
      shadow-template(
        svg-width: svg-width.pt(),
        svg-height: svg-height.pt(),
        blur-deviation: blur-deviation.pt(),
        spread-radius: spread.pt(),
        fill: fill,
        dx: dx.pt(),
        dy: dy.pt(),
        rect-dx: outset.pt(),
        rect-dy: outset.pt(),
        rect-width: width.pt(),
        rect-height: height.pt(),
        radius-tl: radius.top-left.pt(),
        radius-tr: radius.top-right.pt(),
        radius-bl: radius.bottom-left.pt(),
        radius-br: radius.bottom-right.pt(),
      )
    }
    let svg = image(
      bytes(svg-source),
      height: svg-height,
      width: svg-width,
      format: "svg",
      alt: "box-shadow",
    )

    block(breakable: false)[
      // For inset shadows, draw the body first so the shadow is placed on top of it
      #if inset [
        #body
      ]

      #place(center + horizon)[
        #svg <shadowed-shadow>
      ]

      // For outset shadows, draw the body after so it stays on top of the shadow
      #if not inset [
        #body
      ]
    ]
  },
)
