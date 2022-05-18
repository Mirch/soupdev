use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize)]
pub struct User {
    pub uid: String,
    pub username: String,
    pub headline: String,
    pub description: String,
}

impl User {
    pub fn empty() -> User {
        User {
            uid: "".to_string(),
            username: "".to_string(),
            headline: "".to_string(),
            description: "".to_string(),
        }
    }
}
