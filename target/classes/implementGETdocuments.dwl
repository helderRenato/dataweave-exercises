%dw 2.0
import toBase64 from dw::core::Binaries
import * from dw::util::Values

output application/json
---

payload.GetDocumentsResponse.documents.*document
    update "id" with "$(toBase64($))"