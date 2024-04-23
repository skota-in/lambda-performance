const timestamp = new Date().toISOString();
export const handler = async (event) => {
    return {
        statusCode: 200,
        body: {timestamp, message: 'Hello from Lambda!'}
    };
};
