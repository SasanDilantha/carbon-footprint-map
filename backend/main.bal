import ballerina/io;
import backend.opensky_client as opensky;

public function main() {
    // Fetch flight data from OpenSky
    // json|error? flightDataWithAuth = opensky:getFlightDataFromOpenSky();
    json|error? flightDataNonAuth = opensky:getOpenSkyDataNonAuth();
    
    // if (flightDataWithAuth is json) {
    //     io:println("Flight Data: ", flightDataWithAuth);
    // } else {
    //     io:println("Error fetching flight data: ", flightDataWithAuth.message());
    // }

    if (flightDataNonAuth is json) {
        io:println("Flight Data: ", flightDataNonAuth);
    } else {
        io:println("Error fetching flight data: ", flightDataNonAuth.message());
    }
}
