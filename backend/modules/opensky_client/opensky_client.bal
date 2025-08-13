import ballerina/http;

// Record type definition for a parsed aircraft state
public type AircraftState record {|
    string icao24;
    string|() callsign;
    string origin_country;
    int|() time_position;
    int|() last_contact;
    float|() longitude;
    float|() latitude;
    float|() baro_altitude;
    boolean on_ground;
    float|() velocity;
    float|() heading;
    float|() vertical_rate;
    anydata sensors;
    float|() geo_altitude;
    string|() squawk;
    boolean spi;
    int position_source;
|};

// // Make OpenSky Client more configurable
// configurable string OPENSKY_CLIENT_ID = ?;
// configurable string OPENSKY_CLIENT_SECRET = ?;

// // get opensky token using client credentials
// public function getOpenSkyToken() returns string|error {
//     // create client
//     http:Client openSkyeAuthClient = check new ("https://auth.opensky-network.org");

//     // initialize the form data
//     map<string|string[]> formData = {
//         "grant_type": "client_credentials",
//         "client_id": OPENSKY_CLIENT_ID,
//         "client_secret": OPENSKY_CLIENT_SECRET
//     };

//     // create request obj
//     http:Request request = new;
//     request.setHeader("Content-Type", "application/x-www-form-urlencoded");
//     request.setPayload(formData);

//     // get response
//     http:Response response = check openSkyeAuthClient->post("/auth/realms/opensky-network/protocol/openid-connect/token", request);

//     // convert to json
//     json responseBody = check response.getJsonPayload();
//     if responseBody is map<json> && responseBody.hasKey("access_token") {
//         string token = <string>responseBody["access_token"];
//         return token;
//     } else {
//         return error("Failed to get OpenSky token: access_token not found in response");
//     }
// }

// public function getFlightDataFromOpenSky() returns json | error?{
//     // create the OpenSky client for get flight data
//     http:Client openSkyClient = check new ("https://opensky-network.org");

//     // create authorization header
//     string token = check getOpenSkyToken();
//     map<string> headers = { "Authorization": "Bearer " + token };

//     // create response object
//     http:Response response = check openSkyClient->get("/api/states/all", headers = headers);

//     return response.getJsonPayload();
// }

public function getOpenSkyDataNonAuth() returns json|error? {
    http:Client openSkyClient = check new ("https://opensky-network.org");
    http:Response response = check openSkyClient->get("/api/states/all");
    return response.getJsonPayload();
}

public function parseOpenSkyData(json openskyData) returns AircraftState[]|error {
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
    AircraftState[] results = [];

    foreach var state in states {
        if state is json[] {
            AircraftState aircraft = {
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
