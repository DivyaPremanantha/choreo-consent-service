import ballerina/http;
import ballerina/random;

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    # A resource for generating consent
    # + return - consent response
    resource function get createAccountConsent() returns string|error {
        // Send a response back to the caller.
        int consentID = check random:createIntInRange(1, 10000);
        return consentID.toString();
    }
}
