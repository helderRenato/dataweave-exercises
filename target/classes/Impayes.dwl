%dw 2.5
output application/json
import * from dw::core::Strings

//Funçao para filtrar o payload em um array com cada caso
fun getFilterdPayload(plainText: String) = 
    //Fazer um replace dos \n \r contidos no plain text
    plainText replace "\n" with (" ") replace "\r" with ("") 
        //Fazer um splitBy pela palavara-chave "MARKET PAY" que e constante em todos os casos
        splitBy "MARKET PAY" map ((text) -> 
                //Como nao precisamos da string vamos fazer um replace por ""
                text replace "*=========================================================================*" with ("")
        
            ) 
        //Tirar todos os elementos em branco do array
        filter ((array) -> trim(array) != "")

fun getSubstring(before: String, after: String, text: String) =
    trim(text substringBefore before substringAfter after)

//function to filter the string if the payload is corrupted
fun analyzeSubString(before: String, after: String, text: String, length: Number) = 
    if(getSubstring(before, after, text)[0 to length] != null)
        trim(getSubstring(before, after, text)[0 to length])
    else
        ""
//Funçao para buscar o montante e saber se e credito ou debito ["CR", 20,00]
fun getMontantArray(item: String) = 
    (getSubstring("Date", "Mont", item) splitBy " " )
        filter ((item) -> item != "" and item != "EUR") 

//Funcao para filtrar o montante adicionar menos se for credito ou normal se debito
fun filterMontant(item: String) = 
    if(getMontantArray(item)[0] == "CR" and getMontantArray(item)[1] != "0,00") 
        "-" ++ getMontantArray(item)[1]
    else 
        getMontantArray(item)[1]

fun getDiffDeChange(item: String) =
    item substringBefore "(Diff de change)" substringAfterLast "Mont" splitBy " " filter ((item) -> item != "EUR" and item != "CR" and item != "DB") joinBy ""
---


getFilterdPayload(payload) map ((item) -> 
            {
                "Type": "Impayés",
                "Sous_type__c": getSubstring("DU", "24", item),
                "Num_ro_de_dossier__c": analyzeSubString("TPE", "Dossier", item, -3),
                "TPE__c": analyzeSubString("ant", "TPE", item, -8),
                "X6_premiers_chiffres__c": getSubstring("Lib.", "Carte", item)[0 to 5],
                "X4_derniers_chiffres__c": getSubstring("Lib.", "Carte", item)[12 to 15],
                "R_f_rence_d_Archivage__c": getSubstring("Mont", "d'archivage :", item),
                "Montant__c": filterMontant(item),
                "Date_Transaction__c": getSubstring("Date Valeur", "Achat", item),
                "Date_de_R_ception__c": getSubstring("Dossier", "DU", item),
                "Diff_de_Change__c": getDiffDeChange(item),
                "Code_motif__c": trim(item substringBeforeLast " : " substringAfterLast " - "),
                "Num_ro_Autorisation__c": analyzeSubString("rence", "ro d'auto :", item, -5),
                "Reference_Client__c": analyzeSubString("Carte", "f.Cli", item, -1),
                "Lib.": analyzeSubString("ro", "Lib. :", item, -5),
                "motif_opp": analyzeSubString("ro", "carte -", item, -5),
                "Commercant": analyzeSubString("f.Cli", "ant", item, -3)
            }
            //Os valore a negativo dentro da funçao analyse string e a quantidade de letras removidas + 1, onde -1 signifia que nada foi removido (no before)
        )