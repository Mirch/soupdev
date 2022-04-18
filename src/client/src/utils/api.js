export const api_uri = "https://pxz4qhgbjk.execute-api.eu-west-1.amazonaws.com";

export async function sendPayment({to, from, amount}) {
    let response = await fetch(`${api_uri}/pay`, {
        method: 'POST',
        body: {
            "to": to,
            "amount": amount,
            "from": from
        }
      });
    let result = await response.json();
    return result;
}

export async function getProfileAsync(username) {
    let response = await fetch(`${api_uri}/profile?username=${username}`);
    let data = await response.json();
    return data;
}

export async function getDonationsAsync(username) {
    let response = await fetch(`${api_uri}/payments?username=${username}`);
    let data = await response.json();
    return data;
}