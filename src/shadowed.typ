#let blur-to-deviation-factor = 1 / 2.6

/// Normalize a radius.
///
/// Returns a dictionary that contains the radius of each corner at
/// "top-left", "top-right", "bottom-left", and "bottom-right".
///
/// - radius (length, dictionary): The radius to normalize.
/// -> dictionary
#let normalize-radius(radius) = {
  if type(radius) == length {
    (
      "top-left": radius,
      "top-right": radius,
      "bottom-left": radius,
      "bottom-right": radius,
    )
  } else if type(radius) == dictionary {
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
      "top-left": top-left,
      "top-right": top-right,
      "bottom-left": bottom-left,
      "bottom-right": bottom-right,
    )
  } else {
    panic("normalize-radius: radius must be of type length or dictionary, got " + str(type(radius)))
  }
}

/// Interpolates the gradient stops based on the color space.
///
/// - gradient (gradient): The gradient.
/// -> array
#let interpolate-stops(gradient) = {
  let in-stops = gradient.stops()
  let stop-count = in-stops.len()
  let len = calc.max(int(256 / stop-count), 2)
  let stops = ()

  for (from, to) in in-stops.windows(2) {
    let from-color = from.at(0)
    let to-color = to.at(0)
    let from-offset = from.at(1)
    let to-offset = to.at(1)
    let delta = to-offset - from-offset

    // No interpolation needed for identical colors
    if from-color == to-color {
      len = 1
    }

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
/// - angle (angle): The angle.
/// -> integer
#let angle-quadrant(angle) = {
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
/// - angle (angle): The angle.
/// - ratio (integer, float): The ratio.
/// -> angle
#let correct-angle(angle, ratio) = {
  let rad = calc.atan(calc.tan(calc.rem-euclid(angle.rad(), calc.tau)) / ratio).rad()
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
/// - angle (angle): The angle.
/// - width (integer, float, length): The width.
/// - height (integer, float, length): The height.
/// -> array
#let calculate-gradient-vector(angle, width, height) = {
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
/// - stop (list): The stop in form of (color, ratio).
/// -> string
#let stop-template(stop) = {
  let stop-color = stop.at(0).to-hex()
  let offset = stop.at(1) / 1%

  "<stop offset=\"" + str(offset) + "%\" stop-color=\"" + str(stop-color) + "\" />"
}

/// Renders a linear gradient.
///
/// - gradient (gradient): The gradient of kind gradient.linear.
/// - gradient-width (integer, float): The width of the gradient.
/// - gradient-height (integer, float): The height of the gradient.
/// -> string
#let linear-gradient-template(gradient, gradient-width, gradient-height) = {
  let interpolated-stops = interpolate-stops(gradient)
  let stops = interpolated-stops.map(stop => stop-template(stop)).join()

  let (x1, y1, x2, y2) = calculate-gradient-vector(gradient.angle(), gradient-width, gradient-height)

  // Replace Unicode minus sign with ASCII hyphen-minus to avoid SVG parsing issues
  // x1 and y1 are always positive
  let x2 = str(x2).replace("\u{2212}", "\u{002D}")
  let y2 = str(y2).replace("\u{2212}", "\u{002D}")

  (
    "<linearGradient id=\"gradient\" gradientUnits=\"userSpaceOnUse\" x1=\""
      + str(x1)
      + "\" y1=\""
      + str(y1)
      + "\" x2=\""
      + str(x2)
      + "\" y2=\""
      + str(y2)
      + "\" gradientTransform=\"matrix("
      + str(gradient-width)
      + " 0 0 "
      + str(gradient-height)
      + " 0 0)\"> "
      + str(stops)
      + " </linearGradient>"
  )
}

/// Renders a radial gradient.
///
/// - gradient (gradient): The gradient of kind gradient.radial.
/// -> string
#let radial-gradient-template(gradient, gradient-width, gradient-height) = {
  let center-x = gradient.center().at(0) / 100%
  let center-y = gradient.center().at(1) / 100%
  let focal-center-x = gradient.focal-center().at(0) / 100%
  let focal-center-y = gradient.focal-center().at(1) / 100%
  let radius = gradient.radius() / 100%
  let focal-radius = gradient.focal-radius() / 100%
  let stops = gradient.stops().map(stop => stop-template(stop)).join()

  (
    "<radialGradient id=\"gradient\" gradientUnits=\"userSpaceOnUse\" cx=\""
      + str(center-x)
      + "\" cy=\""
      + str(center-y)
      + "\" fx=\""
      + str(focal-center-x)
      + "\" fy=\""
      + str(focal-center-y)
      + "\" r=\""
      + str(radius)
      + "\" fr=\""
      + str(focal-radius)
      + "\" gradientTransform=\"matrix("
      + str(gradient-width)
      + " 0 0 "
      + str(gradient-height)
      + " 0 0)\"> "
      + str(stops)
      + " </radialGradient>"
  )
}

/// Renders a gradient based on its kind.
///
/// - gradient (gradient): The gradient of kind gradient.linear or gradient.radial.
/// - gradient-width (integer, float): The gradient width.
/// - gradient-height (integer, float): The gradient height.
/// -> string
#let gradient-template(gradient, gradient-width, gradient-height) = {
  if gradient.kind() == std.gradient.linear {
    linear-gradient-template(gradient, gradient-width, gradient-height)
  } else if gradient.kind() == std.gradient.radial {
    radial-gradient-template(gradient, gradient-width, gradient-height)
  } else {
    panic("gradient-template: gradient must be of kind linear or radial")
  }
}

