const api_uri = "https://ahx9w3qr4k.execute-api.eu-west-1.amazonaws.com";

export async function getProfileAsync(uid) {
    let response = await fetch(`${api_uri}/profile?uid=${uid}`);
    let data = await response.json();
    return data;
}