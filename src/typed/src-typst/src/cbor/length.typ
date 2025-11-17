/// Encode a length into a CBOR-compatible float.
///
/// - length (length): A length.
/// -> float
#let encode(length) = {
  length.pt()
}
