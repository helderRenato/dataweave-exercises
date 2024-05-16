%dw 2.5
output application/json

import repeat from  dw::core::Strings

//Encontrar a palavra expediente no payload
fun getExpedienteIndex (array: Array) = (
    //encontrar a palavra expediente
    getFilteredPayload(array) map ((item, index) -> 
                    item.B == "Expediente"
        ) find true )[0]

//Verificar se o objeto contem algum vazio
fun doesObjactContainsEmptys(object: Object) = 
    object mapObject ((value, key, index) -> 
                if((isEmpty(value)) and ("$key" != "A"))  
                    key: true
                else 
                    key: false
            ) pluck $ 
//filtrar o payload para nao conter {}
fun getFilteredPayload(array: Array) = 
    array map ((item) -> 
                if((doesObjactContainsEmptys(item) contains true) or sizeOf(doesObjactContainsEmptys(item)) != 14) 
                    {}
                else 
                    item
            ) filter ((item) -> !(isEmpty(item)))
//analisar o numero do comercio
fun filterComercio(comercioNumber: String) = 
    if(sizeOf(comercioNumber) == 9)  
        comercioNumber
    else 
        //retornar o numero com a quantidade de zeros que faltam
        repeat("0", 9 - sizeOf(comercioNumber)) ++ comercioNumber 

---

//Buscar apenas as linhas essenciais do excel
getFilteredPayload(payload."Cargos a Comercio")[getExpedienteIndex(payload."Cargos a Comercio") + 1 to -1]
    //Criar o objecto formatado     
    map ((item) -> {
                "Expediente": item.B,
                "Comércio": filterComercio(item.C),
                "Nome Comércio": item.D,
                "Tarjeta": item.E,
                "Importe retrocesso": item.F,
                "Descrição": item.G,
                "Data": item.H,
                "Ref.Operação": item.I,
                "Tipo incidência": item.J,
                "Número": item.K,
                "Importe operação": item.L,
                "Descrição": item.M,
                "Idioma requerido": item.N
            })
