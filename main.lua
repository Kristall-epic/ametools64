-- name: ~ AmeTools64 ~
-- descriptions: Ametools64 is a powerful level editor similar to TT64 and Quad64 that lets you add, move around, change certain properties, and delete objects in a level, you can use any custom behavior/model as long as you can grab a sample of an object with said model/behavior, for models you only need to know its geo.bin name!, it can even export all objects in the level to ModFS in a format you can paste into a script.c file\nthere's also API functions that let you add custom presets for you and others to mess around with!

function toggle_editor()
  AME.EDITOR = not AME.EDITOR
  
  if AME.EDITOR == false then
    hud_show()
    camera_unfreeze(true)
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

hook_chat_command("ame-cam-vel", "- editor cam vel", camVelocity)

function turnVelocity(vel)
  AME.turnVel = tonumber(vel) or 50
  return true
end

hook_chat_command("ame-cam-turn", "- editor cam turning vel", turnVelocity)

function lerpStrength(power)
  power = tonumber(power) or .3
	
  AME.lerpStr = math.clamp(power, 0, 1)
  return true
end

hook_chat_command("ame-held-lerp", "[0-1] - how quickly the held object will move towards its intended position", lerpStrength)


--tries to find a model of a certain name in any of the currently active mods, if it is found, it is added to ametools' list of models so you can use it
function find_model(search)
  local model = smlua_model_util_get_id(search) or 159
  
	if model and model ~= 159 then
	  modelName = "E_MODEL_"..string.upper(string.sub(search, 0, search:len() - 4))
	
	  djui_chat_message_create("found "..search.." in a mod! Its ID is "..tostring(model)..' and now you can find it as "'..modelName..'" in the object builder!')
		
		if not models[model] then
		  models[model] = modelName
		end
	else
		djui_chat_message_create("model not found, ignore script error, it means that smlua_model_util_get_id() did not find that model anywhere")
	end
	
  return true
end

hook_chat_command("ame-find-model", "- tries to find a model anywhere in your active mods then adds it to ametools' model list so you can use it", find_model)


function find_behavior(name)

  for i = 16000, 32768 do
	  bhvName = get_behavior_name_from_id(i)
	
	  if bhvName and bhvName:find(name) then
		  djui_chat_message_create("found "..bhvName.." it is id "..i)
		end
	end

end

--hook_chat_command("ame-find-behavior", "- tries to find a behavior anywhere in your active mods then adds it to ametools' model list so you can use it", find_behavior)

--defines a custom behavior from the currently held object to ametools' behavior list so you can use it
function define_bhv_to_amelist(name)
   if not AME.grab.obj then djui_chat_message_create("Grab an object with custom behavior!!!") return true end   
	
	local id = get_id_from_behavior(AME.grab.bhv)
	
	if behaviors[id] or search_id_from_behavior_name(name) then
	  djui_chat_message_create("Behavior already exists")
		return true
	end
	
	behaviors[id] = name
	
	djui_chat_message_create("Defined behavior ID "..id.." as "..name..". You can now use it in the object builder")
  
	return true
end

hook_chat_command("ame-define-bhv", " [name] - if the held object has a custom behavior, adds it to ametools' behavior list so you can use it", define_bhv_to_amelist)


--defines a custom model from the currently held object to ametools' model list so you can use it
function define_model_to_amelist(name)
   if not AME.grab.obj then djui_chat_message_create("Grab an object with custom model!!!") return true end   
	
	local id = AME.grab.model
	
	if models[id] or get_id_from_model_name(name) then
	  djui_chat_message_create("Model already exists "..id)
		return true
	end
	
	models[id] = name
	
	djui_chat_message_create("Defined model ID "..id.." as "..name..". You can now use it in the object builder")
  
	return true
end

hook_chat_command("ame-define-model", " [name] - if the held object has a custom model, adds it to ametools' model list so you can use it", define_model_to_amelist)


