%dw 2.0
output application/csv header=true
---
payload map {
            "Expediente": $."Expediente", 
            "Comércio": $."Comércio",
            "Nome Comércio": $."Nome Comércio",
            "Tarjeta": $."Tarjeta",
            "Importe retrocesso": $."Importe retrocesso",
            "Descrição": $."Descrição",
            "Data": $."Data",
            "Ref.Operação": $."Ref.Operação",
            "Tipo incidência": $."Tipo incidência",
            "Número": $."Número",
            "Importe operação": $."Importe operação",
            "Descrição": $."Descrição",
            "Idioma requerido": $."Idioma requerido"
        }   