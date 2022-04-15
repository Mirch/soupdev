import "./donations.css";

export function DonationsContainer(props) {
    return (
        <div class="donations-container">
            {props.children}
        </div>
    );
}