function save_level_objs(key)
  local lvl =
    level_is_vanilla_level(gNetworkPlayers[0].currLevelNum) == 0
    and smlua_level_util_get_info(gNetworkPlayers[0].currLevelNum).fullname
    or get_level_name(
      gNetworkPlayers[0].currCourseNum,
      gNetworkPlayers[0].currLevelNum,
      gNetworkPlayers[0].currAreaIndex
    )
	local lvl_file = string.lower(lvl:gsub(" ", "_"))	
  
  local fallback = "level_"..lvl_file.."_area_"..gNetworkPlayers[0].currAreaIndex..".txt"

  local filename = #key > 0 and string.lower(key:gsub(" ", "_"))..".txt" or fallback

  local file = modFs:get_file(filename) or modFs:create_file(filename, true)
  file:set_text_mode(true) -- Set mode to text
  file:rewind() -- Reset offset to the beginning of the file

	local count = 0
	local lines = {}
	for i = 0, NUM_OBJ_LISTS - 1 do
        local o = obj_get_first(i)
        repeat
				  count = count + 1
						if (o and not excludedExports[get_id_from_behavior(o.behavior)]) then
              local new = create_object_c_func(o)
              table.insert(lines, new)
						end
            o = obj_get_next(o)
        until o == nil
    end
		file:erase(file.size)
		for i, obj in pairs(lines) do
		  file:write_line(obj)
		end
		local success = modFs:save()
		if (success == true) then
		  djui_popup_create("AME: Exported objects from level to\nuser/sav/"..modFs.modPath..".modfs/"..file.filepath, 4)
		else	
			djui_popup_create("AME: Error exporting objects from level.", 1)
		end

    return true
end

hook_chat_command("ame-export", " [name] - Export the current area's objects to ModFS.", save_level_objs)

function import_objs_from_modfs(key)
  local filename = tostring(key..".txt")
	local file = modFs:get_file(filename)

  if not file then
    djui_chat_message_create("AME: File "..key..".txt not found")
    return true
  end

    local count = 0
  for i = 0, NUM_OBJ_LISTS - 1 do
        local o = obj_get_first(i)
        repeat
				  count = count + 1
						if (o and not excludedExports[get_id_from_behavior(o.behavior)]) then
              obj_mark_for_deletion(o)
						end
            o = obj_get_next(o)
        until o == nil
    end

  file:rewind()
	
	while file:is_eof() ~= true do
	  local line = file:read_line()

    line = string.sub(line, 8, #line - 2)
	  
	  local objParam = {}
	  
	  for param in string.gmatch(line, "[^, ]+") do
      djui_chat_message_create(param)
			table.insert(objParam, param)
	  end
	
		load_obj_from_line(objParam[1], tonumber(objParam[2]), tonumber(objParam[3]), tonumber(objParam[4]), degrees_to_sm64(tonumber(objParam[5])), degrees_to_sm64(tonumber(objParam[6])), degrees_to_sm64(tonumber(objParam[7])), objParam[8], objParam[9])
		--load_coopstone(tostring(objParam[1]), tonumber(objParam[2]), objParam[3], tonumber(objParam[4]), tonumber(objParam[5]), tonumber(objParam[6]), tonumber(objParam[7]))
		
  end

  return true
end

hook_chat_command("ame-import", "[name] - destroys every object in the current area then imports a set of objects from ModFS", import_objs_from_modfs)

function ame_set_scale(msg)
  if not AME.grab.obj then return true end

  local args = {}
    for argument in msg:gmatch("%S+") do table.insert(args, argument) end
		
	local x = tonumber(args[1]) or 1
  local y = tonumber(args[2]) or 1
	local z = tonumber(args[3]) or 1


  obj_set_gfx_scale(AME.grab.obj, x, y, z)

end

hook_chat_command("ame-obj-scale", "g", ame_set_scale)


function set_obj_field(value)
  local value = tonumber(value)
  
	if value and AME.grab.obj and AME.chosen and AME.grab.obj[AME.chosen] and not immutableObjFields[AME.chosen] then
	  AME.grab.obj[AME.chosen] = value
	end
	return true
end
hook_chat_command("ame-set-field", "- sets a field from the grabbed object", set_obj_field)

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