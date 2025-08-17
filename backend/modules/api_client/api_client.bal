import ballerina/http;
import ballerina/log;
import ballerina/time;
import backend.data_types as dt;

// Make OpenSky Client configuration
configurable string API_OPENSKY_CLIENT_ID = ?;
configurable string API_OPENSKY_CLIENT_SECRET = ?;

// OpenSky OAuth2 token endpoint
final string TOKEN_URL = "https://auth.opensky-network.org/auth/realms/opensky-network/protocol/openid-connect/token";

// OAuth2 Token cache
string accessToken = "";
int tokenExpiry = 0;

// Get OpenSky token using client credentials
public function getOpenSkyToken() returns string|error {
    // Get current time in seconds
    time:Utc currentTime = time:utcNow();
    int now = currentTime[0];

    // Return cached token if still valid
    if accessToken != "" && now < tokenExpiry {
        return accessToken;
    }

    // Create form data for the POST request
    string body = string `grant_type=client_credentials&client_id=${API_OPENSKY_CLIENT_ID}&client_secret=${API_OPENSKY_CLIENT_SECRET}`;

    // Create HTTP client for token endpoint
    http:Client openSkyAuthClient = check new (TOKEN_URL);

    // Create request with headers and payload
    http:Request request = new;
    request.setHeader("Content-Type", "application/x-www-form-urlencoded");
    request.setTextPayload(body);

    // Send POST request
    http:Response response = check openSkyAuthClient->post("", request);

    // Parse response
    json payload = check response.getJsonPayload();
    if payload is map<json> && payload.hasKey("access_token") {
        // Extract access_token as a string
        string accessToken = <string>payload["access_token"];
        if payload["expires_in"] is int {
            tokenExpiry = now + <int>payload["expires_in"] - 30; // Refresh 30s earlier
        } else {
            string expiresInStr = payload["expires_in"].toString();
            int expiresIn = check int:fromString(expiresInStr);
            tokenExpiry = now + expiresIn - 30;
        }
        return accessToken;
    } else {
        return error("Failed to get OpenSky token: access_token not found in response");
    }
}

// Get flight data from OpenSky API
public function getFlightDataFromOpenSky() returns json|error? {
    // Get OAuth2 token
    string token = check getOpenSkyToken();

    // Create HTTP client for OpenSky API
    http:Client openSkyClient = check new ("https://opensky-network.org/api");
    // create request with Authorization header
    // Define headers as a map
    map<string> headers = {
        "Authorization": string `Bearer ${token}`,
        "Content-Type": "application/json"
    };


    // Send GET request with Authorization header
    http:Response|error response = openSkyClient->get("/states/all", headers);

    if response is error {
        log:printError("Failed to fetch OpenSky states", 'error = response);
        return {"error": "Failed to fetch states"};
    }

    json payload = check response.getJsonPayload();
    return payload;
}

public function getOpenSkyDataNonAuth() returns json|error? {
    http:Client openSkyClient = check new ("https://opensky-network.org");
    http:Response response = check openSkyClient->get("/api/states/all");
    return response.getJsonPayload();
}

public function parseOpenSkyData(json openskyData) returns dt:AllAircraftState[]|error {
    // Check if the 'states' field exists and is a json array
    var statesResult = openskyData.states;
    if statesResult is error {
        return error("Invalid or missing 'states' field in JSON data");
    }
    if statesResult !is json[] {
        return error("'states' field is not a JSON array");
    }

    // Define variables
    json[] states = statesResult;
    dt:AllAircraftState[] results = [];

    foreach var state in states {
        if state is json[] {
            dt:AllAircraftState aircraft = {
                icao24: <string>state[0],
                callsign: state[1] is string ? <string?>state[1] : (),
                origin_country: <string>state[2],
                time_position: <int?>state[3],
                last_contact: <int?>state[4],
                longitude: <float?>state[5],
                latitude: <float?>state[6],
                baro_altitude: <float?>state[7],
                on_ground: <boolean>state[8],
                velocity: <float?>state[9],
                heading: <float?>state[10],
                vertical_rate: <float?>state[11],
                sensors: state[12],
                geo_altitude: <float?>state[13],
                squawk: state[14] is string ? <string?>state[14] : (),
                spi: <boolean>state[15],
                position_source: <int>state[16]
            };
            results.push(aircraft);
        }
    }
    return results;
}
