pub enum PaymentStatus {
    Pending = 0,
    Paid = 1,
    Cancelled = 2
}

pub struct Payment {
    pub id: String,
    pub from: String,
    pub to: String,
    pub intent_id: String,
    pub amount: i32
}