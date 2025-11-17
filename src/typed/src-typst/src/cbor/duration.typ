/// Encode a duration into a CBOR-compatible float.
///
/// - duration (duration): A duration.
/// -> float
#let encode(duration) = {
  assert(type(duration) == std.duration, message: "duration.encode: duration must be type of duration")

  duration.seconds()
}
