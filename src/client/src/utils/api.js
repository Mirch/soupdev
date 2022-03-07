const api_uri = "https://ahx9w3qr4k.execute-api.eu-west-1.amazonaws.com";

export async function getProfileAsync(username) {
    let response = await fetch(`${api_uri}/profile?username=${username}`);
    let data = await response.json();
    return data;
}