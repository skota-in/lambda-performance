export const handler = async (event) => {
    const users = await getUsers();
    const response = {
        statusCode: 200,
        body: users,
    };
    console.log('Sending', response);
    return response;
};

async function getUsers() {
    try {
        const response = await fetch('https://microsoftedge.github.io/Demos/json-dummy-data/5MB.json');
        const users = await response.json();
        return users.map(u => u.name);
    } catch (error) {
        console.error(error);
    }
}
