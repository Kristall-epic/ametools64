
--set mario position to camera [m]
function keybind_teleport_mario_to_cam(m)
  m.pos.x = AME.camPos.x
  m.pos.y = AME.camPos.y
  m.pos.z = AME.camPos.z
end

hook_keybind("m", keybind_teleport_mario_to_cam)

--toggle object spawning mode [s]
function keybind_toggle_spawning(m)
  AME.spawning = not AME.spawning
end

hook_keybind("s", keybind_toggle_spawning)

--toggle coordinate gizmo that lets you see where ±X, ±Z and ±Y are [n]
function toggle_gizmo(m)
  AME.info.gizmo.visible = not AME.info.gizmo.visible
  return true
end

hook_keybind("n", toggle_gizmo)

--launches a magic beam from your camera position and angle that grabs the first object it touches [g]
function grab_object(m)
  
  spawn_non_sync_object(id_bhvObjectGrabber, E_MODEL_WATER_MINE, AME.camPos.x, AME.camPos.y, AME.camPos.z, nil)
end

hook_keybind("g", grab_object)

--destroys the currently grabbed object [x]
function delete_grabbed(m)
  
  if AME.grab.obj == m.marioObj then djui_popup_create("DON'T DELETE MARIO PLEASE", 1) end
  
  if (not AME.grab.obj) or AME.grab.obj == m.marioObj then return end
  
  spawn_non_sync_object(id_bhvExplosion, E_MODEL_EXPLOSION, AME.grab.pos.x, AME.grab.pos.y, AME.grab.pos.z, nil)
  
  obj_mark_for_deletion(AME.grab.obj)
  
  AME.grab.obj = nil
end

hook_keybind("x", delete_grabbed)

--spawns a copy of the currently grabbed object [d]
function dupe_grabbed(m)
if not AME.grab.obj then return end
  local o = AME.grab
	local model = obj_get_model_id_extended(o.obj)
	  if model == E_MODEL_ERROR_MODEL then
      model = o.obj.oUnk94
	  end
	
	spawn_sync_object(get_id_from_behavior(o.bhv), model, o.pos.x, o.pos.y, o.pos.z, function(obj) 
	  obj.oBehParams  = o.obj.oBehParams
		obj.oFaceAnglePitch = o.obj.oFaceAnglePitch
		obj.oFaceAngleYaw = o.obj.oFaceAngleYaw
		obj.oFaceAngleRoll = o.obj.oFaceAngleRoll
		obj.oUnk94 = o.obj.oUnk94 ~= 0 and o.obj.oUnk94 or o.model
	end)

end

hook_keybind("d", dupe_grabbed)

--sets the near plane very close to zero so z-buffer dies and you can see through stuff, lets you see all objects anywhere [v]
function toggle_x_ray_vision(m)
  AME.xray = not AME.xray
  
  if (AME.xray == true) then
    set_override_near(0.000000001)
  else
    set_override_near(1)
  end
end

hook_keybind("v", toggle_x_ray_vision)

--toggles if mario should be around the level or become part of the camera [Shift + m]
function toggle_mario(m)
  AME.mario = not AME.mario
	
	if AME.mario == true then
	  set_mario_action(m, ACT_FREEFALL, 0)
		m.health = 0x880
	end
	
end

hook_keybind("M", toggle_mario)

--saves all objects in the current level to modFS in a format that can be pasted into a script.c [Shift + s]
function save_level_objs(m)
  local lvl =
    level_is_vanilla_level(gNetworkPlayers[0].currLevelNum) == 0
    and smlua_level_util_get_info(gNetworkPlayers[0].currLevelNum).fullname
    or get_level_name(
      gNetworkPlayers[0].currCourseNum,
      gNetworkPlayers[0].currLevelNum,
      gNetworkPlayers[0].currAreaIndex
    )
	local lvl_file = string.lower(lvl:gsub(" ", "_"))	

  local filename = "level_"..lvl_file.."_area_"..gNetworkPlayers[0].currAreaIndex..".txt"

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
		  djui_popup_create("AME: Exported objects from level to\nuser/sav/"..modFs.modpath..".modfs/"..file.filepath, 4)
		else	
			djui_popup_create("AME: Error exporting objects from level.", 1)
		end
end

hook_keybind("S", save_level_objs)


--[[
[r]
toggles rotating the currently held object 
Joystick: horizontal changes yaw, vertical changes pitch
A & Z change the roll
R resets all rotations of the object to 0
]]

function toggle_rotate_mode(m)
  if not AME.grab.obj then return end
	
	AME.grab.rotating = not AME.grab.rotating
	
end

hook_keybind("r", toggle_rotate_mode)