export const api_uri = "https://pxz4qhgbjk.execute-api.eu-west-1.amazonaws.com";

export async function sendPayment({ to, from, amount }) {
    let response = await fetch(`${api_uri}/pay`, {
        method: 'POST',
        redirect: 'follow',
        body: JSON.stringify({
            "to": to,
            "amount": parseInt(amount),
            "from": from
        })
    }).then(response => {
        console.log(response);
        if (response.redirected) {
            window.location.href = response.url;
        }
    });
    return response;
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