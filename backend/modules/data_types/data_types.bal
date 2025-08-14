// Record type definition for a parsed aircraft state
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