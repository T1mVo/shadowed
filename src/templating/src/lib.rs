use serde::Deserialize;
use typed::{ColorGradient, FromBytes, Length, LengthRadius, Radius};
use wasm_minimal_protocol::*;

initiate_protocol!();

#[wasm_func]
fn template(arg: &[u8]) -> Result<Vec<u8>, String> {
    let options = Options::from_bytes(arg)?;

    Ok(arg.to_owned())
}

#[derive(Deserialize)]
#[serde(rename_all = "kebab-case")]
struct Options {
    svg_height: Length,
    svg_width: Length,
    blur: Length,
    spread: Length,
    fill: ColorGradient,
    rect_height: Length,
    rect_width: Length,
    outset: Length,
    radius: LengthRadius,
}

impl FromBytes for Options {
    fn from_bytes(bytes: &[u8]) -> Result<Self, String> {
        ciborium::from_reader(bytes).map_err(|err| err.to_string())
    }
}
