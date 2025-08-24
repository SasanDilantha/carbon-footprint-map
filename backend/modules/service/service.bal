import backend.data_types as dt;
import backend.fetching_data as fetching;
import ballerina/log;

public function estimatedCarbonFootprint() returns json|error {
    // Define array for map data
    dt:MapFlightData[] mapData = [];
    // Define array for Climatiq requests
    dt:ClimatiqLeg[] climatiqRequests = [];

    // Fetch flight data
    dt:FlightResponse|error? flightData = fetching:fetchFlightData();
    if flightData is () {
        log:printError("Flight data fetch returned nil");
        return error("Failed to fetch flight data: nil response");
    }
    if flightData is error {
        log:printError("Failed to fetch flight data", 'error = flightData);
        return error("Failed to fetch flight data", cause = flightData);
    }

    log:printInfo("Fetched flight data successfully", flightData = flightData.toString());

    // Map flight data to frontend format and prepare Climatiq requests
    foreach dt:Flight flight in flightData.data {
        // Validate IATA codes and aircraft type
        string? fromIata = flight.departure.iata;
        string? toIata = flight.arrival.iata;

        if fromIata is () || toIata is () {
            log:printWarn("Skipping flight due to missing IATA or aircraft data", 
                flightNumber = flight.flight.iata);
            continue;
        }

        // Create Climatiq request parameter
        dt:ClimatiqLeg climatiqReqParam = {
            'from: fromIata,
            'to: toIata,
        };

        climatiqRequests.push(climatiqReqParam);

        // Map flight data to frontend format
        dt:MapFlightData mapFlightData = {
            flight_number: flight.flight.iata,
            departure: flight.departure,
            arrival: flight.arrival,
            live: flight.live,
            status: flight.flight_status,
            co2e: () // Initialize with a default value
        };
        mapData.push(mapFlightData);
    }

    // Fetch CO2e data
    dt:ClimatiqResponse[]|error co2eData = fetching:fetchCo2eData(climatiqRequests);
    if co2eData is error {
        log:printError("Failed to fetch CO2e data", 'error = co2eData);
        return error("Failed to fetch CO2e data", cause = co2eData);
    }
    log:printInfo("Fetched CO2e data successfully", co2eData = co2eData.toString());

    // Combine CO2e data with mapData in same order
    foreach int i in 0 ..< mapData.length() {
        if i >= co2eData.length() {
            log:printWarn("No CO2e data for flight", flightNumber = mapData[i].flight_number);
            continue;
        }
        dt:MapFlightData flight = mapData[i];
        dt:ClimatiqResponse CO2e = co2eData[i];
        flight.co2e = CO2e;
    }

    // Convert mapData to JSON
    return mapData.toJson();
}