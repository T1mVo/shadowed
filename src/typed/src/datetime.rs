use serde::{Deserialize, Serialize};

use crate::FromBytes;

/// A struct representing a date and time with optional fields.
#[derive(Serialize, Deserialize, Debug)]
pub struct DateTime {
    pub year: Option<i64>,
    pub month: Option<i64>,
    pub day: Option<i64>,
    pub hour: Option<i64>,
    pub minute: Option<i64>,
    pub second: Option<i64>,
}

impl FromBytes for DateTime {
    fn from_bytes(bytes: &[u8]) -> Result<Self, String> {
        ciborium::from_reader(bytes).map_err(|err| err.to_string())
    }
}
