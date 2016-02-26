
local function pre_process(msg)
  -- SERVICE MESSAGE
  if msg.action and msg.action.type then
    local action = msg.action.type
    -- Check if banned user joins chat by link
    if action == 'chat_add_user_link' then
      local user_id = msg.from.id
      print('Controllo id invitato: '..user_id)
      local banned = is_banned(user_id, msg.to.id)
      if banned or is_gbanned(user_id) then -- Check it with redis
      print('L\'utente è bannato!')
      local name = user_print_name(msg.from)
      savelog(msg.to.id, name.." ["..msg.from.id.."] è bannato, ed è stato kickato! ")-- Save to logs
      kick_user(user_id, msg.to.id)
      end
    end
    -- Check if banned user joins chat
    if action == 'chat_add_user' then
      local data = load_data(_config.moderation.data)
      local user_id = msg.action.user.id
      print('Controllo id invitato: '..user_id)
      local banned = is_banned(user_id, msg.to.id)
      if banned or is_gbanned(user_id) then -- Check it with redis
        print('L\'utente è bannato!')
        local name = user_print_name(msg.from)
        savelog(msg.to.id, name.." ["..msg.from.id.."] ha aggiunto un utente bannato >"..msg.action.user.id)-- Save to logs
        kick_user(user_id, msg.to.id)
        local banhash = 'addedbanuser:'..msg.to.id..':'..msg.from.id
        redis:incr(banhash)
        local banhash = 'addedbanuser:'..msg.to.id..':'..msg.from.id
        local banaddredis = redis:get(banhash) 
        if banaddredis then 
          if tonumber(banaddredis) == 4 and not is_owner(msg) then 
            kick_user(msg.from.id, msg.to.id)-- Kick user who adds ban ppl more than 3 times
          end
          if tonumber(banaddredis) ==  8 and not is_owner(msg) then 
            ban_user(msg.from.id, msg.to.id)-- Kick user who adds ban ppl more than 7 times
            local banhash = 'addedbanuser:'..msg.to.id..':'..msg.from.id
            redis:set(banhash, 0)-- Reset the Counter
          end
        end
      end
      if data[tostring(msg.to.id)] then
        if data[tostring(msg.to.id)]['settings'] then
          if data[tostring(msg.to.id)]['settings']['lock_bots'] then 
            bots_protection = data[tostring(msg.to.id)]['settings']['lock_bots']
          end
         end
        end
      --end
    if msg.action.user.username ~= nil then
      if string.sub(msg.action.user.username:lower(), -3) == 'bot' and not is_momod(msg) and bots_protection == "yes" then --- Will kick bots added by normal users
        local name = user_print_name(msg.from)
          savelog(msg.to.id, name.." ["..msg.from.id.."] ha aggiunto un bot > @".. msg.action.user.username)-- Save to logs
          kick_user(msg.action.user.id, msg.to.id)
      end
    end
  end
    -- No further checks
  return msg
  end
  -- banned user is talking !
  if msg.to.type == 'chat' then
    local data = load_data(_config.moderation.data)
    local group = msg.to.id
    local texttext = 'groups'
    --if not data[tostring(texttext)][tostring(msg.to.id)] and not is_realm(msg) then -- Check if this group is one of my groups or not
    --chat_del_user('chat#id'..msg.to.id,'user#id'..our_id,ok_cb,false)
    --return 
    --end
    local user_id = msg.from.id
    local chat_id = msg.to.id
    local banned = is_banned(user_id, chat_id)
    if banned or is_gbanned(user_id) then -- Check it with redis
      print('Utente bannato che parla!')
      local name = user_print_name(msg.from)
      savelog(msg.to.id, name.." ["..msg.from.id.."] utente bannato che parla!")-- Save to logs
      kick_user(user_id, chat_id)
      msg.text = ''
    end
  end
  return msg
end

