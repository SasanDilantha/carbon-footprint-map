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

// Aircraft flight interval
public type FlightInterval record {|
    string icao24;
    int begin;
    int end;
|};

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

// ========================================== NEW MAP FUNCTIONS TYPE ============================

// Root response type
public type FlightResponse record {|
    Pagination pagination;
    Flight[] data;
|};

// Pagination
public type Pagination record {|
    int limitValue;
    int offset;
    int count;
    int total;
|};

// Flight entry
public type Flight record {|
    string flight_date;
    string flight_status;
    Departure departure;
    Arrival arrival;
    Airline airline;
    FlightInfo flight;
    Aircraft aircraft;
    Live? live;
|};

// Departure airport details
public type Departure record {|
    string? airport;
    string? timezone;
    string? iata;
    string? icao;
    string? terminal;
    string? gate;
    int? delay;
    string scheduled;
    string estimated;
    string? actual;
    string? estimated_runway;
    string? actual_runway;
|};

// Arrival airport details (includes baggage)
public type Arrival record {|
    string? airport;
    string? timezone;
    string? iata;
    string? icao;
    string? terminal;
    string? gate;
    string? baggage;
    int? delay;
    string scheduled;
    string estimated;
    string? actual;
    string? estimated_runway;
    string? actual_runway;
|};

// Airline details
public type Airline record {|
    string name;
    string iata;
    string icao;
|};

// Flight info
public type FlightInfo record {|
    string number;
    string iata;
    string icao;
    anydata codeshared; // Can be null or object
|};

// Aircraft details (relevant for CO2 estimation, e.g., to classify type as jet/turboprop)
public type Aircraft record {|
    string registration;
    string iata; // e.g., "A321" for Airbus A321, used to lookup seats or type
    string icao;
|};

// Live flight data (useful for real-time map positioning if flight is active)
public type Live record {|
    string updated;
    float latitude;
    float longitude;
    float altitude;
    float direction;
    float speed_horizontal;
    float speed_vertical;
    boolean is_ground;
|};

// Helper type for carbon data
public type CarbonFlightData record {|
    string fromIata;
    string toIata;
    string aircraftType;
|};

// Type for output to frontend
public type MapFlightData record {|
    string flight_number;
    string status;
    Departure departure;
    Arrival arrival;
    Live? live; // if live
    ClimatiqResponse? co2e; // kg
|};


public type ClimatiqLeg record {|
    string 'from;
    string 'to;
|};

// Type for Climatiq response
public type ClimatiqResponse record {|
    float co2e;
    string co2e_unit;
    string co2e_calculation_method;
|};
