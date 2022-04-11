import './profile.css';
import { useState, useEffect } from 'react';
import { useParams } from "react-router-dom";
import { getProfileAsync } from '../utils/api';
import Button from 'react-bootstrap/Button';
import { api_uri } from '../utils/api';

import { Payment } from '../components/payment';

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
    const [donor, setDonor] = useState(5);


    if (!profile) {
        return <div></div>;
    }
    let paymentQuery = `/pay?to=${profile.username}&donation=${donation}`;
    return (
        <div className="page-container">
            <div className="profile-container">
                <h1>{profile.username}</h1>
                <h2>is {profile.headline}!</h2>
                <hr />
                <br />
                <p className="profile-description">{profile.description}</p>
                <div className="donations-container">
                    <form action={api_uri + paymentQuery} method="POST">
                        <input type="text" value={donor} onChange={event => setDonor(event.target.value)} />
                        <input type="number" value={donation} onChange={event => setDonation(event.target.value)} />
                        <button type="submit">Checkout</button>
                    </form>
                </div>
            </div>
        </div>
    )
}