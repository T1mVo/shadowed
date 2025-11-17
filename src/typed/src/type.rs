use serde::{Deserialize, Serialize};

use crate::FromBytes;

/// A structure representing a type defined by a string.
#[derive(Serialize, Deserialize, PartialEq, Eq, Debug)]
#[serde(transparent)]
pub struct Type {
    pub r#type: String,
}

impl Type {
    /// Creates a new `Type` instance from the given string.
    ///
    /// # Arguments
    ///
    /// * `r#type` - A string representing the type.
    ///
    /// # Examples
    ///
    /// ```
    /// let custom_type = Type::new(String::from("CustomType"));
    /// assert_eq!(custom_type.r#type, "CustomType");
    /// ```
    pub const fn new(r#type: String) -> Self {
        Self { r#type }
    }
}

impl FromBytes for Type {
    fn from_bytes(bytes: &[u8]) -> Result<Self, String> {
        ciborium::from_reader(bytes).map_err(|err| err.to_string())
    }
}