local function username_id(cb_extra, success, result)
  local get_cmd = cb_extra.get_cmd
  local receiver = cb_extra.receiver
  local chat_id = cb_extra.chat_id
  local member = cb_extra.member
  local sender=cb_extra.sender
  local text = ''
  for k,v in pairs(result.members) do
    vusername = v.username
    if vusername == member then
      member_username = member
      member_id = v.id
      if member_id == our_id then 
        return false 
      end
      if get_cmd == 'kicka' then
        if member_id==sender then
          return send_large_msg(receiver, "Non puoi kickarti da solo")
        end
        if is_momod2(member_id, chat_id) and not is_admin2(sender) then
          return send_large_msg(receiver, "Non puoi kickare moderatori, proprietario od amministratori")
        end
        return kick_user(member_id, chat_id)
      elseif get_cmd == 'banna' then
        if is_momod2(member_id, chat_id) and not is_admin2(sender) then
          return send_large_msg(receiver, "Non puoi bannare moderatori, proprietario od amministratori")
        end
        send_large_msg(receiver, 'L\'utente @'..member..' ['..member_id..'] è stato bannato')
        return ban_user(member_id, chat_id)
      elseif get_cmd == 'unbanna' then
        send_large_msg(receiver, 'L\'utente @'..member..' ['..member_id..'] è stato unbannato')
        local hash =  'banned:'..chat_id
        redis:srem(hash, member_id)
        return 'Utente '..user_id..' unbannato'
      elseif get_cmd == 'bang' then
        send_large_msg(receiver, 'L\'utente @'..member..' ['..member_id..'] è stato bannato globalmente')
        return banall_user(member_id, chat_id)
      elseif get_cmd == 'unbannag' then
        send_large_msg(receiver, 'L\'utente @'..member..' ['..member_id..'] è stato rimosso dalla lista dei ban globali')
        return unbanall_user(member_id, chat_id)
      end
    end
  end
  return send_large_msg(receiver, text)
end

