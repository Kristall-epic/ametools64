
function render_3d_gizmo(l) 
    
    pointer.pos.x = djui_hud_get_screen_width()*.5
    pointer.pos.y = djui_hud_get_screen_height()*.525
    
    
    local final_z_yaw = pointer.pos.x + (sins(pointer.look.yaw)*pointer.maxVal)*SCALE
      local final_z_pitch = pointer.pos.y + ((sins(pointer.look.pitch)*pointer.maxVal) * (coss(pointer.look.yaw)))*SCALE
      
      local final_x_yaw = pointer.pos.x + (coss(pointer.look.yaw + 0x8000)*pointer.maxVal)*SCALE
      local final_x_pitch = pointer.pos.y + ((sins(pointer.look.pitch)*pointer.maxVal) * (sins(pointer.look.yaw)))*SCALE
      
      local final_y_pitch = pointer.pos.y + (coss(pointer.look.pitch)*pointer.maxVal)*SCALE
      
      --render shadows
      djui_hud_set_color(64, 64, 64, 127)
      
      djui_hud_render_line(pointer.pos.x, pointer.pos.y - 0.75, final_z_yaw, final_z_pitch - 0.75, 3*SCALE)
      
      djui_hud_render_line(pointer.pos.x, pointer.pos.y - 0.75, final_x_yaw, final_x_pitch - 0.75, 3*SCALE)
      
      djui_hud_render_line(pointer.pos.x, pointer.pos.y, pointer.pos.x, final_y_pitch - 1.5, 3*SCALE)
      
      djui_hud_set_color(0, 255, 0, 192)
      
      --if looking up then Y line should be beneath X and Z line, render first
      if pointer.look.pitch <= 32768 then
      djui_hud_render_line(pointer.pos.x, pointer.pos.y, pointer.pos.x, final_y_pitch, 1.5*SCALE)
      end
      
      --if looking between the angle where Z should overlap X, make Z render on top
      if pointer.look.yaw > 0x4000 and pointer.look.yaw < 0x8000 then
      djui_hud_set_color(255, 0, 0, 192)
      
      djui_hud_render_line(pointer.pos.x, pointer.pos.y, final_x_yaw, final_x_pitch, 1.5*SCALE)
      
      djui_hud_set_color(0, 0, 255, 192)
      
      djui_hud_render_line(pointer.pos.x, pointer.pos.y, final_z_yaw, final_z_pitch, 1.5*SCALE)
      else
      djui_hud_set_color(0, 0, 255, 192)
      
      djui_hud_render_line(pointer.pos.x, pointer.pos.y, final_z_yaw, final_z_pitch, 1.5*SCALE)
      
      djui_hud_set_color(255, 0, 0, 192)
      
      djui_hud_render_line(pointer.pos.x, pointer.pos.y, final_x_yaw, final_x_pitch, 1.5*SCALE)
      end
      
      djui_hud_set_color(0, 255, 0, 192)
      --if looking down Y line should be on top, render last
      if pointer.look.pitch > 32768 then
      djui_hud_render_line(pointer.pos.x, pointer.pos.y, pointer.pos.x, final_y_pitch, 1.5*SCALE)
      end
    
      djui_hud_set_color(255, 255, 255, 255)
      djui_hud_set_rotation(0, 0, 0)
end

function find_object_by_name(string)
    for i, v in ipairs(BMOD_OBJ_LIST) do
        if v.name == string.upper(string) then
            return i
        end
      
    end
end

function find_model_by_behavior(bhv)

  for i, v in ipairs(BMOD_OBJ_LIST) do
    if v.behavior == bhv then
        return v.model
    end
		
  end
end

function search_mode_name(key)
    for i, v in pairs(BMOD_OBJ_LIST) do
        if string.find(v.name, string.upper(key)) then
            djui_chat_message_create(v.name)
            found = true
        end
    end
    
end

--hooks a string to run a function when inputted in chat while in Explorer, basically keybinds
function hook_keybind(key, func)
  if (type(key) == "string" and type(func) == "function") then
    
    local keybind = {
      str = key,
      run = func
    }
    table.insert(keybindList, keybind)
    
  end
  
end

function string_is_keybind(string)
  for i, key in pairs(keybindList) do
    if (string == key.str) then
      return true
    end
  end
end

function obj_get_nearest_object(o, radius)
  for i = 0, NUM_OBJ_LISTS - 1 do
        local o2 = obj_get_first(i)
        local dist = dist_between_objects(o2, o)
        repeat
            if (o2 and o2 ~= o) and dist < radius then
            return o2
            end
            o2 = obj_get_next(o2)
            dist = dist_between_objects(o2, o)
        until o2 == nil
    end
end

function convertToHex(val)
  sign = val < 0 and "-" or "+"
  if val == 0 then
    sign = ""
  end
  
return sign..string.format("0x%x", math.abs(val))
  
end

