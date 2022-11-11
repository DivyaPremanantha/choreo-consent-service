import ballerina/http;

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    # A resource for generating consent
    # + return - consent response
    function createAccountConsent() returns string|error {
        // Send a response back to the caller.
        return "Account Consent Created";
    }
}
