
local function run(msg, matches)

if matches[1] == 'admin' then
    local data = load_data(_config.moderation.data)
    local admins = 'admins'
    if not data[tostring(admins)] then
        data[tostring(admins)] = {}
        save_data(_config.moderation.data, data)
    end
    local message = 'Lista degli amministratori:\n\n'
    for k,v in pairs(data[tostring(admins)]) do
        message = message .. '- @' .. v .. ' [' .. k .. '] ' ..'\n'
    end
    return message
end



local service= 'Il comando di aiuto è molto lungo, ti è stato inviato in privato.\nSe non l\'hai ricevuto, allora scrivimi 12 messaggi (per aggirare lo spam reporting) e richiedi nuovamente su questo gruppo il messaggio di aiuto con /help'

local priv='COMANDI IN PRIVATO\n'
  ..'• /id : mostra il tuo id e quello del bot\n'
  ..'• /join [id] : fatti aggiungere al gruppo\n'
  ..'• /ping : verifica se il bot è in funzione\n'
  ..'• /contatta [testo] : contatta il proprietario del bot, se hai qualcosa da segnalare\n'
  ..'• /help : mostra questo messaggio\n'
  ..'\nHai aggiunto il bot ad un gruppo ma non funziona?\nQuesto perchè il gruppo non fa parte del suo indice. Chiedi ad un amministratore del bot (usa "/admin") di aggiungerlo per te'

local u='\nCOMANDI PER TUTTI\n'
  ..'• /regole : mostra le regole del gruppo\n'
  ..'• /about : mostra la descrizione del gruppo\n'
  ..'• /listamod : mostra l\'elenco dei moderatori di questo gruppo\n'
  ..'• /boss : mostra l\'id del proprietario del gruppo\n'
  ..'• /kickami : fatti rimuovere dal gruppo senza perdere messaggi e media\n'
  ..'• /id : mostra l\'id a risposta o l\'id del gruppo\n'
  ..'• /membri : mostra l\'elenco dei membri del Realm\n'
  ..'• /membrifile : mostra l\'elenco dei membri del realm sotto forma di file\n'
  ..'• /ping : verifica se il bot è in funzione\n'
  ..'• /join [id] : fatti aggiungere al gruppo\n'
  ..'• /help : mostra questo messaggio\n'
  ..'\nHai aggiunto il bot ad un gruppo ma non funziona?\nQuesto perchè il gruppo non fa parte del suo indice. Chiedi ad un amministratore del bot (usa "/admin") di aggiungerlo per te'

if msg.to.type == 'chat' then
    local receiver='user#'..msg.from.id
    send_large_msg('chat#'..msg.to.id, service, ok_cb, false)




local realm='COMANDI IN UN REALM\n'
  ..'• /creagruppo [nome] : crea un nuovo gruppo\n'
  ..'• /impostabout [id] [descrizione] : imposta la descrizione di un gruppo\n'
  ..'• /impostaregole [id] [regole] : imposta le regole di un gruppo\n'
  ..'• /nome [id] [nome] : imposta il nome di un gruppo\n'
  ..'• /[blocca|sblocca] [id] [nome|membri|foto|flood|bot|arabo] : blocca/sblocca nome/foto/membri/flood/bot/arabo di un gruppo\n'
  ..'• /info [id] : visualizza le impostazioni di un gruppo\n'
  ..'• /aggadmin [username|id] : promuovi ad amministratore del bot\n'
  ..'• /rimadmin [username|id] : rimuovi dagli amministratori del bot\n'
  ..'• /lista admin : mostra la lista degli amministratori del bot\n'
  ..'• /lista gruppi : mostra la lista dei gruppi amministrati dal Realm (file)\n'
  ..'• /log : mostra il log degli eventi del gruppo\n'

local ad='\nCOMANDI PER ADMIN\n'
  ..'Gli amministratori possono esercitare il loro potere nei Realm, hanno i poteri di moderatore ovunque ed inoltre:\n'
  ..'• /agg : aggiungi il gruppo all\'indice dei gruppi amministrati (da fare se il bot non ha creato il gruppo)\n'
  ..'• /rim : rimuovi il gruppo dall\'indice dei gruppi amministrati\n'
  ..'• /pm [id|username] [testo] : sinvia un messaggio ad un determinato id\n'
  ..'• /importa [link] : il bot si unirà al gruppo tramite link\n'
  ..'• /fotobot : cambia la foto del bot\n'
  ..'• /contatti : ricevi due file (txt e json) con l\'elenco dei contatti del bot\n'
  ..'• /eliminacont [id|username] : elimina l\'utente dall\'elenco dei contatti del bot\n'
  ..'• /dialog : invia due file (txt e json) con un\'anteprima delle conversazioni del bot\n'
  ..'• /chi [id] : mostra le info basilari dell\'utente\n'
  ..'• /setgrprop [id x] [id y] : imposta y come proprietario del gruppo x\n'
  ..'• /bloccautente [id|username] : blocca l\'utente (il bot bloccherà l\'utente)\n'
  ..'• /sbloccautente [id|username] : sblocca l\'utente (il bot sbloccherà l\'utente)\n'
  ..'• /bang [username|id|risposta] : banna l\'utente da tutti i gruppi amministrati da questo bot\n'
  ..'• /unbannag [username|id|risposta] : rimuovi l\'utente dall\'indice dei ban globali\n'
  ..'• /listaban [id] : mostra l\'elenco dei membri bannati dal gruppo\n'
  ..'• /listabang : mostra l\'elenco degli utenti bannati globalmente\n'
  ..'• /msg gruppo [id] : mostra le statistiche del gruppo\n'
  ..'• /msg bot : mostra le statistiche del bot\n'
  
