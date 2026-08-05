-- name: ~ AmeTools64 ~
-- descriptions: Ametools64 is a powerful level editor similar to TT64 and Quad64 that lets you add, move around, change certain properties, and delete objects in a level, it can even export all objects in the level to ModFS in a format you can paste into a script.c file\nthere's also API functions that let you add custom objects for you and others to mess around with!
define_custom_obj_fields({oLoremIpsum = 'u32', oTrueModelIndex = 'u32'})

function toggle_editor()
  AME.EDITOR = not AME.EDITOR
  
  if AME.EDITOR == false then
    hud_show()
    camera_unfreeze()
    set_first_person_enabled(false)
    set_override_fov(0)
    setwitdh("1")
    setheighth("1")
    viewportPos(".5 .5")
  else
    hud_hide()
    set_override_fov(70)
    --set_first_person_enabled(true)
    AME.camPos = {
      x = gMarioStates[0].pos.x,
      y = gMarioStates[0].pos.y + 250,
      z = gMarioStates[0].pos.z
    }
    setwitdh(".55")
    setheighth(".65")
    viewportPos(".5 .525")
  end
  
  return true
end

hook_chat_command("kex", "- toggles editor mode", toggle_editor)

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
	  if string.find(key, "E_MODEL_") then
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