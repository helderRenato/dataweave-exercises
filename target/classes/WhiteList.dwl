%dw 2.0
output application/json  

var businessUnitsWhitelist = "lu, be"

fun verifyWhiteList(item: String) = 
    businessUnitsWhitelist contains (item)
---

{
    "firstName": payload.firstName, 
    "lastName": payload.lastName, 
    "allowedBusinessUnits": payload.allowedBusinessUnits filter ((item, index) -> verifyWhiteList(item))
}