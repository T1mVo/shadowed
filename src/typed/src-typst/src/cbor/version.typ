#let max-components = 5

/// Encode a version into CBOR-compatible array.
/// 
/// Only the first five components are considered.
///
/// - version (version): A version.
/// -> array
#let encode(version) = {
  assert(type(version) == std.version, message: "version.encode: version must be type of version")

  let result = ()
  
  for i in range(max-components) {
    result.push(version.at(i))
  }
  
  result
}
