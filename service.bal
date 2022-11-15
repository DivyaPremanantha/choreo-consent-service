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
        json[]|error requestedPermissions = consentResource.Data.Permissions.ensureType();
        string|error consentExpiryStr = consentResource.Data.ExpirationDateTime.ensureType();

        boolean|error consentExpiryResponse = isConsentExpired(consentExpiryStr);
        boolean|error enforcedPermissionResponse = isPermissionEnforced(requestedPermissions);

        if !(consentExpiryResponse is error) {
            if !(enforcedPermissionResponse is error) {
                json mapJson = {"consentID": consentID};
                return consentResource.mergeJson(mapJson);
            } else {
                return enforcedPermissionResponse;
            }
        } else {
            return consentExpiryResponse;
        }
    }
}

function isPermissionEnforced(json[]|error requestedPermissions) returns boolean|error {
    string[] validPermissions = ["ReadAccountsBasic", "ReadTransactionsBasic"];

    if !((requestedPermissions is error)) {
        string[]|error requestedPermissionsStrArr = requestedPermissions.cloneWithType();
        if !((requestedPermissionsStrArr is error)) {
            if (requestedPermissionsStrArr.length() > validPermissions.length()) {
                if (validPermissions.sort().slice(0, requestedPermissionsStrArr.length() - 1) == requestedPermissionsStrArr.sort()) {
                    return true;
                } else {
                    return error("Invalid permissions requested");                
                }
            } else {
                    return error("Permission reuested are not supported");                
            }
        } else {
            return error("Consent resource contains invalid permission format");
        }
    } else {
        return error("Invalid Consent Resource");
    }
}

function isConsentExpired(string|error consentExpiryStr) returns boolean|error {
    if !((consentExpiryStr is error)) {
        time:Utc consentExpiry = check time:utcFromString(consentExpiryStr);
        io:println(consentExpiry);
        if (consentExpiry > time:utcNow()) {
            return true;
        } else {
            io:println("Consent expired");
            return error("Consent expired");
        }
    } else {
        return error("Invalid Consent Expiry Date Time in Consent Resource");
    }
}
