export const handler = async (event) => {
    const countries = await getCountries();
    const response = {
        statusCode: 200,
        body: countries,
    };
    console.log('Sending', response);
    return response;
};

async function getCountries() {
    try {
        const response = await fetch('https://restcountries.com/v3.1/all');
        const countries = await response.json();
        return countries.map(country => country.name);
    } catch (error) {
        console.error(error);
    }
}
