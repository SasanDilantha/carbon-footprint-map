import ballerina/http;
import ballerina/log;
// import ballerina/time;

import backend.data_types as dt;

// config aviationstack access key
configurable string API_AVIATIONSTACK_ACCESS_KEY = ?;
// config climatiq API key
configurable string API_CLIMATIQ_KEY = ?;


// get flight data from aviationstack API
public function fetchFlightData() returns dt:FlightResponse|error? {
    // Create HTTP client for AviationStack API
    http:Client aviationStackClient = check new ("http://api.aviationstack.com/v1");

    // Define endpoint
    string endpoint = string `/flights?access_key=${API_AVIATIONSTACK_ACCESS_KEY}&flight_status=active`;
    http:Request request = new;
    request.setHeader("Content-Type", "application/x-www-form-urlencoded");
    request.setTextPayload(endpoint);

    // Send GET request
    http:Response | error response = check aviationStackClient->get(endpoint);
    
    if response is error {
        log:printError("Failed to fetch flight data", 'error = response);
        return error("Failed to fetch flight data");
    }

    json payload = check response.getJsonPayload();
    return payload.fromJsonWithType(dt:FlightResponse);
}

// fetch list of co2e from climatiq
public function fetchCo2eData(dt:ClimatiqLeg[] climatiqRequests) returns dt:ClimatiqResponse[]|error {
    if (climatiqRequests.length() == 0) {
        log:printError("No valid requests to send", 'error = error("No valid requests to send"));
        return error("No valid requests to send");
    }

    // define climatiq client
    http:Client climatiqClient = check new ("https://api.climatiq.io");
    // Define headers
    map<string> headers = {
        "Authorization": string `Bearer ${API_CLIMATIQ_KEY}`,
        "Content-Type": "application/json"
    };

    // Create request payload
    json co2Request = {
        "legs": [
            climatiqRequests.toJson()
        ]
    };

    // Send POST request
    http:Response | error response = check climatiqClient->post("/travel/flights", co2Request, headers);
    if response is error {
        log:printError("Failed to fetch CO2e data", 'error = response);
        return error("Failed to fetch CO2e data");
    }
    log:printInfo("Fetched CO2e data successfully", 'statusCode = response.statusCode);
    json payload = check response.getJsonPayload();
    return payload.fromJsonWithType(ClimatiqResponse);
}
