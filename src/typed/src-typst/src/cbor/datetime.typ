/// Encode a datetime into a CBOR-compatible dictionary.
///
/// - datetime (datetime): A datetime.
/// -> dictionary
#let encode(datetime) = {
  assert(type(datetime) == std.datetime, message: "datetime.encode: datetime must be type of datetime")

  (
    "year": datetime.year(),
    "month": datetime.month(),
    "day": datetime.day(),
    "hour": datetime.hour(),
    "minute": datetime.minute(),
    "second": datetime.second(),
  )
}
