
AME.camPos = {x = 0, y = 0, z = 0}
AME.camVel = 50
DISTANCE = 50

FLYCAM = true
angleYaw = 0x0
anglePitch = 0x0
local l, camera_freeze, vec3f_set, vec3f_copy, camera_unfreeze, obj_mark_for_deletion, spawn_sync_object, djui_popup_create_global, tostring, spawn_non_sync_object, clamp, play_sound, hook_event, hook_on_sync_table_change = gLakituState, camera_freeze, vec3f_set, vec3f_copy, camera_unfreeze, obj_mark_for_deletion, spawn_sync_object, djui_popup_create_global, tostring, spawn_non_sync_object, clamp, play_sound, hook_event, hook_on_sync_table_change

local function spawning_controls(m)
    m.peakHeight = m.pos.y
    m.freeze = true
		
    camera_freeze()
    set_first_person_enabled(false)
    OBJECT_DISTANCE = coss(anglePitch)*DISTANCE
    stickYaw = m.intendedYaw - gLakituState.yaw
    
    vec3f_set(l.focus, AME.camPos.x - sins(angleYaw)*OBJECT_DISTANCE, AME.camPos.y - sins(anglePitch)*DISTANCE, AME.camPos.z - coss(angleYaw)*OBJECT_DISTANCE)
    vec3f_copy(l.pos, AME.camPos)
    local grabDist = AME.grab.dist
    
    AME.grab.goalPos = {
      x = AME.camPos.x - sins(angleYaw)*(coss(anglePitch)*grabDist),
      y = AME.camPos.y - sins(anglePitch)*grabDist,
      z = AME.camPos.z - coss(angleYaw)*(coss(anglePitch)*grabDist)
    }
    
    if (AME.grab.obj) then
      AME.grab.pos.x = math.lerp(AME.grab.pos.x, AME.grab.goalPos.x, AME.lerpStr)
      AME.grab.pos.y = math.lerp(AME.grab.pos.y, AME.grab.goalPos.y, AME.lerpStr)
      AME.grab.pos.z = math.lerp(AME.grab.pos.z, AME.grab.goalPos.z, AME.lerpStr)
      
      if (AME.grab.obj == m.marioObj) then
        m.pos.x = AME.grab.pos.x
        m.pos.y = AME.grab.pos.y
        m.pos.z = AME.grab.pos.z
        m.vel.y = 0
      else
        AME.grab.obj.oPosX = AME.grab.pos.x
        AME.grab.obj.oPosY = AME.grab.pos.y - AME.grab.obj.oVelY
        AME.grab.obj.oPosZ = AME.grab.pos.z
				if (AME.grab.obj.oVelY < 0) then
				  AME.grab.obj.oVelY = 0
				end
      end
      
      if (m.controller.buttonDown & D_JPAD ~= 0) then
        AME.grab.dist = AME.grab.dist + AME.camVel/2
      elseif (m.controller.buttonDown & U_JPAD ~= 0) then
        AME.grab.dist = AME.grab.dist - AME.camVel/2
      end
      
      if (m.controller.buttonPressed & B_BUTTON ~= 0) then
			  if AME.grab.rotating == true then
					AME.grab.rotating = false
			  else
          if AME.grab.model == "E_MODEL_NONE" then
            obj_set_model_extended(AME.grab.obj, E_MODEL_NONE)
          end
				  
            AME.grab.obj = nil
			  end
			end	
      
    end
    
    if m.controller.buttonDown & L_CBUTTONS ~= 0 then
      angleYaw = angleYaw - 0x10*AME.turnVel
    end
    if m.controller.buttonDown & R_CBUTTONS ~= 0 then
      angleYaw = angleYaw + 0x10*AME.turnVel
    end
    
    if m.controller.buttonDown & U_CBUTTONS ~= 0 and anglePitch > -16000 then
      anglePitch = anglePitch - 0x10*AME.turnVel
    end
    if m.controller.buttonDown & D_CBUTTONS ~= 0 and anglePitch < 16000 then
      anglePitch = anglePitch + 0x10*AME.turnVel
    end

    if AME.grab.rotating == false then

      if (m.controller.buttonDown & A_BUTTON) ~= 0 then
          AME.camPos.x = AME.camPos.x + coss(-angleYaw - 0x4000)*(sins(anglePitch)*AME.camVel)
          AME.camPos.y = AME.camPos.y + coss(anglePitch)*(AME.camVel)
          AME.camPos.z = AME.camPos.z + sins(-angleYaw - 0x4000)*(sins(anglePitch)*AME.camVel)
          
      elseif (m.controller.buttonDown & Z_TRIG) ~= 0 then
          AME.camPos.x = AME.camPos.x - coss(-angleYaw - 0x4000)*(sins(anglePitch)*AME.camVel)
          AME.camPos.y = AME.camPos.y - coss(anglePitch)*(AME.camVel)
          AME.camPos.z = AME.camPos.z - sins(-angleYaw - 0x4000)*(sins(anglePitch)*AME.camVel)
      end
    
		  --Horizontal movement
      AME.camPos.x = AME.camPos.x + sins(stickYaw + angleYaw)*((AME.camVel*(m.controller.stickMag/64))*coss(anglePitch))
      AME.camPos.z = AME.camPos.z + coss(stickYaw + angleYaw)*((AME.camVel*(m.controller.stickMag/64))*coss(anglePitch))
      
		  --Vertical movement, can move horizontally based on pitch cuz it is like godot camera
      AME.camPos.y = AME.camPos.y + sins(anglePitch)*coss(stickYaw)*(AME.camVel*(m.controller.stickMag/64))
      AME.camPos.x = AME.camPos.x + sins(angleYaw + 0x4000)*(AME.camVel*(m.controller.rawStickX/127)*sins(anglePitch)) * (anglePitch < 0 and -1 or 1)
      AME.camPos.z = AME.camPos.z + coss(angleYaw + 0x4000)*(AME.camVel*(m.controller.rawStickX/127)*sins(anglePitch)) * (anglePitch < 0 and -1 or 1)
		else
		  if not AME.grab.obj then
			  AME.grab.rotating = false
			end
		
		  if m.controller.buttonDown & A_BUTTON ~= 0 then
			  AME.grab.obj.oFaceAngleRoll = AME.grab.obj.oFaceAngleRoll + (AME.camVel*20)
			end
			
			if m.controller.buttonDown & Z_TRIG ~= 0 then
			  AME.grab.obj.oFaceAngleRoll = AME.grab.obj.oFaceAngleRoll - (AME.camVel*20)
			end
			
			if m.controller.buttonPressed & R_TRIG ~= 0 then
			  AME.grab.obj.oFaceAngleYaw = 0
			  AME.grab.obj.oFaceAnglePitch = 0
			  AME.grab.obj.oFaceAngleRoll = 0
			end
		  
			AME.grab.obj.oFaceAngleYaw = AME.grab.obj.oFaceAngleYaw + ((m.controller.rawStickX/127)*(AME.camVel*20))*AME.grab.rotY
		  AME.grab.obj.oFaceAnglePitch = AME.grab.obj.oFaceAnglePitch - ((m.controller.rawStickY/127)*(AME.camVel*20))*AME.grab.rotP
		
    end
        if (AME.spawning == true) then
          
					if m.controller.buttonPressed & R_TRIG ~= 0 then
					  AME.spawnMode = 1 - AME.spawnMode
					end
					
					if AME.spawnMode == SPAWN_MODE_COMBO then
					
            if spawner.id > #BMOD_OBJ_LIST then
              spawner.id = 0
            end
            
            if spawner.id < 0 then
              spawner.id = #BMOD_OBJ_LIST
            end
            
            if (m.controller.buttonPressed & L_JPAD ~= 0) then
              spawner.id = spawner.id - 1
            end
            
            if (m.controller.buttonPressed & R_JPAD ~= 0) then
              spawner.id = spawner.id + 1
            end
            
            if (m.controller.buttonPressed & U_JPAD ~= 0) then
              spawner.id = spawner.id - 3
            end
            
            if (m.controller.buttonPressed & D_JPAD ~= 0) then
              spawner.id = spawner.id + 3
            end
						
					end
					
					if (m.controller.buttonPressed & B_BUTTON ~= 0 and AME.grab.rotating == false) then
            m.faceAngle.y = pointer.look.yaw + 0x8000
						local objX = AME.camPos.x - coss(-angleYaw - 0x4000)*(500*coss(anglePitch - 0x8000))
            local objY = AME.camPos.y - 500*sins(anglePitch)
            local objZ = AME.camPos.z - sins(-angleYaw - 0x4000)*(500*coss(anglePitch - 0x8000))
            
						if AME.spawnMode == SPAWN_MODE_COMBO then
              spawn_sync_object(BMOD_OBJ_LIST[spawner.id].behavior, BMOD_OBJ_LIST[spawner.id].model, objX, objY, objZ, function(o) o.oUnk94 = BMOD_OBJ_LIST[spawner.id].model end)
						else
							spawn_sync_object(AME.builtObj.bhv, AME.builtObj.model, objX, objY, objZ, function(o) o.oUnk94 = AME.builtObj.model end)
						end
          end
          
        end

