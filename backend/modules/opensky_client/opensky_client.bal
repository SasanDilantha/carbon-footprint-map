import ballerina/http;

// Make OpenSky Client more configurable
configurable string OPENSKY_CLIENT_ID = ?;
configurable string OPENSKY_CLIENT_SECRET = ?;

// get opensky token using client credentials
public function getOpenSkyToken() returns string|error {
    // create client
    http:Client openSkyeAuthClient = check new ("https://auth.opensky-network.org");

    // initialize the form data
    map<string|string[]> formData = {
        "grant_type": "client_credentials",
        "client_id": OPENSKY_CLIENT_ID,
        "client_secret": OPENSKY_CLIENT_SECRET
    };

    // create request obj
    http:Request request = new;
    request.setHeader("Content-Type", "application/x-www-form-urlencoded");
    request.setPayload(formData);

    // get response
    http:Response response = check openSkyeAuthClient->post("/auth/realms/opensky-network/protocol/openid-connect/token", request);

    // convert to json
    json responseBody = check response.getJsonPayload();
    if responseBody is map<json> && responseBody.hasKey("access_token") {
        string token = <string>responseBody["access_token"];
        return token;
    } else {
        return error("Failed to get OpenSky token: access_token not found in response");
    }
}

public function getFlightDataFromOpenSky() returns json | error?{
    // create the OpenSky client for get flight data
    http:Client openSkyClient = check new ("https://opensky-network.org");

    // create authorization header
    string token = check getOpenSkyToken();
    map<string> headers = { "Authorization": "Bearer " + token };

    // create response object
    http:Response response = check openSkyClient->get("/api/states/all", headers = headers);

    return response.getJsonPayload();
}