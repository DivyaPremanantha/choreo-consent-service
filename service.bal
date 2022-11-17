import ballerina/http;
import ballerina/time;
import ballerina/io;

# A service representing a network-accessible API
# bound to port `9090`.
json|error consentResponse = {};
service / on new http:Listener(9090) {
    # A resource for generating consent
    # + return - consent response
    resource function post accountConsent(@http:Payload json consentResource) returns json|error {
        io:println("Account Consent Create Service Initiated");
        string consentID = "343eea20-3f9d-4c12-8777-fe446c554210";
        json[]|error requestedPermissions = consentResource.Data.Permissions.ensureType();
        string|error consentExpiryStr = consentResource.Data.ExpirationDateTime.ensureType();

        boolean|error consentExpiryResponse = isConsentExpired(consentExpiryStr);
        boolean|error enforcedPermissionResponse = isPermissionEnforced(requestedPermissions);

        if !(consentExpiryResponse is error) {
            if !(enforcedPermissionResponse is error) {
                json mapJson = {"Data": {"ConsentId": consentID, "Status": "AwaitingAuthorisation", "StatusUpdateDateTime": time:utcToString(time:utcNow()), "CreationDateTime": time:utcToString(time:utcNow())}};
                consentResponse = consentResource.mergeJson(mapJson);
                return consentResponse;
            } else {
                return enforcedPermissionResponse;
            }
        } else {
            return consentExpiryResponse;
        }
    }

     resource function get accountConsent() returns json|error {
         return consentResponse;
     }
}

function isPermissionEnforced(json[]|error requestedPermissions) returns boolean|error {

    if !((requestedPermissions is error)) {
        string[]|error requestedPermissionsStrArr = requestedPermissions.cloneWithType();
        if !((requestedPermissionsStrArr is error)) {
            if (requestedPermissionsStrArr.every(validateAllowedPermissions)) {
                return true;
            } else {
                return error("{'error': 'Permission Validation Failed', 'error_description': 'Permission requested are not supported'}");
            }
        } else {
            return error("{'error': 'Invalid Permission Format', 'error_description': 'Permissions passed in the consent resource is not a valid json'}");
        }
    } else {
        return error("{'error': 'Invalid Consent Resource', 'error_description': 'Consent resource passed is not a valid json'}");
    }
}

function validateAllowedPermissions(string requestedPermission) returns boolean {
    string[] validPermissions = ["ReadAccountsBasic", "ReadTransactionsBasic"];
    foreach var validPermission in validPermissions {
        if (requestedPermission == validPermission) {
            return true;
        }
    }
    return false;
}

function isConsentExpired(string|error consentExpiryStr) returns boolean|error {
    if !((consentExpiryStr is error)) {
        time:Utc consentExpiry = check time:utcFromString(consentExpiryStr);
        io:println(consentExpiry);
        if (consentExpiry > time:utcNow()) {
            return true;
        } else {
            io:println("Consent expired");
            return error("{'error': 'Consent expired', 'error_description': 'ExpirationDateTime specified in the consent resource has been expired'}");
        }
    } else {
        return error("{'error': 'Invalid Consent Expiry', 'error_description': 'Invalid Consent Expiry Date Time specified in the Consent Resource'}");
    }
}