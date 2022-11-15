import ballerina/http;
import ballerina/time;
import ballerina/io;

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    # A resource for generating consent
    # + return - consent response
    resource function post createAccountConsent(@http:Payload json consentResource) returns json|error {
        io:println("Service Reached");
        string consentID = "343eea20-3f9d-4c12-8777-fe446c554210";
        string[]|error requestedPermissions = consentResource.Data.Permissions.ensureType();
        string|error consentExpiryStr = consentResource.Data.ExpirationDateTime.ensureType();

        if !((requestedPermissions is error) || (consentExpiryStr is error)) {
            io:println("Permission validation successfull");
            if !((isConsentExpired(consentExpiryStr) is error) || (isValidPermissions(requestedPermissions) is error)) {
                io:println("Consent validation successfull");
                json mapJson = {"consentID": consentID};
                return consentResource.mergeJson(mapJson);
            }
        } else {
            io:println(requestedPermissions);
            io:println(consentExpiryStr);
            return error("Invalid Consent Resource");
        }
    }
}

function isValidPermissions(string[] requestedPermissions) returns boolean|error {
    string[] validPermissions = ["ReadAccountsBasic", "ReadTransactionsBasic"];
    io:println(requestedPermissions.sort());
    if (validPermissions.sort() == requestedPermissions.sort()) {
        return true;
    } else {
        return error("Invalid permissions");
    }
}

function isConsentExpired(string consentExpiryStr) returns boolean|error {
    time:Utc consentExpiry = check time:utcFromString(consentExpiryStr);
    io:println(consentExpiry);
    if (consentExpiry > time:utcNow()) {
        return true;
    } else {
        return error("Consent expired");
    }
}
