use std;

pub fn get_env_variable(var_name: &str) -> String {
    let env_variable = match std::env::var_os(var_name) {
        Some(v) => v.into_string().unwrap(),
        None => panic!("{} is not set.", var_name),
    };

    return env_variable;
}

// General
pub const DOMAIN: &str = "DOMAIN";

// Payments
pub const PAYMENTS_TABLE_NAME: &str = "PAYMENTS_TABLE_NAME";
pub const ORDER_ID_INDEX_NAME: &str = "ORDER_ID_INDEX_NAME";
pub const TO_INDEX_NAME: &str = "TO_INDEX_NAME";


// Users
pub const USERS_TABLE_NAME: &str = "USERS_TABLE_NAME";
pub const USERS_USERNAME_INDEX: &str = "USERS_USERNAME_INDEX";

// Stripe
pub const STRIPE_WEBHOOK_SECRET: &str = "STRIPE_WEBHOOK_SECRET";
