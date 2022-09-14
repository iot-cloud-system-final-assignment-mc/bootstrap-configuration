const buildResponse = (statusCode, body) => {
    return {
        statusCode: statusCode,
        body: JSON.stringify(body),
        headers: {
            "Access-Control-Allow-Headers": "Content-Type, Origin, X-Requested-With, Accept, Authorization, Access-Control-Allow-Methods, Access-Control-Allow-Headers, Access-Control-Allow-Origin",
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "OPTIONS,POST,GET,PUT"
        },
    };
};


module.exports = {
    buildResponse
};

