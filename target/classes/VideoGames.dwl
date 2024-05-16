%dw 2.5
output application/json
---

payload.results map ((item) -> 
            {
                "name": item.name,
                "platforms": item.platforms map ((platform) -> 
                                platform.platform.name
                            ),
                "stores": item.stores map ((store) ->
                                store.store.name
                            ),
                "released": item.released,
                "rating": item.rating, 
                "genres": item.genres map ((genre) ->
                                genre.name
                            )
            }
        )
