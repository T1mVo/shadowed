use serde::{Deserialize, Serialize};

use crate::FromBytes;

const SECONDS_IN_MINUTE: f64 = 60.0;
const MINUTES_IN_HOUR: f64 = 60.0;
const HOURS_IN_DAY: f64 = 24.0;
const DAYS_IN_WEEK: f64 = 7.0;

/// A structure representing a duration of time in seconds.
#[derive(Serialize, Deserialize, Debug)]
#[serde(transparent)]
pub struct Duration {
    pub seconds: f64,
}

impl Duration {
    /// Returns the total duration in seconds.
    pub const fn seconds(&self) -> f64 {
        self.seconds
    }

    /// Returns the total duration in minutes.
    pub const fn minutes(&self) -> f64 {
        self.seconds() / SECONDS_IN_MINUTE
    }

    /// Returns the total duration in hours.
    pub const fn hours(&self) -> f64 {
        self.minutes() / MINUTES_IN_HOUR
    }

    /// Returns the total duration in days.
    pub const fn days(&self) -> f64 {
        self.hours() / HOURS_IN_DAY
    }

    /// Returns the total duration in weeks.
    pub const fn weeks(&self) -> f64 {
        self.days() / DAYS_IN_WEEK
    }
}

impl FromBytes for Duration {
    fn from_bytes(bytes: &[u8]) -> Result<Self, String> {
        ciborium::from_reader(bytes).map_err(|err| err.to_string())
    }
}
