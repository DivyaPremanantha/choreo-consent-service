import ballerina/http;
import ballerina/io;
import ballerina/random;

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    # A resource for generating consent
    # + return - consent response
    resource function post createAccountConsent(@http:Payload json consentResource) returns string|error {
        // Send a response back to the caller.
        int consentID = check random:createIntInRange(1, 10000);
        io:println(consentResource.Data.Permissions);
        if (consentResource.Data.Permissions == ["ReadAccountsBasic", "ReadTransactionBasic"]) {
            json j1 = {"consentID": consentID};
            json|error j2 = consentResource.mergeJson(j1);
            io:println(j2);
            return j2.ensureType(string);
        }
        return error("Invalid permissions");
    }
}
