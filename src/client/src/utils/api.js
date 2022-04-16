export const api_uri = "https://pxz4qhgbjk.execute-api.eu-west-1.amazonaws.com";

export async function getProfileAsync(username) {
    let response = await fetch(`${api_uri}/profile?username=${username}`);
    let data = await response.json();
    return data;
}

export async function getDonationsAsync(username) {
    let response = await fetch(`${api_uri}/payments?username=${username}`);
    let data = await response.json();
    console.log(data);
    return data;
}