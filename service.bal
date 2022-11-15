import ballerina/http;
import ballerina/time;

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    # A resource for generating consent
    # + return - consent response
    resource function post createAccountConsent(@http:Payload json consentResource) returns json|error {
        string consentID = "343eea20-3f9d-4c12-8777-fe446c554210";
        string[]|error requestedPermissions = consentResource.Data.Permissions.ensureType();
        string|error consentExpiryStr = consentResource.Data.ExpirationDateTime.ensureType();

        if !((requestedPermissions is error) || (consentExpiryStr is error)) {
            if !((isConsentExpired(consentExpiryStr) is error) || (isValidPermissions(requestedPermissions) is error)) {
                json mapJson = {"consentID": consentID};
                return consentResource.mergeJson(mapJson);
            } else {
                return error("Consent validation failed");
            }
        } else {
            return error("Invalid consent resource");
        }
    }
}
function isValidPermissions(string[] requestedPermissions) returns boolean|error {
    string[] validPermissions = ["ReadAccountsBasic", "ReadTransactionBasic"];
    if (validPermissions.sort() == requestedPermissions.sort()) {
        return true;
    } else {
        return error("Invalid permissions");
    }
}

function isConsentExpired(string consentExpiryStr) returns boolean|error {
    time:Utc consentExpiry = check time:utcFromString(consentExpiryStr);
    if (consentExpiry > time:utcNow()) {
        return true;
    } else {
        return error("Consent expired");
    }
}