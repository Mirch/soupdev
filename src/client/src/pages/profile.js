import './profile.css';
import { useState, useEffect } from 'react';
import { useParams } from "react-router-dom";
import { getProfileAsync, getDonationsAsync, sendPayment } from '../utils/api';
import { api_uri } from '../utils/api';

import { DonationsContainer } from '../components/donations/donationsContainer';
import { Donation } from '../components/donations/donation';

export function Profile() {
    let params = useParams();
    const [profile, setProfile] = useState(null);
    useEffect(() => {
        async function getProfile() {
            const profile = await getProfileAsync(params.username);
            setProfile(profile);
        }
        getProfile();
    }, []);
    const [donation, setDonation] = useState(5);
    const [donor, setDonor] = useState("");
    const [donations, setDonations] = useState(null);
    useEffect(() => {
        async function getDonations() {
            const donations = await getDonationsAsync(params.username);
            setDonations(donations);
        }
        getDonations();
    }, []);


    if (!profile || !donations) {
        return <div></div>;
    }
    return (
        <div className="page-container">
            <div className="profile-container">
                <h1>{profile.username}</h1>
                <h2>is {profile.headline}!</h2>
                <hr />
                <br />
                <p className="profile-description">{profile.description}</p>
                <div className="payment-container">
                    <form action={api_uri} method="POST">
                        <input
                            type="text"
                            placeholder='name'
                            value={donor}
                            onChange={event => setDonor(event.target.value)}
                        />
                        <input
                            type="number"
                            placeholder='5'
                            value={donation}
                            onChange={event => setDonation(event.target.value)}
                        />
                        <button
                            type="submit"
                            onSubmit={event => sendPayment({ to: profile.username, from: donor, amount: donation })}>
                            Checkout
                        </button>
                    </form>
                </div>
                <DonationsContainer>
                    {
                        donations.map((donation, index) => {
                            return <Donation key={index} from={donation.from} amount={donation.amount} date={donation.created} />
                        })
                    }
                </DonationsContainer>
            </div>
        </div>
    )
}