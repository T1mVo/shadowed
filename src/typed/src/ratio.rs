use serde::{Deserialize, Serialize};

use crate::FromBytes;

/// A structure representing a ratio from 0 to 1.
#[derive(Serialize, Deserialize, Debug)]
#[serde(transparent)]
pub struct Ratio {
    pub ratio: f64,
}

impl Ratio {
    /// Creates a new `Ratio` instance from a given floating-point value.
    ///
    /// # Arguments
    ///
    /// * `ratio` - A floating-point value representing the ratio (expected to be between 0 and 1).
    ///
    /// # Examples
    ///
    /// ```
    /// let ratio = Ratio::new(0.5);
    /// assert_eq!(ratio.ratio, 0.5);
    /// ```
    pub const fn new(ratio: f64) -> Self {
        Self { ratio }
    }

    /// Converts the ratio to a percentage string representation.
    ///
    /// # Examples
    ///
    /// ```
    /// let ratio = Ratio::new(0.75);
    /// assert_eq!(ratio.to_percentage(), "75%");
    /// ```
    pub fn to_percentage(&self) -> String {
        format!("{}%", self.ratio * 100.0)
    }
}

impl FromBytes for Ratio {
    fn from_bytes(bytes: &[u8]) -> Result<Self, String> {
        ciborium::from_reader(bytes).map_err(|err| err.to_string())
    }
}