function create_object_c_func(o)

  local model = models[obj_get_model_id_extended(o)] or "E_MODEL_CUSTOM_"..obj_get_model_id_extended(o)
	if model == "E_MODEL_ERROR_MODEL" then
    model = models[o.oUnk94]
	end
	local pos = tostring(o.oPosX..", "..o.oPosY..", "..o.oPosZ)
	local p, y, r = sm64_to_degrees(o.oFaceAnglePitch), sm64_to_degrees(o.oFaceAngleYaw), sm64_to_degrees(o.oFaceAngleRoll)
	local angle = tostring(p..", "..y..", "..r)
	local p1, p2, p3, p4 = (o.oBehParams >> 24) & 0xFF, (o.oBehParams >> 16) & 0xFF, (o.oBehParams >> 8) & 0xFF, o.oBehParams & 0xFF
	local params = "0x"..string.format("%02x%02x%02x%02x", p1, p2, p3, p4)
	local beh = behaviors[get_id_from_behavior(o.behavior)] or "id_bhvCustom"..get_id_from_behavior(o.behavior)
	
	local final = "OBJECT("..model..", "..pos..", "..angle..", "..params..", "..beh.."),"
	
	return final
end

function set_grabbed_params(msg)
  local args = {}
    for argument in msg:gmatch("%S+") do table.insert(args, argument) end
    if args[1] ~= nil then args[1] = string.upper(args[1]) end
    
    if (not AME.grab.obj) then return true end
    
    if args[1] == nil or args[2] == nil or args[3] == nil or args[4] == nil then return true end

    if tonumber(args[1]) ~= nil and tonumber(args[2]) ~= nil and tonumber(args[3]) ~= nil and tonumber(args[4]) ~= nil then
        --OBJECT_PARAMS.param2 = tonumber(msg2)
        --OBJECT_PARAMS.param3 = tonumber(msg3)
        --OBJECT_PARAMS.param4 = tonumber(msg4)
        --OBJECT_PARAMS.param2ndbyte = tonumber(msg5)
        AME.grab.obj.oBehParams = (AME.grab.obj.oBehParams & 0x00000000) | ((tonumber(args[1]) & 0xFF) << 24) | ((tonumber(args[2]) & 0xFF) << 16) | ((tonumber(args[3]) & 0xFF) << 8) | ((tonumber(args[4]) & 0xFF)) 
        return true
    end
    
    
end

hook_chat_command("ame-params", "grabbed obj params", set_grabbed_params)

view = {
  dvd = false,
  x = 160,
  y = 120,
  velX = 1,
  velY = 1,
  w = 160,
  h = 120
}

function updateGeo()
if AME.EDITOR ~= true then return end
    viewport = geo_get_current_root()
    djui_hud_set_resolution(RESOLUTION_N64)
    
    if view.dvd == true then
      view.x = view.x + view.velX
      view.y = view.y + view.velY
      
      if view.x < 5 or view.x > 310 then
        view.velX = -view.velX
      end
      
      if view.y < 5 or view.y > 230 then
        view.velY = -view.velY
      end
      
    end
    
    viewport.x = view.x
    viewport.y = view.y
    
    viewport.width = view.w
    viewport.height = view.h
end

--hook_event(HOOK_ON_GEO_PROCESS, updateGeo)

function setwitdh(w)
  view.w = tonumber(w)*160
end

function setheighth(w)
  view.h = tonumber(w)*120
end

function viewportPos(pos)
  local posX, posY = pos:match("(%S+) (%S+)")
  
  if not posX or posX == 0 then posX = 1 end
  if not posY or posY == 0 then posY = 1 end
  
  view.x = 320*(tonumber(posX))
  view.y = 240*(tonumber(posY))
end

function search_id_from_behavior_name(bhv)
  
	for id, str in pairs(behaviors) do
	
	  if string.find(str, bhv) then
      djui_chat_message_create(str)
    end
	
	  if str == bhv then
		  return id
		end
	end
	
end

function get_id_from_model_name(model)
  
	for id, str in pairs(models) do
	
	  if string.find(str, string.upper(model)) then
      djui_chat_message_create(str)
    end
	
	  if str == string.upper(model) then
		  return id
		end
	end
	
end

function obj_build_set_bhv(bhv)
  local behID = search_id_from_behavior_name(bhv)
  
	if behID and AME.EDITOR == true and AME.spawnMode == SPAWN_MODE_BUILD then
    AME.builtObj.bhv = behID
	end
	return true
end

--hook_chat_command("ame-bhv", "- sets the built obj's behavior", obj_build_set_bhv)


function obj_build_set_model(model)
  local modelID = get_id_from_model_name(model)
  
	if modelID and AME.EDITOR == true and AME.spawnMode == SPAWN_MODE_BUILD then
    AME.builtObj.model = modelID
	end
	return true
end

--hook_chat_command("ame-model", "- sets the built obj's model", obj_build_set_model)