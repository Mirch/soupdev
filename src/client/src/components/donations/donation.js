export function Donation(props) {
    let from = props.from;
    let amount = props.amount / 100.0;
    let dateOptions = {year: 'numeric', month: 'long', day: 'numeric' };
    let date = new Date(props.date).toLocaleString("en-US", dateOptions);

    return (
        <div className="donation">
            <h6>{date}</h6>
            <h3>{from}</h3> donated <b>${amount}</b>.
        </div>
    );
}