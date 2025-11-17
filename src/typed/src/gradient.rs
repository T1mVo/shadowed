use serde::{Deserialize, Serialize};

use crate::{Angle, Center, FromBytes, Ratio, Stop};

/// An enum representing different types of gradients with specific parameters for each type.
#[derive(Serialize, Deserialize, Debug)]
#[serde(rename_all = "kebab-case", untagged)]
pub enum Gradient {
    Linear {
        stops: Vec<Stop>,
        angle: Angle,
    },
    Radial {
        stops: Vec<Stop>,
        center: Center,
        radius: Ratio,
        focal_center: Center,
        focal_radius: Ratio,
    },
    Conic {
        stops: Vec<Stop>,
        angle: Angle,
        center: Center,
    },
}

impl FromBytes for Gradient {
    fn from_bytes(bytes: &[u8]) -> Result<Self, String> {
        ciborium::from_reader(bytes).map_err(|err| err.to_string())
    }
}