local pr='COMANDI PER IL PROPRIETARIO (IN PRIVATO)\n'
  ..'• /tutto [id] : mostra tutte le informazioni sul gruppo\n'
  ..'• /cambiades [id] [descrizione] : cambia la descrizione del gruppo\n'
  ..'• /cambiaregole [id] [regole] : cambia le regole del gruppo\n'
  ..'• /cambianome [id] [nome] : cambia il nome del gruppo\n'
  ..'• /loggruppo [id] : mostra il log degli eventi rilevanti del gruppo\n'
  ..'• /owner [id x] banna [id y] : banna dal gruppo x l\'utente y\n'
  ..'• /owner [id x] unbanna [id y] : unbanna dal gruppo x l\'utente y\n'
  ..'• /owner [id x] kicka [id y] : kicka dal gruppo x l\'utente y\n'
  ..'• /owner [id] rim mod : rimuovi tutti i moderatori dal gruppo\n'
  ..'• /owner [id] rim regole : elimina le regole del gruppo\n'
  ..'• /owner [id] rim des : elimina la descrizione del gruppo\n'
  ..'• /owner [id] imflood : imposta la sensibilità del flood del gruppo\n'
  ..'• /owner [id] [blocca|sblocca] [nome|membri] : blocca/sblocca nome/membri\n'
  ..'• /owner [id] nuovo link : genera un nuovo link per il gruppo\n'
  ..'• /owner [id] mostra link : ricevi il link del gruppo\n\n'
  
  ..'Comandi che possono essere utilizzati dal proprietario di un gruppo per gestirlo in privato\n'
  
local prg='\nCOMANDI PER IL PROPRIETARIO (IN GRUPPO)\n'
  ..'Tutti i comandi disponibili ai moderatori, ed inoltre:\n'
  ..'• /spazza [membri|mod|regole|about] : elimina membri/moderatori/regole/descrizione\n'
  ..'• /setboss [id] : imposta il nuovo proprietario del gruppo\n'
  ..'• /tagga [messaggio] : tagga tutti i membri del gruppo in un messaggio\n'
  ..'• /kickanouser : rimuovi gli utenti senza uno username\n'
  


local mo='\nCOMANDI PER MODERATORI\n'
  ..'• /invita [username] : invita l\'utente nel gruppo\n'
  ..'• /nome [nome] : cambia il nome del gruppo\n'
  ..'• /foto : cambia la foto del gruppo (inviala dopo aver richiesto il comando sotto forma di immagine\n'
  ..'• /promuovi [id|username|risposta] : promuovi utente ad amministratore\n'
  ..'• /degrada [id|username|risposta] : rimuovi l\'utente dagli amministratori\n'
  ..'• /setta [regole|about] [regole|descrizione] : imposta le regole/la descrizione del gruppo\n'
  ..'• /[blocca|sblocca] [nome|membri|flood|arabo|bot] : blocca/sblocca il nome/impedisci l\'entrata di nuovi membri/attiva il blocco flood/rimuovi chi scrive caratteri arabi/impoedisci l\'aggiunta di bot\n'
  ..'• /setflood [5-20] : imposta la sensibiltà del kick per flood\n'
  ..'• /info : mostra le attuali impostazioni del gruppo\n'
  ..'• /nuovolink : genera un nuovo link e revoca quello precedente\n'
  ..'• /link : mostra il link del gruppo\n'
  ..'• /res [username|risposta] : mostra le info disponibili per quell\'utente\n'
  ..'• /banna [username|id|risposta] : banna l\'utente\n'
  ..'• /unbanna [username|id|risposta] : unbanna l\'utente\n'
  ..'• /kicka [username|id|risposta] : rimuovi l\'utente/banna [username|id|risposta] : banna l\'utente\n'
  ..'• /unbanna [username|id|risposta] : unbanna l\'utente\n'
  ..'• /kickainattivi [messaggi] : kicka gli utenti che hanno scritto meno messaggi del numero indicato. Se [messaggi] non è presente, verranno rimossi i membri che non hanno mai scritto\n'
  ..'• /salva [parola] [testo] : imposta una risposta personalizzata ad un comando\n'
  ..'• /get [parola] : mosta il testo associato a quella parola\n'
  ..'• /msg : mostra le statistiche del gruppo (file)\n'
  ..'• /msglista : mostra le statistiche del gruppo (messaggio)\n'




local help = ''

if is_realmM(msg) and not is_admin(msg) then
  help = realm..prg..mo..u
elseif is_realmM(msg) and is_admin(msg) then
  help = realm..ad..prg..mo..u
elseif is_admin(msg) and not is_realmM(msg) then
  help = ad..prg..mo..u
elseif is_owner(msg) then
  help = pr..prg..mo..u..'\n\n(non puoi usare i comandi per admin)' 
elseif is_momod(msg) then
  help = mo..u..'\n\n(non puoi usare i comandi per proprietario ed admin)'
else
  help = u..'\n\n(non puoi usare i comandi per moderatori, proprietario ed admin)'
end

send_large_msg(receiver, help, ok_cb, false)

--send_msg('chat#'..msg.to.id, 'In privato ;)', ok_cb, false)

else
    return priv
end

end

return {
  description = "/help",
  usage = "/help",
  patterns = {
    "^/help",
    "^/(admin)"
  }, 
  run = run 
}
