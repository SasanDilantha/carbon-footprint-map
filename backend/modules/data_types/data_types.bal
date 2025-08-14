public type AllAircraftState record {|
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

public type AircraftState record {|
    string icao24;
    string|() callsign;
    string origin_country;
    float|() latitude;
    float|() longitude;
|};

public type Location record {|
    float latitude;
    float longitude;
|};


// map to AllAircraftState to AircraftState
public function mapToAircraftState(AllAircraftState state) returns AircraftState {
    return {
        icao24: state.icao24,
        callsign: state.callsign,
        origin_country: state.origin_country,
        latitude: state.latitude,
        longitude: state.longitude
    };
}

// map to AllAircraftState to Location
public function mapToLocation(AllAircraftState state) returns Location|error {
    if state.latitude is () || state.longitude is () {
        return error("Cannot map to Location: latitude or longitude is missing");
    }

    return {
        latitude: <float>state.latitude,
        longitude: <float>state.longitude
    };
}

// map to array of AllAircraftState to array of AircraftState
public function mapToArrayAircraftState(AllAircraftState[] states) returns AircraftState[] {
    AircraftState[] mappedStates = [];
    foreach var state in states {
        mappedStates.push(mapToAircraftState(state));
    }
    return mappedStates;
}

// map to array of AllAircraftState to array of Location
public function mapToArrayLocation(AllAircraftState[] states) returns Location[]|error {
    Location[] mappedStates = [];
    foreach var state in states {
        Location | error location = mapToLocation(state);
        if location is error {
            return error(location.message());
        }
        mappedStates.push(location);
    }
    return mappedStates;
}