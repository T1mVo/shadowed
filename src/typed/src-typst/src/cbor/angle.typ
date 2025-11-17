/// Encode an angle into a CBOR-compatible float.
///
/// - angle (angle): A angle.
/// -> float
#let encode(angle) = {
  assert(type(angle) == std.angle, message: "angle.encode: angle must be type of angle")

  angle.rad()
}
