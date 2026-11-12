# Salesforce Device Tracker

Un proiect mic făcut de mine ca să exersez Salesforce: o aplicație care ține evidența echipamentelor IT (laptopuri, monitoare, telefoane) și a angajaților cărora le sunt date. Am pornit de la ce văd zilnic la serviciu, la suportul IT.

## Ce face
- ține evidența echipamentelor: tip, serie unică, status
- când aloci un echipament cuiva, statusul devine singur *Assigned*; când îl returnezi, revine *Available*
- nu te lasă să aloci un echipament care e deja dat altcuiva
- când un echipament intră *In Repair*, se creează automat un task

## Cum e construit
Două obiecte custom:
- `Device__c`: echipamentul (serie unică, tip, status, plus un roll-up cu numărul de alocări)
- `Device_Assignment__c`: alocarea, legată de echipament prin Master-Detail și de angajat (Contact) prin Lookup, cu dată de început și de sfârșit

Pe lângă obiecte:
- **Validation rule:** data de returnare nu poate fi înaintea celei de alocare
- **Trigger Apex + handler:** schimbă statusul și blochează alocările duble. Am ținut logica în clasa handler, iar trigger-ul doar o apelează. Codul nu face query-uri sau salvări în bucle, deci merge și pentru multe recorduri deodată
- **Teste Apex:** patru scenarii (alocare, alocare dublă, returnare, 200 de alocări deodată)
- **Flow:** când statusul trece pe *In Repair*, creează un task
- **Permission Set** cu drepturi de citire, creare și editare, fără ștergere
- o aplicație Lightning „Device Tracker” cu tab-urile necesare

## De ce am făcut așa
- Master-Detail către Device, pentru că o alocare nu are sens fără echipament și așa am putut face roll-up
- Lookup către Contact, pentru că angajatul există și în afara alocărilor
- Flow pentru ce e simplu, Apex pentru verificarea pe loturi

## Ce aș îmbunătăți
- la returnare, statusul devine *Available* fără să verifice dacă mai există alte alocări active
- task-ul din Flow nu se închide singur când echipamentul iese din *In Repair*
- o componentă LWC pentru alocare rapidă
