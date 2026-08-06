-- name: ~ AmeTools64 ~
-- descriptions: Ametools64 is a powerful level editor similar to TT64 and Quad64 that lets you add, move around, change certain properties, and delete objects in a level, it can even export all objects in the level to ModFS in a format you can paste into a script.c file\nthere's also API functions that let you add custom objects for you and others to mess around with!
define_custom_obj_fields({oLoremIpsum = 'u32', oTrueModelIndex = 'u32'})

function toggle_editor()
  AME.EDITOR = not AME.EDITOR
  
  if AME.EDITOR == false then
    hud_show()
    camera_unfreeze()
    set_override_fov(0)
  else
    hud_hide()
    set_override_fov(90)
    AME.camPos = {
      x = gMarioStates[0].pos.x,
      y = gMarioStates[0].pos.y + 250,
      z = gMarioStates[0].pos.z
    }
  end
  
  return true
end

hook_chat_command("ame", "- toggles editor mode", toggle_editor)

function camVelocity(vel)
  AME.camVel = tonumber(vel) or 50
  return true
end

hook_chat_command("kv", "- editor cam vel", camVelocity)

function turnVelocity(vel)
  AME.turnVel = tonumber(vel) or 50
  return true
end

hook_chat_command("kt", "- editor cam turning vel", turnVelocity)


--tries to find a model of a certain name in any of the currently active mods, if it is found, it is defined globally and added to ametools' list of models
function find_model(search)
  local model = smlua_model_util_get_id(search) or 159
  
	if model and model ~= 159 then
	  modelName = "E_MODEL_"..string.upper(string.sub(search, 0, search:len() - 4))
	
	  djui_chat_message_create("found "..search.." in a mod! Its ID is "..tostring(model)..' and now you can find it as "'..modelName..'"!')
		
		if not models[model] then
		  models[model] = modelName
		end
	else
		djui_chat_message_create("model not found, ignore script error, it means that smlua_model_util_get_id() did not find that model anywhere")
	end
	
  return true
end

hook_chat_command("ame-find-model", "- tries to find a model anywhere in your active mods then defines it globally so you can use it", find_model)


function keybinds(m, key)
  if (m.playerIndex ~= 0) then return end
  
  if key == "ame" then
    toggle_editor()
    return false
  end
  
  if AME.EDITOR ~= true then return end
  
  for i, v in pairs(keybindList) do
    if (key == v.str) then
      v.run(m)
    end
  end
	
	if AME.spawning == true and AME.spawnMode == SPAWN_MODE_BUILD then
	  if string.find(key, "E_MODEL") then
			obj_build_set_model(key)
	  end
	  
	  if string.find(key, "id_bhv") then
			obj_build_set_bhv(key)
	  end
	end	
  
  if AME.spawning ~= false and AME.spawnMode == SPAWN_MODE_COMBO then
    if (not string_is_keybind(key)) then
      local obj = find_object_by_name(key)
      
      if obj then
        spawner.id = obj
      else
        search_mode_name(key)
      end
    end
  end
  
  return false
end

hook_event(HOOK_ON_CHAT_MESSAGE, keybinds)