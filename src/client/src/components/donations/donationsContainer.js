import "./donations.css";

export function DonationsContainer(props) {
    return (
        <div className="donations-container">
            {props.children}
        </div>
    );
}