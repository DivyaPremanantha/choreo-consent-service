import ballerina/http;

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    # A resource for generating consent
    # + return - consent response
    resource function post accountAccessConsent() returns string|error {
        // Send a response back to the caller.
        return "Account Consent POST Service Invoked";
    }

    # A resource to return consent
    # + return - consent response
    resource function get accountAccessConsent() returns string|error {
        // Send a response back to the caller.
        return "Account Consent GET Service Invoked";
    }

        # A resource to return consent
    # + return - consent response
    resource function get accounts() returns string|error {
        // Send a response back to the caller.
        return "Account Service Invoked";
    }
}
