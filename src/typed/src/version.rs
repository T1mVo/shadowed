use serde::{Deserialize, Serialize};

use crate::FromBytes;

/// A structure representing version with 5 components.
#[derive(Serialize, Deserialize, PartialEq, Eq, Debug)]
#[serde(transparent)]
pub struct Version {
    pub components: [u32; 5],
}

impl FromBytes for Version {
    fn from_bytes(bytes: &[u8]) -> Result<Self, String> {
        ciborium::from_reader(bytes).map_err(|err| err.to_string())
    }
}
