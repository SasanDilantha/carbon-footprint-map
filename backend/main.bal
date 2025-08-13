import ballerina/io;
import backend.opensky_client as opensky;

public function main() {
    // get OpenSky flight data without authentication
    json|error? flightDataNonAuth = opensky:getOpenSkyDataNonAuth();
    json data = [];

    // check if flight data is emty
    if flightDataNonAuth is (){
        io:println("No flight data received (nil response)");
        return;
    }else if flightDataNonAuth is error { // check if flight data have errors
        io:println("Error fetching flight data: ", flightDataNonAuth.message());
        return;
    }else { // covert flight data to only json type
        data = flightDataNonAuth;   
    }

    // parse the OpenSky data
    opensky:AircraftState[] | error aircraftStates = opensky:parseOpenSkyData(data);
    if aircraftStates is error {
        io:println("Error parsing OpenSky data: ", aircraftStates.message());
        return;
    }
    io:println("Parsed Aircraft States: ", aircraftStates);

}