/// Renders a SVG box shadow.
///
/// - svg-width (integer, float): The SVG width.
/// - svg-height (integer, float): The SVG height.
/// - blur-deviation (integer, float): The blur deviation.
/// - spread-radius (integer, float): The spread radius.
/// - fill (color, gradient): The fill color or gradient.
/// - rect-dx (integer, float): The gradient x position.
/// - rect-dy (integer, float): The gradient y position.
/// - rect-width (integer, float): The gradient width.
/// - rect-height (integer, float): The gradient height.
/// - radius-tl (integer, float): The top-left radius.
/// - radius-tr (integer, float): The top-right radius.
/// - radius-bl (integer, float): The bottom-left radius.
/// - radius-br (integer, float): The bottom-right radius.
/// -> string
#let shadow-template(
  svg-width: none,
  svg-height: none,
  blur-deviation: none,
  spread-radius: none,
  fill: none,
  rect-dx: none,
  rect-dy: none,
  rect-width: none,
  rect-height: none,
  radius-tl: none,
  radius-tr: none,
  radius-bl: none,
  radius-br: none,
) = {
  let gradient = if type(fill) == gradient { gradient-template(fill, svg-width, svg-height) } else { "" }
  let fill = if type(fill) == color { fill.to-hex() } else { "url(#gradient)" }
  let spread-operator = if spread-radius >= 0 { "dilate" } else { "erode" }

  (
    "<svg viewBox=\"0 0 "
      + str(svg-width)
      + " "
      + str(svg-height)
      + "\" height=\""
      + str(svg-height)
      + "\" width=\""
      + str(svg-width)
      + "\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\"> <defs> "
      + str(gradient)
      + " <filter id=\"shadow\" filterUnits=\"userSpaceOnUse\" primitiveUnits=\"userSpaceOnUse\" x=\"-10%\" y=\"-10%\" width=\"120%\" height=\"120%\"> <feGaussianBlur in=\"SourceGraphic\" stdDeviation=\""
      + str(blur-deviation)
      + "\" result=\"blur\" /> <feMorphology operator=\""
      + str(spread-operator)
      + "\" radius=\""
      + str(spread-radius)
      + "\" in=\"blur\" result=\"spread\" /> </filter> </defs> <path d=\" M "
      + str(rect-dx + radius-tl)
      + ", "
      + str(rect-dy)
      + " H "
      + str(rect-dx + rect-width - radius-tr)
      + " A "
      + str(radius-tr)
      + " "
      + str(radius-tr)
      + " 0 0 1 "
      + str(rect-dx + rect-width)
      + ", "
      + str(rect-dy + radius-tr)
      + " V "
      + str(rect-dy + rect-height - radius-br)
      + " A "
      + str(radius-br)
      + " "
      + str(radius-br)
      + " 0 0 1 "
      + str(rect-dx + rect-width - radius-br)
      + ", "
      + str(rect-dy + rect-height)
      + " H "
      + str(rect-dx + radius-bl)
      + " A "
      + str(radius-bl)
      + " "
      + str(radius-bl)
      + " 0 0 1 "
      + str(rect-dx)
      + ", "
      + str(rect-dy + rect-height - radius-bl)
      + " V "
      + str(rect-dy + radius-tl)
      + " A "
      + str(radius-tl)
      + " "
      + str(radius-tl)
      + " 0 0 1 "
      + str(rect-dx + radius-tl)
      + ", "
      + str(rect-dy)
      + " Z \" fill=\""
      + str(fill)
      + "\" filter=\"url(#shadow)\" /> </svg>"
  )
}

#let shadow(dx: 0pt, dy: 0pt, blur: 0pt, spread: 0pt, fill: black, radius: 0pt, body) = layout(
  size => {
    // Type checks
    assert(type(dx) == length, message: "shadow: dx must be of type length")
    assert(type(dy) == length, message: "shadow: dy must be of type length")
    assert(type(blur) == length, message: "shadow: blur must be of type length")
    assert(type(spread) == length, message: "shadow: spread must be of type length")
    assert(
      type(fill) == color or type(fill) == gradient,
      message: "shadow: fill must be of type color or gradient",
    )
    assert(
      type(radius) == length or type(radius) == dictionary,
      message: "shadow: radius must be of type length or dictionary",
    )

    // Value checks
    assert(blur >= 0pt, message: "shadow: blur must be greater or equal to zero")

    // Conditional checks based on radius type
    if type(radius) == length {
      assert(radius >= 0pt, message: "shadow: radius must be greater or equal to zero")
    } else {
      for r in radius.values() {
        assert(type(r) == length, message: "shadow: radius values must be of type length")
        assert(r >= 0pt, message: "shadow: radius values must be greater or equal to zero")
      }
    }

    let (width, height) = measure(width: size.width, height: size.height)[
      #body
    ]

    // Return empty block if width or height are zero to avoid issues with dividing by zero
    if (width == 0pt or height == 0pt) {
      return block()
    }

    let outset = calc.max(blur + spread, 0pt)

    let radius = normalize-radius(radius)

    let svg-height = height + outset * 2
    let svg-width = width + outset * 2
    let blur-deviation = blur * blur-to-deviation-factor

    let svg-source = shadow-template(
      svg-width: svg-width.pt(),
      svg-height: svg-height.pt(),
      blur-deviation: blur-deviation.pt(),
      spread-radius: spread.pt(),
      fill: fill,
      rect-dx: outset.pt(),
      rect-dy: outset.pt(),
      rect-width: width.pt(),
      rect-height: height.pt(),
      radius-tl: radius.at("top-left").pt(),
      radius-tr: radius.at("top-right").pt(),
      radius-bl: radius.at("bottom-left").pt(),
      radius-br: radius.at("bottom-right").pt(),
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
