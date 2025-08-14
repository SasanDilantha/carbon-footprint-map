import ballerina/io;
import backend.data_types as dt;
import ballerina/lang.'float as flt;
import backend.opensky_client as opensky;

// convert degrees to radians
public function degreesToRadians(float degrees) returns float {
    return degrees * flt:PI / 180;
}

// calcilate the distance between two locations using Haversine formula (km)
public function calculateDistance(dt:Location location1, dt:Location location2) returns float {
    float earthRadius = 6371.0; // Earth's radius in km

    float dLat = degreesToRadians(location2.latitude - location1.latitude);
    float dLon = degreesToRadians(location2.longitude - location1.longitude);

    float lat1Rad = degreesToRadians(location1.latitude);
    float lat2Rad = degreesToRadians(location2.latitude);

    float a = flt:pow(flt:sin(dLat / 2.0), 2.0) + 
            flt:cos(lat1Rad) * flt:cos(lat2Rad) * flt:pow(flt:sin(dLon / 2.0), 2.0);

    float c = 2.0 * flt:atan2(flt:sqrt(a), flt:sqrt(1.0 - a));
    return earthRadius * c;
}

// Compute distances from a reference point to a list of aircraft states
public function computeFlightDistance(dt:Location ref, dt:AircraftState[] flights) returns map<float> {
    map<float> distances = {};
    foreach var flight in flights {
        if flight.latitude is float && flight.longitude is float {
            dt:Location location = {latitude: <float>flight.latitude, longitude: <float>flight.longitude};
            distances[flight.icao24] = calculateDistance(ref, location);
        }
    }
    return distances;
}

// Display distances from a reference point to aircraft
public function displayDistancesToRef(float refLat, float refLon) returns error? {
    // get data from OpenSky
    json | error fetchAircraftStates = opensky:getOpenSkyDataNonAuth();
    // map json to AllAircraftState array
    if fetchAircraftStates is error {
        return error("Error fetching flight data: " + fetchAircraftStates.message());
    }
    dt:AllAircraftState[] | error states = opensky:parseOpenSkyData(fetchAircraftStates);

    if states is error {
        return error("Error parsing OpenSky data: " + states.message());
    }
    dt:AircraftState[] flights = dt:mapToArrayAircraftState(states);
    dt:Location ref = { latitude: refLat, longitude: refLon };

    map<float> distMap = computeFlightDistance(ref, flights);

    foreach var [icao24, distance] in distMap.entries() {
        io:println("Flight ", icao24, " --> Distance: ", distance, " km");
    }
}