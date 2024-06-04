%dw 2.0

output application/csv


fun getLabel(subType: String) = 
    bucket map ((item, index) -> 
                if(item.sourceDimensionValues contains (subType))  
                    item.label
                else 
                    null
            ) 
        filter ((item, index) -> item != null ) 
        reduce ((item, accumulator = {}) -> accumulator ++ { label: "$(item)" })

fun addSubTypeLabel(items: Array) = 
    items reduce ((item, accumulator = []) -> 
                accumulator + (item ++ getLabel(item.subType))
            )

---

addSubTypeLabel(payload) map {
            "type": $."type", 
            "subType": $.subType, 
            "amount": $.amount, 
            "label": $.label

        }