end

local function update()
    local m = gMarioStates[0]
    l = gLakituState

    if AME.EDITOR == true then
        local manualYaw = atan2s(l.pos.z - l.focus.z, l.pos.x - l.focus.x)
  local manualPitch = atan2s(l.focus.y - l.pos.y, math.sqrt( (l.pos.z - l.focus.z)*(l.pos.z - l.focus.z) + (l.pos.x - l.focus.x)*(l.pos.x - l.focus.x))) + 0x4000
		
    pointer.look.yaw = manualYaw + 0x8000
    pointer.look.pitch = manualPitch
      
        spawning_controls(m)
    end
end

hook_event(HOOK_UPDATE, update)

hook_event(HOOK_MARIO_UPDATE, function(m) 
  if AME.mario == false and AME.EDITOR == true then
		set_mario_action(m, ACT_FREEFALL, 0)
		m.pos.x = AME.camPos.x
		m.pos.y = AME.camPos.y
		m.pos.z = AME.camPos.z
		m.vel.x = 0
		m.vel.y = 0
		m.vel.z = 0
		m.forwardVel = 0
		--m.visibleToObjects = false
		m.marioObj.header.gfx.scale.x = 0.0000001
		m.marioObj.header.gfx.scale.y = 0.0000001
		m.marioObj.header.gfx.scale.z = 0.0000001
	end
end)

hook_event(HOOK_ON_HUD_RENDER, function() m = gMarioStates[0] 
if AME.EDITOR == true then
  m.currentRoom = 0
end	
end)

function death(m)
  if AME.EDITOR == true and AME.mario == false then
	  return false
	end
end

hook_event(HOOK_ON_DEATH, death)