use serde::{Deserialize, Serialize};

use crate::{Color, FromBytes, Ratio};

/// A structure representing a color stop in a gradient with a specified color and offset.
#[derive(Serialize, Deserialize, Debug)]
pub struct Stop {
    pub color: Color,
    pub offset: Ratio,
}

impl Stop {
    /// Creates a new `Stop` instance with the specified color and offset.
    ///
    /// # Arguments
    ///
    /// * `color` - The color of the stop in the gradient.
    /// * `offset` - The offset of the stop, represented as a ratio.
    ///
    /// # Examples
    ///
    /// ```
    /// let stop = Stop::new(Color::red(), Ratio::from(0.5));
    /// assert_eq!(stop.color, Color::red());
    /// assert_eq!(stop.offset, Ratio::from(0.5));
    /// ```
    pub const fn new(color: Color, offset: Ratio) -> Self {
        Self { color, offset }
    }
}

impl FromBytes for Stop {
    fn from_bytes(bytes: &[u8]) -> Result<Self, String> {
        ciborium::from_reader(bytes).map_err(|err| err.to_string())
    }
}
