%dw 2.0
import fromBase64 from dw::core::Binaries

output application/xml

var splittedURL = splitBy(payload, "/") 
var id = "$(fromBase64(splittedURL[sizeOf(splittedURL) - 1]))"

---

GetDocumentsRequest: {
            ids: {
                    id: id
                }
        }
