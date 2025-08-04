module service;

import ballerina/http;
import ballerina/env;
import ballerina/log;

// Fetch OAuth2 access token
public isolated function fetchAccessToken() returns string|error {
    string clientId = check env:get("OPENSKY_CLIENT_ID");
    string clientSecret = check env:get("OPENSKY_CLIENT_SECRET");

    http:Client authClient = check new ("https://auth.opensky-network.org", {
        headers: {
            "Content-Type": "application/x-www-form-urlencoded"
        }
    });

    string payload = string `grant_type=client_credentials&client_id=${clientId}&client_secret=${clientSecret}`;

    http:Response resp = check authClient->post(
        "/auth/realms/opensky-network/protocol/openid-connect/token",
        body = payload
    );

    json responseJson = check resp.getJsonPayload();
    return <string>responseJson.access_token;
}

// Get ALL real-time flight states worldwide
public isolated function getAllFlightStates() returns json|error {
    string token = check fetchAccessToken();

    http:Client apiClient = check new ("https://opensky-network.org/api", {
        auth: {
            scheme: http:AuthScheme.BEARER_TOKEN,
            accessToken: token
        }
    });

    http:Response resp = check apiClient->get("/states/all");
    json payload = check resp.getJsonPayload();
    return payload;
}

// Get filtered flight states by bounding box
public isolated function getFlightStates(string lamin, string lomin, string lamax, string lomax) returns json|error {
    string token = check fetchAccessToken();

    http:Client apiClient = check new ("https://opensky-network.org/api", {
        auth: {
            scheme: http:AuthScheme.BEARER_TOKEN,
            accessToken: token
        }
    });

    string query = string `?lamin=${lamin}&lomin=${lomin}&lamax=${lamax}&lomax=${lomax}`;
    http:Response resp = check apiClient->get("/states/all" + query);
    json payload = check resp.getJsonPayload();
    return payload;
}
