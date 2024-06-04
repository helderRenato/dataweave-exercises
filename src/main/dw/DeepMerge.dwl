%dw 2.0
// Transformar o payload em array para ser mais facil contar os duplicados
var payloadArray = payload pluck ((value, key, index) -> 
                "$key": value
            )
var newValue = {
        "message": "Hello You",
        "newKey": "new",
        "b": [ "q", "b" ],
        "c": {
                "r": [ "5" ],
                "y": {
                        "b": 5
                    },
                "a": 9
            },
        "d": [
                {
                    "ee": {
                            "aa": 5
                        }
                }
            ]
    }
// This variable has the function to keep all the keys that are suppose to be in the final merge
var totalLengtOfMerge = keysOf(newValue ++ payload distinctBy $$)

fun nTimesAKeyAppearsAtObject(key: String, object: Array<Object>, i: Number, duplicate: Number) =
    if (i == sizeOf(object))
        duplicate
    else if (object[i]."$key" != null)
        nTimesAKeyAppearsAtObject(key, object, (i + 1), (duplicate + 1))
    else
        nTimesAKeyAppearsAtObject(key, object, (i + 1), (duplicate))

// Merging an object contains walking for each element of the object and do a merge
fun getMergedObject(new: Object, old: Object, i: Number, mergedObject: Object, keys: Array, keysToIgnore: Array) =
    if (i == sizeOf(keys))
        mergedObject
    else
        getMergedObject(new, old, (i + 1), mergedObject ++ mergeObject(new, old, keysToIgnore), keys, keysToIgnore ++ [
                        keys[i]
                    ])

fun mergeObject(new: Object, old: Object, keysToIgnore: Array) =
    new mapObject ((value, key) -> old mapObject ((value1, key1) -> if (!(keysToIgnore contains "$key1")) // se nao for as keys ja feitas pode passar
        // Caso a chave for igual fazer merge
                                if (key == key1)
                                    if ((typeOf(value) == Array or typeOf(value) == Object) and (typeOf(value1) == String or typeOf(value1) == Number))

                                        "$key": value

                                    else if (typeOf(value) == Object)
            // Caso for um Objecto fazer merge

                                        "$key": mergeObject(value, value1 ++ value, []) distinctBy $$

          else // Caso os dois forem strings
                                    if (((typeOf(value) == String) and (typeOf(value1) == String)) or ((typeOf(value) == String) and (typeOf(value1) == Number)) or ((typeOf(value) == Number) and (typeOf(value1) == String)) or ((typeOf(value) == Number) and (typeOf(value1) == Number)))

                                        "$key": value
                                                                                                                                                                                                                
          else
                                        {}
        else // Caso a key existir no new value e nao no payload
                                if (!(keysOf(new) contains "$key1" as Key))

                                    "$key1": value1

                                else if (!(keysOf(old) contains "$key" as Key))

                                    "$key": value
                                                                                                                                                                                                
        else
                                    {}
                            else
                                {}))

// END FUNCTIONS TO MERGE AN OBJECT
// Functions responsible to merge an array
// Function to retrieve the index of a certain value in an array
// Given the value and the array to look for
fun getIndex(value: Any, array: Array) =
    array map ((item, index) -> if ((item is Object) and (value is Object))
                    if (keysOf(item) == keysOf(value))
                        index
                    else
                        []
                else if (item == value)
                    index
                else
                    "") filter ((item) -> !isEmpty(item))

fun getMergedArray(new: Array, old: Array, i: Number, mergedArray: Array, desideredLengthForTheArray: Array) =
    if (i == sizeOf(desideredLengthForTheArray))
        mergedArray distinctBy $
    else
        getMergedArray(new, old, (i + 1), mergedArray ++ flatten(mergeArray(new, old, desideredLengthForTheArray)), desideredLengthForTheArray)

fun mergeArray(new: Array, old: Array, desideredLengthForTheArray: Array) =
    if (!(new map $ is Number contains (false)) or !(new map $ is String contains (false)))
        ((old ++ new)[-1 to 0] distinctBy $)[-1 to 0]
    else
        desideredLengthForTheArray map ((item) -> if (!(isEmpty(getIndex(item, new))) and !(isEmpty(getIndex(item, old)))) // If the both new and old array have the same elements we can do a merge
                        if(item is Object)
                            getMergedObject(new[getIndex(item, new)[0]], old[getIndex(item, old)[0]], 0, {}, keysOf(new[getIndex(item, new)[0]]), []) distinctBy $$
                        else if(item is Array) 
                            mergeArray(new[item], old[item], (old[getIndex(item, old)[0]] ++ new[getIndex(item, new)[0]] ) distinctBy $)
                        else 
                            item ++ old[item]
            
                    else if ((isEmpty(getIndex(item, new))))
                        getIndex(item, old) map ((item) -> if (old[item] is Object)
                                        old[item]
                                    else if (old[item] is Array)
                                        flatten(mergeArray(new, old[item], old[item]))
                                    else
                                old[item]) distinctBy $

                    else if ((isEmpty(getIndex(item, old))))
                        getIndex(item, new) map ((item) -> if (new[item] is Object)
                                        new[item]
                                    else if (new[item] is Array)
                                        flatten(mergeArray(old, new[item], new[item]))
                                    else
                                new[item]) distinctBy $
                    else
                        [])

// END FUNCTIONS TO MERGE AN ARRAY
// Functions responsible to make the deep merge by walking for the payload and the new value , seeing cases like is it an Array or is an object and run the merge for each element to be merged
fun deepMerge(old: Object, new: Object) =
    totalLengtOfMerge map ((item) -> if ((keysOf(new) contains "$item" as Key) and (keysOf(old) contains "$item" as Key)) // In the case that the key exists in the both objects we can continue               to merge
      // If the value is a String or a Number we dont need to merge
                    if ((new."$item" is String) or (new."$item" is Number))

                        "$item": new."$item"

                    else if (new."$item" is Object)

                        "$item": getMergedObject(new."$item", old."$item", 0, {}, keysOf(new."$item"), []) distinctBy $$

                    else if (new."$item" is Array)

                        "$item": getMergedArray(new."$item", old."$item", 0, [], (old."$item" ++ new."$item") distinctBy $)
                                                                                                                
      else
                        {}
    else // In the case of a key that doesnt exist in both object we only have                to add them
                if ((keysOf(new) contains "$item" as Key))

                    "$item": new."$item"

                else if ((keysOf(old) contains "$item" as Key))

                    "$item": old."$item"
                                                                                                
    else
                    {}) reduce ((item, acc) -> acc ++ item)
output application/json  
---
deepMerge(payload, newValue)