import './profile.css';
import { useState, useEffect } from 'react';
import { useParams } from "react-router-dom";
import { getProfileAsync } from '../utils/api';
import Button from 'react-bootstrap/Button';
import { api_uri } from '../utils/api';

import { Payment } from '../components/payment';

export function Profile() {
    let params = useParams();
    const [token, setToken] = useState(null);
    useEffect(() => {
        async function getToken() {
            const token = await getProfileAsync(params.username);
            setToken(token);
        }
        getToken();
    }, [])
    const [donation, setDonation] = useState(5);

    if (!token) {
        return <div></div>;
    }
    let paymentQuery = `/pay?to=${token.username}&donation=${donation}`;
    return (
        <div className="page-container">
            <div className="profile-container">
                <h1>{token.username}</h1>
                <h2>is {token.headline}!</h2>
                <hr />
                <br />
                <p className="profile-description">{token.description}</p>
                <div className="donations-container">
                    <form action={api_uri + paymentQuery} method="POST">
                        <input type="number" value={donation} onChange={event => setDonation(event.target.value)}/>
                        <button type="submit">Checkout</button>
                    </form>
                </div>
            </div>
        </div>
    )
}