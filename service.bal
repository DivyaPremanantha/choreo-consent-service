import ballerina/http;
import ballerina/time;
import ballerina/io;

# A service representing a network-accessible API
# bound to port `9090`.
json|error consentResponse = {};
service / on new http:Listener(9090) {
    # A resource to generate consent.
    # 
    # + consentResource - The consent resource.
    # + return - Consent response.
    resource function post accountConsent(@http:Payload json consentResource) returns json|error {
        io:println("Account Consent Create Service Initiated");
        string consentID = "343eea20-3f9d-4c12-8777-fe446c554210";
        json[]|error requestedPermissions = consentResource.Data.Permissions.ensureType();
        string|error consentExpiryStr = consentResource.Data.ExpirationDateTime.ensureType();

        boolean|error consentExpiryResponse = isConsentExpired(consentExpiryStr);

        if !(consentExpiryResponse is error) {
            boolean|error enforcedPermissionResponse = isPermissionEnforced(requestedPermissions);
            if !(enforcedPermissionResponse is error) {
                io:println("Constructing Account Consent Response");
                json mapJson = {"Data": {"ConsentId": consentID, "Status": "AwaitingAuthorisation", "StatusUpdateDateTime": time:utcToString(time:utcNow()), "CreationDateTime": time:utcToString(time:utcNow())}};
                consentResponse = consentResource.mergeJson(mapJson);
                io:println("Account Consent Response Constructed");
                return consentResponse;
            } else {
                return enforcedPermissionResponse;
            }
        } else {
            return consentExpiryResponse;
        }
    }

    # A resource to return consent.
    # 
    # + return - Consent response.
     resource function get accountConsent() returns json|error {
         return consentResponse;
     }
}

# A function to enforce permissions.
# 
# + requestedPermissions - The requested permission in the consent resource.
# + return - Permission enforcement response.
function isPermissionEnforced(json[]|error requestedPermissions) returns boolean|error {
    io:println("Account Consent Permission Validation Initiated");
    if !((requestedPermissions is error)) {
        string[]|error requestedPermissionsStrArr = requestedPermissions.cloneWithType();
        if !((requestedPermissionsStrArr is error)) {
            if (requestedPermissionsStrArr.every(validateAllowedPermissions)) {
                io:println("Account Consent Permission Validation Successfull");
                return true;
            } else {
                io:println("Account Consent Permission Validation Failed, Permissions not supported");
                return error("{'error_message': 'Permission Validation Failed', 'error_description': 'Permission requested are not supported'}");
            }
        } else {
            io:println("Account Consent Permission Validation Failed, Invalid Permission Format");
            return error("{'error_message': 'Invalid Permission Format', 'error_description': 'Permissions passed in the consent resource is not a valid json'}");
        }
    } else {
        io:println("Account Consent Permission Validation Failed, Invalid Consent Resource");
        return error("{'error_message': 'Invalid Consent Resource', 'error_description': 'Consent resource passed is not a valid json'}");
    }
}

# A function to validate permissions.
# 
# + requestedPermission - The requested permission in the consent resource.
# + return - Permission validation response.
function validateAllowedPermissions(string requestedPermission) returns boolean {
    string[] validPermissions = ["ReadAccountsBasic", "ReadTransactionsBasic"];
    foreach var validPermission in validPermissions {
        if (requestedPermission == validPermission) {
            return true;
        }
    }
    return false;
}

# A function to validate consent.
# 
# + consentExpiryStr - The string value of the consent expiration date time.
# + return - Consent validation response.
function isConsentExpired(string|error consentExpiryStr) returns boolean|error {
    io:println("Account Consent Expiry Validation Initiated");
    if !((consentExpiryStr is error)) {
        time:Utc consentExpiry = check time:utcFromString(consentExpiryStr);
        if (consentExpiry > time:utcNow()) {
            io:println("Account Consent Expiry Validation Successfull");
            return true;
        } else {
            io:println("Account Consent Expiry Validation Failed, Consent expired");
            return error("{'error_message': 'Consent expired', 'error_description': 'ExpirationDateTime specified in the consent resource has been expired'}");
        }
    } else {
        io:println("Account Consent Expiry Validation Failed, Invalid Consent Expiry Date Time");
        return error("{'error_message': 'Invalid Consent Expiry Date Time', 'error_description': 'Invalid Consent Expiry Date Time specified in the Consent Resource'}");
    }
}