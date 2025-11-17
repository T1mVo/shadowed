use serde::{Deserialize, Serialize};

use crate::FromBytes;

/// A structure representing an angle in radians.
///
/// The `Angle` type can convert between radians and degrees.
#[derive(Serialize, Deserialize, Debug)]
#[serde(transparent)]
pub struct Angle {
    pub radians: f64,
}

impl Angle {
    /// Creates a new `Angle` instance from the given radians.
    ///
    /// # Arguments
    ///
    /// * `radians` - The angle in radians to create an `Angle` from.
    ///
    /// # Examples
    ///
    /// ```
    /// let angle = Angle::new(1.0);
    /// assert_eq!(angle.rad(), 1.0);
    /// ```
    pub const fn new(radians: f64) -> Self {
        Self { radians }
    }

    /// Returns the angle in radians.
    ///
    /// # Examples
    ///
    /// ```
    /// let angle = Angle { inner: 1.0 };
    /// assert_eq!(angle.rad(), 1.0);
    /// ```
    pub const fn rad(&self) -> f64 {
        self.radians
    }

    /// Returns the angle in degrees.
    ///
    /// # Examples
    ///
    /// ```
    /// let angle = Angle { inner: std::f64::consts::PI };
    /// assert_eq!(angle.deg(), 180.0);
    /// ```
    pub const fn deg(&self) -> f64 {
        self.radians * 180.0 / std::f64::consts::PI
    }
}

impl FromBytes for Angle {
    fn from_bytes(bytes: &[u8]) -> Result<Self, String> {
        ciborium::from_reader(bytes).map_err(|err| err.to_string())
    }
}
