#import "utils.typ"
/// Encode a color into a CBOR-compatible map.
///
/// - color (color): 
/// -> dictionary
#let encode(color) = {
  assert(type(color) == std.color, message: "color.encode: color must be type of color")

  let components = color.rgb().components().map(component => utils.ratio-to-int(component))

  (
    "r": components.at(0),
    "g": components.at(1),
    "b": components.at(2),
    "a": components.at(3),
  )
}
