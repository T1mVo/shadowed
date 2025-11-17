#import "utils.typ"

/// Encode a ratio into a CBOR-compatible float.
///
/// - ratio (ratio): A ratio of any value.
/// -> float
#let encode(ratio) = {
  utils.ratio-to-float(ratio)
}
