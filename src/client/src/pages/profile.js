import './profile.css';
import { useState, useEffect } from 'react';
import { useParams } from "react-router-dom";
import { getProfileAsync } from '../utils/api';
import Button from 'react-bootstrap/Button';

export function Profile() {
    let params = useParams();
    const [token, setToken] = useState(null);
    useEffect(() => {
        async function getToken() {
            const token = await getProfileAsync(params.uid);
            setToken(token);
        }
        getToken();
    }, [])
    if (!token) {
        return <div></div>;
    }
    return (
        <div className="page-container">
            <div className="profile-container">
                <h1>{token.username}</h1>
                <h2>is {token.headline}!</h2>
                <hr/>
                <br/>
                <p className="profile-description">{token.description}</p>
                <div className="donations-container">
                    <Button variant="warning">Donate</Button>    
                </div>
            </div>
        </div>
    )
}