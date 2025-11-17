use serde::{Deserialize, Serialize};

use crate::{FromBytes, length::Length};

#[derive(Serialize, Deserialize, Debug)]
pub struct Radius {
    pub tl: Length,
    pub tr: Length,
    pub bl: Length,
    pub br: Length,
}

impl FromBytes for Radius {
    fn from_bytes(bytes: &[u8]) -> Result<Self, String> {
        ciborium::from_reader(bytes).map_err(|err| err.to_string())
    }
}
