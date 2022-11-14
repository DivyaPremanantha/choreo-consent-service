import ballerina/http;
import ballerina/io;
import ballerina/random;

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    # A resource for generating consent
    # + return - consent response
    resource function post createAccountConsent(@http:Payload json consentResource) returns json|error {
        // Send a response back to the caller.
        int consentID = check random:createIntInRange(1, 10000);
        io:println(consentResource.Data.Permissions);
        if (consentResource.Data.Permissions == ["ReadAccountsBasic", "ReadTransactionBasic"]) {
            json mapJson = {"consentID": consentID};
            return consentResource.mergeJson(mapJson);
        }
        return error("Invalid permissions");
    }
}
