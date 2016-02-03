local function set_bot_photo(msg, success, result)
  local receiver = get_receiver(msg)
  if success then
    local file = 'data/photos/bot.jpg'
    print('File scaricato in:', result)
    os.rename(result, file)
    print('File spostato in:', file)
    set_profile_photo(file, ok_cb, false)
    send_large_msg(receiver, 'Foto cambiata!', ok_cb, false)
    redis:del("bot:photo")
  else
    print('Errore nel download: '..msg.id)
    send_large_msg(receiver, 'Errore, per favore prova di nuovo!', ok_cb, false)
  end
end
local function parsed_url(link)
  local parsed_link = URL.parse(link)
  local parsed_path = URL.parse_path(parsed_link.path)
  return parsed_path[2]
end
local function get_contact_list_callback (cb_extra, success, result)
  local text = " "
  for k,v in pairs(result) do
    if v.print_name and v.id and v.phone then
      text = text..string.gsub(v.print_name ,  "_" , " ").." ["..v.id.."] = "..v.phone.."\n"
    end
  end
  local file = io.open("contact_list.txt", "w")
  file:write(text)
  file:flush()
  file:close()
  send_document("user#id"..cb_extra.target,"contact_list.txt", ok_cb, false)--.txt format
  local file = io.open("contact_list.json", "w")
  file:write(json:encode_pretty(result))
  file:flush()
  file:close()
  send_document("user#id"..cb_extra.target,"contact_list.json", ok_cb, false)--json format
end
local function user_info_callback(cb_extra, success, result)
  result.access_hash = nil
  result.flags = nil
  result.phone = nil
  if result.username then
    result.username = '@'..result.username
  end
  result.print_name = result.print_name:gsub("_","")
  local text = serpent.block(result, {comment=false})
  text = text:gsub("[{}]", "")
  text = text:gsub('"', "")
  text = text:gsub(",","")
  if cb_extra.msg.to.type == "chat" then
    send_large_msg("chat#id"..cb_extra.msg.to.id, text)
  else
    send_large_msg("user#id"..cb_extra.msg.to.id, text)
  end
end
local function get_dialog_list_callback(cb_extra, success, result)
  local text = ""
  for k,v in pairs(result) do
    if v.peer then
      if v.peer.type == "chat" then
        text = text.."grouppo{"..v.peer.title.."}["..v.peer.id.."]("..v.peer.members_num..")"
      else
        if v.peer.print_name and v.peer.id then
          text = text.."utente{"..v.peer.print_name.."}["..v.peer.id.."]"
        end
        if v.peer.username then
          text = text.."("..v.peer.username..")"
        end
        if v.peer.phone then
          text = text.."'"..v.peer.phone.."'"
        end
      end
    end
    if v.message then
      text = text..'\nUltimo messaggio >\nmsg id = '..v.message.id
      if v.message.text then
        text = text .. "\n testo = "..v.message.text
      end
      if v.message.action then
        text = text.."\n"..serpent.block(v.message.action, {comment=false})
      end
      if v.message.from then
        if v.message.from.print_name then
          text = text.."\n Da > \n"..string.gsub(v.message.from.print_name, "_"," ").."["..v.message.from.id.."]"
        end
        if v.message.from.username then
          text = text.."( "..v.message.from.username.." )"
        end
        if v.message.from.phone then
          text = text.."' "..v.message.from.phone.." '"
        end
      end
    end
    text = text.."\n\n"
  end
  local file = io.open("dialog_list.txt", "w")
  file:write(text)
  file:flush()
  file:close()
  send_document("user#id"..cb_extra.target,"dialog_list.txt", ok_cb, false)--.txt format
  local file = io.open("dialog_list.json", "w")
  file:write(json:encode_pretty(result))
  file:flush()
  file:close()
  send_document("user#id"..cb_extra.target,"dialog_list.json", ok_cb, false)--json format
end
local function run(msg,matches)
    local data = load_data(_config.moderation.data)
    local receiver = get_receiver(msg)
    local group = msg.to.id
    if not is_admin(msg) then
    	return
    end
    if msg.media then
      	if msg.media.type == 'photo' and redis:get("bot:photo") then
      		if redis:get("bot:photo") == 'waiting' then
        		load_photo(msg.id, set_bot_photo, msg)
      		end
      	end
    end
    if matches[1] == "fotobot" then
    	redis:set("bot:photo", "waiting")
    	return 'Per favore, inviami la nuova foto ora'
    end
    if matches[1] == "pm" then
    	send_large_msg("user#id"..matches[2],matches[3])
    	return "Messaggio inviato"
    end
    if matches[1] == "bloccautente" then
    	if is_admin2(matches[2]) then
    		return "Non puoi bloccare un admin"
    	end
    	block_user("user#id"..matches[2],ok_cb,false)
    	return "Utente bloccato"
    end
    if matches[1] == "sbloccautente" then
    	unblock_user("user#id"..matches[2],ok_cb,false)
    	return "Utente sbloccato"
    end
    if matches[1] == "importa" then--join by group link
    	local hash = parsed_url(matches[2])
    	import_chat_link(hash,ok_cb,false)
    end
    if matches[1] == "contatti" then
      get_contact_list(get_contact_list_callback, {target = msg.from.id})
      return "Ti ho inviato la lista contatti sottoforma di file e json in privato"
    end
    if matches[1] == "eliminacont" then
      del_contact("user#id"..matches[2],ok_cb,false)
      return "L\'utente "..matches[2].." è stato eliminato dalla lista dei contatti"
    end
    if matches[1] == "dialog" then
      get_dialog_list(get_dialog_list_callback, {target = msg.from.id})
      return "Ti ho inviato il dialog sottoforma di file e json in privato"
    end
    if matches[1] == "chi" then
      user_info("user#id"..matches[2],user_info_callback,{msg=msg})
    end
    return
end
return {
  patterns = {
	"^[!/](pm) (%d+) (.*)$",
	"^[!/](importa) (.*)$",
	"^[!/](sbloccautente) (%d+)$",
	"^[!/](bloccautente) (%d+)$",
	"^[!/](fotobot)$",
	"%[(photo)%]",
	"^[!/](contatti)$",
	"^[!/](dialog)$",
	"^[!/](eliminacont) (%d+)$",
	"^[!/](chi) (%d+)$"
  },
  run = run,
}