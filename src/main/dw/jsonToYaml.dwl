%dw 2.0
output application/yaml

fun jsonToYaml(object: Object) = 
    properties: 
            object mapObject ((value, key, index) -> 
                        if(typeOf(value) == Object)  
                            "$(key)?": 
                                    jsonToYaml(value)
                        else 
                            "$(key)?": value
                    )
---

jsonToYaml(payload)