local function run(msg, matches)
 if matches[1]:lower() == 'id' then
    if msg.to.type == "user" then
      return "ID bot: "..msg.to.id.. "\n\nIl tuo ID: "..msg.from.id
    end
    if type(msg.reply_id) ~= "nil" then
      local name = user_print_name(msg.from)
        savelog(msg.to.id, name.." ["..msg.from.id.."] used /id ")
      id = get_message(msg.reply_id,get_message_callback_id, false)
    elseif matches[1]:lower() == 'id' then
      local name = user_print_name(msg.from)
      savelog(msg.to.id, name.." ["..msg.from.id.."] used /id ")
      return "ID del gruppo " ..string.gsub(msg.to.print_name, "_", " ").. ":\n\n"..msg.to.id  
    end
  end
  local receiver = get_receiver(msg)
  if matches[1]:lower() == 'kickami' then-- /kickme
    if msg.to.type == 'chat' then
      local name = user_print_name(msg.from)
      savelog(msg.to.id, name.." ["..msg.from.id.."] ha abbandonato con kickme ")-- Save to logs
      chat_del_user("chat#id"..msg.to.id, "user#id"..msg.from.id, ok_cb, false)
    end
  end
  if not is_momod(msg) then -- Ignore normal users 
    return nil
  end

  if matches[1]:lower() == "listaban" then -- Ban list !
    local chat_id = msg.to.id
    if matches[2] and is_admin(msg) then
      chat_id = matches[2] 
    end
    return ban_list(chat_id)
  end
  if matches[1]:lower() == 'banna' then-- /ban 
    if type(msg.reply_id)~="nil" and is_momod(msg) then
      if is_admin(msg) then
        local msgr = get_message(msg.reply_id,ban_by_reply_admins, false)
      else
        msgr = get_message(msg.reply_id,ban_by_reply, false)
      end
    end
    if msg.to.type == 'chat' then
      local user_id = matches[2]
      local chat_id = msg.to.id
      if string.match(matches[2], '^%d+$') then
        if tonumber(matches[2]) == tonumber(our_id) then 
          return
        end
        if not is_admin(msg) and is_momod2(tonumber(matches[2]), msg.to.id) then
          return "Non puoi bannare moderatori, proprietario od amministratori"
        end
        if tonumber(matches[2]) == tonumber(msg.from.id) then
          return "Non puoi bannarti da solo!"
        end
        local name = user_print_name(msg.from)
        savelog(msg.to.id, name.." ["..msg.from.id.."] ha bannato ".. matches[2])
        ban_user(user_id, chat_id)
      else
        local member = string.gsub(matches[2], '@', '')
        local get_cmd = 'banna'
        local name = user_print_name(msg.from)
        savelog(msg.to.id, name.." ["..msg.from.id.."] ha bannato ".. matches[2])
        chat_info(receiver, username_id, {get_cmd=get_cmd, receiver=receiver, chat_id=msg.to.id, member=member})
      end
    return 
    end
  end
  if matches[1]:lower() == 'unbanna' then -- /unban 
    if type(msg.reply_id)~="nil" and is_momod(msg) then
      local msgr = get_message(msg.reply_id,unban_by_reply, false)
    end
    if msg.to.type == 'chat' then
      local user_id = matches[2]
      local chat_id = msg.to.id
      local targetuser = matches[2]
      if string.match(targetuser, '^%d+$') then
        local user_id = targetuser
        local hash =  'banned:'..chat_id
        redis:srem(hash, user_id)
        local name = user_print_name(msg.from)
        savelog(msg.to.id, name.." ["..msg.from.id.."] ha unbannato ".. matches[2])
        return 'User '..user_id..' unbanned'
      else
        local member = string.gsub(matches[2], '@', '')
        local get_cmd = 'unbanna'
        chat_info(receiver, username_id, {get_cmd=get_cmd, receiver=receiver, chat_id=msg.to.id, member=member})
      end
    end
  end

  if matches[1]:lower() == 'kicka' then
    if type(msg.reply_id)~="nil" and is_momod(msg) then
      if is_admin(msg) then
        local msgr = get_message(msg.reply_id,Kick_by_reply_admins, false)
      else
        msgr = get_message(msg.reply_id,Kick_by_reply, false)
      end
    end
    if msg.to.type == 'chat' then
      local user_id = matches[2]
      local chat_id = msg.to.id
      if string.match(matches[2], '^%d+$') then
        if tonumber(matches[2]) == tonumber(our_id) then 
          return
        end
        if not is_admin(msg) and is_momod2(matches[2], msg.to.id) then
          return "Non puoi kickare moderatori, proprietario od amministratori"
        end
        if tonumber(matches[2]) == tonumber(msg.from.id) then
          return "Non puoi kickarti da solo! C\'è /kickme per questo"
        end
        local name = user_print_name(msg.from)
        savelog(msg.to.id, name.." ["..msg.from.id.."] ha kickato ".. matches[2])
        kick_user(user_id, chat_id)
      else
        local member = string.gsub(matches[2], '@', '')
        local get_cmd = 'kicka'
        local name = user_print_name(msg.from)
        savelog(msg.to.id, name.." ["..msg.from.id.."] ha kickato ".. matches[2])
        chat_info(receiver, username_id, {get_cmd=get_cmd, receiver=receiver, chat_id=msg.to.id, member=member, sender=msg.from.id})
      end
    else
      return 'Questo non è un gruppo'
    end
  end

  if not is_admin(msg) then
    return
  end

  if matches[1]:lower() == 'bang' then -- Global ban
    if type(msg.reply_id) ~="nil" and is_admin(msg) then
      return get_message(msg.reply_id,banall_by_reply, false)
    end
    local user_id = matches[2]
    local chat_id = msg.to.id
    if msg.to.type == 'chat' then
      local targetuser = matches[2]
      if string.match(targetuser, '^%d+$') then
        if tonumber(matches[2]) == tonumber(our_id) then
         return false 
        end
        banall_user(targetuser)
        return 'L\'utente ['..user_id..' ] è stato bannato globalmente'
      else
        local member = string.gsub(matches[2], '@', '')
        local get_cmd = 'bang'
        chat_info(receiver, username_id, {get_cmd=get_cmd, receiver=receiver, chat_id=msg.to.id, member=member})
      end
    end
  end
  if matches[1]:lower() == 'unbannag' then -- Global unban
    local user_id = matches[2]
    local chat_id = msg.to.id
    if msg.to.type == 'chat' then
      if string.match(matches[2], '^%d+$') then
        if tonumber(matches[2]) == tonumber(our_id) then 
          return false 
        end
        unbanall_user(user_id)
        return 'L\'utente ['..user_id..' ] è stato rimosso dalla lista dei ban globali'
      else
        local member = string.gsub(matches[2], '@', '')
        local get_cmd = 'unbannag'
        chat_info(receiver, username_id, {get_cmd=get_cmd, receiver=receiver, chat_id=msg.to.id, member=member})
      end
    end
  end
  if matches[1]:lower() == "listabang" then -- Global ban list
    return banall_list()
  end
end

return {
  patterns = {
    "^/([Bb]ang) (.*)$",
    "^/([Bb]ang)$",
    "^/([Ll]istaban) (.*)$",
    --"^[!/]([Ll]istaban)$",
    "^/([Ll]istabang)$",
    "^/([Bb]anna) (.*)$",
    "^/([Kk]icka)$",
    "^/([Uu]nbanna) (.*)$",
    "^/([Uu]nbannag) (.*)$",
    "^/([Uu]nbannag)$",
    "^/([Kk]icka) (.*)$",
    "^/([Kk]ickami)$",
    "^/([Bb]anna)$",
    "^/([Uu]nbanna)$",
    "^/([Ii]d)$",
    "^!!tgservice (.+)$",
  },
  run = run,
  pre_process = pre_process
}
