%dw 2.0
import fromBase64 from dw::core::Binaries

output application/json

var splittedURL = splitBy(payload, "/") 
var id = splittedURL[sizeOf(splittedURL) - 1] 

---
{
    url: "http://documents/" ++ fromBase64(id)
}

