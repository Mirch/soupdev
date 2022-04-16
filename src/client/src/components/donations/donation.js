export function Donation(props) {
    let from = props.from;
    let amount = props.amount / 100.0;
    let date = props.date;

    return (
        <div>
            <h6>{date}</h6>
            <h3>{from}</h3> donated <b>${amount}</b>.
        </div>
    );
}