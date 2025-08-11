import ballerina/io;
import backend.opensky_client as opensky;

public function main() {
    // Fetch flight data from OpenSky
    json|error? flightData = opensky:getFlightDataFromOpenSky();
    
    if (flightData is json) {
        io:println("Flight Data: ", flightData);
    } else {
        io:println("Error fetching flight data: ", flightData.message());
    }
}
