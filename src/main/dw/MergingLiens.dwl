%dw 2.5
output application/json
---

clients: 

    //Remover o array de arrays retornado pelo pluck do groupBy por codigo
        flatten(
    //Remover o ids do objeto
            payload.clients map ((item) -> 
                        item - "ids"
                    ) 
    //Agrupar por codigo
                groupBy ((item) -> item.code)
    //Remover as tags do codigo do objeto
                pluck ((value) -> value)
        )
        //Fazer Merge dos objetos com flatten code igual
            map ((item) -> 
                //Remover "liens" do objeto
                    (item - "liens") ++ 
                            //Adicionar "liens" formatado ou seja com todos os correspondentes
                            {
                                liens: payload.clients filter ((item2) -> item2.code == item.code) flatMap $.liens
                            }
                ) distinctBy $."type"