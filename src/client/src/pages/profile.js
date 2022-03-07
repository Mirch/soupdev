import { useState, useEffect } from 'react';
import { useParams } from "react-router-dom";
import { getProfileAsync } from '../utils/api';
import './profile.css';

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
    return (
        <div class="page-container">
            <div class="profile-container">
                <h1>{token ? token.username : "user"}</h1>
                <h2> says hi!</h2>
            </div>
        </div>
    )
}