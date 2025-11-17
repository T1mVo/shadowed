#import "angle.typ"
#import "center.typ"
#import "ratio.typ"
#import "stop.typ"
#import "utils.typ"

/// Encode a gradient into a CBOR-compatible dictionary.
///
/// - gradient (gradient): A gradient.
/// -> dictionary
#let encode(gradient) = {
  assert(type(gradient) == std.gradient, message: "gradient.encode: gradient must be type of gradient")

  let result = (:)

  let type = if gradient.kind() == std.gradient.linear {
    "linear"
  } else if gradient.kind() == std.gradient.radial {
    "radial"
  } else if gradient.kind() == std.gradient.conic {
    "conic"
  } else {
    panic("gradient.encode: Invalid gradient type")
  }

  // Add stops
  let stops = gradient.stops().map(s => stop.encode(s.at(0), s.at(1)))
  result.insert("stops", stops)

  // Add angle
  if type == "linear" or type == "conic" {
    let angle = angle.encode(gradient.angle())
    result.insert("angle", angle)
  }

  // Add center
  if type == "radial" or type == "conic" {
    let center = center.encode(..gradient.center())
    result.insert("center", center)
  }

  // Add radius
  if type == "radial" {
    let radius = ratio.encode(gradient.radius())
    result.insert("radius", radius)
  }

  // Add focal-center {
  if type == "radial" {
    let focal_center = center.encode(..gradient.focal-center())
    result.insert("focal-center", focal_center)
  }

  // Add focal-radius
  if type == "radial" {
    let focal_radius = ratio.encode(gradient.focal-radius())
    result.insert("focal-radius", focal_radius)
  }

  result
}
