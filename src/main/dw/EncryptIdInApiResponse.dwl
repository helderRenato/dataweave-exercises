%dw 2.0
import toBase64 from dw::core::Binaries

output application/json

var document = payload.GetDocumentsResponse.documents.document
---

{
    id: toBase64(document.id), 
    fileName: document.fileName, 
    sizeInBytes: document.sizeInBytes as Number, 
    downloadUrl: document.downloadUrl
}