%dw 2.0
import toBase64 from dw::core::Binaries

output application/octet-stream
---
toBase64(payload as Binary)

