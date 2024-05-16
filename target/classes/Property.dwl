%dw 2.0
output application/json  


fun verifyWhiteList(item: String) = 
    properties.businessUnitsWhitelist contains (item)
---

{
    "firstName": payload.firstName, 
    "lastName": payload.lastName, 
    "allowedBusinessUnits": payload.allowedBusinessUnits filter ((item, index) -> verifyWhiteList(item))
}