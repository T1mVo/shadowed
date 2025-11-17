use serde::{Deserialize, Serialize};

use crate::{FromBytes, Radius};

/// A structure representing a length in points.
#[derive(Serialize, Deserialize, Debug)]
#[serde(transparent)]
pub struct Length {
    pub points: f64,
}

impl Length {
    /// Creates a new `Length` instance from a given number of points.
    ///
    /// # Arguments
    ///
    /// * `points` - A floating-point value representing the length in points.
    ///
    /// # Examples
    ///
    /// ```
    /// let length = Length::new(72.0);
    /// assert_eq!(length.pt(), 72.0);
    /// ```
    pub const fn new(points: f64) -> Self {
        Self { points }
    }

    /// Returns the length in points.
    ///
    /// # Examples
    ///
    /// ```
    /// let length = Length::new(72.0);
    /// assert_eq!(length.pt(), 72.0);
    /// ```
    pub const fn pt(&self) -> f64 {
        self.points
    }

    /// Converts the length to millimeters.
    ///
    /// # Examples
    ///
    /// ```
    /// let length = Length::new(72.0);
    /// assert_eq!(length.mm(), 25.4);
    /// ```
    pub const fn mm(&self) -> f64 {
        self.points * (25.4 / 72.0)
    }

    /// Converts the length to centimeters.
    ///
    /// # Examples
    ///
    /// ```
    /// let length = Length::new(720.0);
    /// assert_eq!(length.cm(), 25.4);
    /// ```
    pub const fn cm(&self) -> f64 {
        self.points * (25.4 / 720.0)
    }

    /// Converts the length to inches.
    ///
    /// # Examples
    ///
    /// ```
    /// let length = Length::new(72.0);
    /// assert_eq!(length.inches(), 1.0);
    /// ```
    pub const fn inches(&self) -> f64 {
        self.points / 72.0
    }
}

impl FromBytes for Length {
    fn from_bytes(bytes: &[u8]) -> Result<Self, String> {
        ciborium::from_reader(bytes).map_err(|err| err.to_string())
    }
}

#[derive(Serialize, Deserialize, Debug)]
#[serde(rename_all = "lowercase", untagged)]
/// An enum representing either a `Length` or a `Radius`.
pub enum LengthRadius {
    Length(Length),
    Radius(Radius),
}

impl FromBytes for LengthRadius {
    fn from_bytes(bytes: &[u8]) -> Result<Self, String> {
        ciborium::from_reader(bytes).map_err(|err| err.to_string())
    }
}
