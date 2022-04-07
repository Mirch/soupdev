use std::collections::HashMap;

use aws_sdk_dynamodb::model::AttributeValue;
use serde::{Serialize, Deserialize};

#[derive(Serialize, Deserialize, PartialEq)]
pub enum PaymentStatus {
    Pending = 0,
    Paid = 1,
    Cancelled = 2,
}

impl PaymentStatus {
    pub fn from_int(value: i32) -> PaymentStatus {
        match value {
            x if x == PaymentStatus::Pending as i32 => PaymentStatus::Pending,
            x if x == PaymentStatus::Paid as i32 => PaymentStatus::Paid,
            x if x == PaymentStatus::Cancelled as i32 => PaymentStatus::Cancelled,
            _ => panic!("Could not convert value.")
        }
    }
}

#[derive(Serialize, Deserialize)]
pub struct Payment {
    pub id: String,
    pub from: String,
    pub to: String,
    pub intent_id: String,
    pub amount: i32,
    pub status: PaymentStatus
}

impl Payment {
    pub fn from_dynamo_hashmap(map: &HashMap<String, AttributeValue>) -> Payment {
        let id = match &map["id"] {
            AttributeValue::S(value) => value.clone(),
            _ => "".to_string()
        };
        let from = match &map["from"] {
            AttributeValue::S(value) => value.clone(),
            _ => "".to_string()
        };
        let to = match &map["to"] {
            AttributeValue::S(value) => value.clone(),
            _ => "".to_string()
        };
        let intent_id = match &map["intent_id"] {
            AttributeValue::S(value) => value.clone(),
            _ => "".to_string()
        };
        let amount = match &map["amount"] {
            AttributeValue::N(value) => value.parse().unwrap(),
            _ => 0
        };
        let status = match &map["status"] {
            AttributeValue::N(value) => value.parse().unwrap(),
            _ => 0
        };

        Payment {
            id: id,
            from: from,
            to: to,
            intent_id: intent_id,
            amount: amount,
            status: PaymentStatus::from_int(status)
        }
    }
}
