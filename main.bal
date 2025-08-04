import ballerina/http;
import service;

service /api on new http:Listener(8080) {

    // GET http://localhost:8080/api/getAllData
    resource function get getAllData() returns json|error {
        return check service:getAllFlightStates();
    }

    // GET /api/allFlights
    resource function get allFlights() returns json|error {
        return check service:getAllFlightStates();
    }

    // GET /api/flights?lamin=...&lomin=...&lamax=...&lomax=...
    resource function get flights(@http:Query string lamin,
                                  @http:Query string lomin,
                                  @http:Query string lamax,
                                  @http:Query string lomax) returns json|error {
        return check service:getFlightStates(lamin, lomin, lamax, lomax);
    }
}
