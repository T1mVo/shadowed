use serde::{Deserialize, Serialize};

use crate::{FromBytes, Gradient};

/// A structure representing a color with red, green, blue, and alpha components.
#[derive(Serialize, Deserialize, Debug)]
pub struct Color {
    pub r: u8,
    pub g: u8,
    pub b: u8,
    pub a: u8,
}

impl Color {
    /// Creates a new `Color` instance from the given red, green, blue, and alpha components.
    ///
    /// # Arguments
    ///
    /// * `r` - The red component.
    /// * `g` - The green component.
    /// * `b` - The blue component.
    /// * `a` - The alpha component.
    ///
    /// # Examples
    ///
    /// ```
    /// let color = Color::new(255, 0, 0, 255);
    /// assert_eq!(color.r, 255);
    /// assert_eq!(color.g, 0);
    /// assert_eq!(color.b, 0);
    /// assert_eq!(color.a, 255);
    /// ```
    pub const fn new(r: u8, g: u8, b: u8, a: u8) -> Self {
        Self { r, g, b, a }
    }

    /// Converts the color to a hexadecimal string representation.
    ///
    /// # Examples
    ///
    /// ```
    /// let color = Color { r: 255, g: 255, b: 255, a: 255 };
    /// assert_eq!(color.to_hex(), "#ffffffff");
    /// ```
    pub fn to_hex(&self) -> String {
        format!("#{:02x}{:02x}{:02x}{:02x}", self.r, self.g, self.b, self.a)
    }
}

impl FromBytes for Color {
    fn from_bytes(bytes: &[u8]) -> Result<Self, String> {
        ciborium::from_reader(bytes).map_err(|err| err.to_string())
    }
}

#[derive(Serialize, Deserialize, Debug)]
#[serde(rename_all = "lowercase", untagged)]
/// An enum representing either a single color or a gradient.
pub enum ColorGradient {
    Color(Color),
    Gradient(Gradient),
}

impl FromBytes for ColorGradient {
    fn from_bytes(bytes: &[u8]) -> Result<Self, String> {
        ciborium::from_reader(bytes).map_err(|err| err.to_string())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn to_hex() {
        let color = Color {
            r: 170,
            g: 187,
            b: 204,
            a: 10,
        };

        let hex = color.to_hex();

        assert_eq!("#aabbcc0a", hex);
    }
}
