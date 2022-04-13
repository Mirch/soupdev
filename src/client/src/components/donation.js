export function Donation(props) {
    let donor = props.donor;
    let donation = props.donation;
    let date = props.date;

    return (
        <div>
            <h6>{date}</h6>
            <h3>{donor}</h3> donated <b>${donation}</b>.
        </div>
    );
}