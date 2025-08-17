import ballerina/io;
// import backend.data_types as dt;
import backend.api_client as api;
// import backend.compute_flight_distance as cfd;


public function main() returns error? {
    // test auth opensky api
    json|error? flightData = api:getFlightDataFromOpenSky();

    if flightData is error{
        io:println("Error fetching flight data: ", flightData.message());
    }
    io:print("Fetched Flight Data (Auth): ", flightData);

    // // get OpenSky flight data without authentication
    // json|error? flightDataNonAuth = opensky:getOpenSkyDataNonAuth();
    // json data = [];

    // // check if flight data is emty
    // if flightDataNonAuth is (){
    //     io:println("No flight data received (nil response)");
    //     return;
    // }else if flightDataNonAuth is error { // check if flight data have errors
    //     io:println("Error fetching flight data: ", flightDataNonAuth.message());
    //     return;
    // }else { // covert flight data to only json type
    //     data = flightDataNonAuth;   
    // }

    // // parse the OpenSky data
    // dt:AllAircraftState[] | error aircraftStates = opensky:parseOpenSkyData(data);
    // if aircraftStates is error {
    //     io:println("Error parsing OpenSky data: ", aircraftStates.message());
    //     return;
    // }
    // io:println("Parsed Aircraft States: ", aircraftStates);

    // check cfd:displayDistancesToRef(51.509865, -0.118092);

}
