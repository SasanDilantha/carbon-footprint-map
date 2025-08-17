import ballerina/http;
import ballerina/log;
import ballerina/time;

import backend.data_types as dt;
import backend.api_client as api;
// import backend.compute_flight_distance as cfd;

service /api on new http:Listener(8080) {
    resource function get flights() returns json|error? {
        // get live flight data
        json|error? flightData = api:getFlightDataFromOpenSky();
        if flightData is error {
            log:printError("Error fetching flight data: ", 'error = flightData);
            return {"error": "Failed to fetch flight data"};
        }
        log:printInfo("Fetched flight data successfully ", 'flightData = flightData);
        // parse flight data
        dt:AllAircraftState[] | error aircraftStates = api:parseOpenSkyData(flightData);
        if aircraftStates is error {
            log:printError("Error parsing OpenSky data: ", 'error = aircraftStates);
            return {"error": "Failed to parse flight data"};
        }
        
        // extract data 
        string icao24 = aircraftStates[0].icao24;
        log:printInfo("Extracted the first ICAO24: ", 'icao24 = icao24);
        int currentTime = time:utcNow()[0];
        log:printInfo("Current UTC time in seconds: ", 'currentTime = currentTime);
        int oneHourAgo = currentTime - 3600;
        log:printInfo("One hour ago in seconds: ", 'oneHourAgo = oneHourAgo);

        // define flight interval
        dt:FlightInterval flightInterval = {
            icao24: icao24,
            begin: oneHourAgo,
            end: currentTime
        };

        return api:getClimatiqCO2Estimate(flightInterval);
    }
}