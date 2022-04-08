use std::{collections::HashMap, str::FromStr};

use aws_sdk_dynamodb::model::AttributeValue;
use chrono::{DateTime, Utc, prelude::*};
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
            _ => panic!("Could not convert value {}.", value)
        }
    }
}

#[derive(Serialize, Deserialize)]
pub struct Payment {
    pub id: String,
    pub from: String,
    pub to: String,
    pub order_id: String,
    pub amount: i32,
    pub status: PaymentStatus,
    pub created: DateTime<Utc>
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
        let order_id = match &map["order_id"] {
            AttributeValue::S(value) => value.clone(),
            _ => "".to_string()
        };
        let amount = match &map["amount"] {
            AttributeValue::N(value) => value.parse().unwrap(),
            _ => 0
        };
        let status = match &map["status"] {
            AttributeValue::N(value) => value.parse().unwrap(),
            _ => -1
        };
        let created = match &map["created"] {
            AttributeValue::S(value) => value.clone(),
            _ => "".to_string()
        };

        Payment {
            id,
            from,
            to,
            order_id,
            amount,
            status: PaymentStatus::from_int(status),
            created: created.parse::<DateTime<Utc>>().unwrap()
        }
    }
}


#[derive(Serialize, Deserialize)]
pub struct PaymentDTO {
    pub from: String,
    pub to: String,
    pub amount: i32,
    pub created: String
}

impl PaymentDTO {
    pub fn from_payment(payment: Payment) -> PaymentDTO {
        PaymentDTO {
           from: payment.from,
           to: payment.to,
           amount: payment.amount,
           created: payment.created.to_string()
        }
    }
}