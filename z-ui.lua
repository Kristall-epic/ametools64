SCALE = .75

pointer = {
  look = {
    yaw = 0x0,
    pitch = 0x0
  },
  pos = {
    x = 0,
    y = 0
  },
maxVal = 8
}

squareW = 36

function render()
  if AME.EDITOR == false then return end
  djui_hud_set_resolution(RESOLUTION_N64)
  width = djui_hud_get_screen_width()
  height = djui_hud_get_screen_height()
  
  squareW = (width/height)*16

  if (AME.info.gizmo.visible == true) then
    render_3d_gizmo(gLakituState, djui_hud_get_screen_width()/2 + 4, djui_hud_get_screen_height()/2 - 4, .65)
		djui_hud_set_color(0, 0, 0, 255)
		djui_hud_render_rect(djui_hud_get_screen_width()/2 - 1, djui_hud_get_screen_height()/2 - 1, 2, 2)
		djui_hud_set_color(255, 255, 255, 255)
		djui_hud_render_rect(djui_hud_get_screen_width()/2 - .5, djui_hud_get_screen_height()/2 - .5, 1, 1)
		djui_hud_reset_color()
  end
  
  if (AME.grab.obj) then
    local scl = .25
		
		local model = models[obj_get_model_id_extended(AME.grab.obj)] or "E_MODEL_CUSTOM_"..obj_get_model_id_extended(AME.grab.obj)
	  if model == "E_MODEL_ERROR_MODEL" then
      model = models[AME.grab.obj.oUnk94]
	  end
    
    AME.grab.properties[BEHAVIOR] = behaviors[get_id_from_behavior(AME.grab.bhv)] or tostring(AME.grab.bhv)
    AME.grab.properties[MODEL] = model
    AME.grab.properties[BEH] = "["..string.format("%02x %02x %02x %02x", (AME.grab.obj.oBehParams >> 24) & 0xFF, (AME.grab.obj.oBehParams >> 16) & 0xFF, (AME.grab.obj.oBehParams >> 8) & 0xFF, AME.grab.obj.oBehParams & 0xFF).."]"
		
    AME.grab.properties[SPACE_TRANSFORM] = ""
    AME.grab.properties[TRANSFORM] = "Transform"
    AME.grab.properties[POSITION] = tostring(string.format("%0.2f",AME.grab.obj.oPosX)..", "..string.format("%0.2f",AME.grab.obj.oPosY)..", "..string.format("%0.2f",AME.grab.obj.oPosZ))
    AME.grab.properties[ANGLE] = "P:"..convertToHex(AME.grab.obj.oFaceAnglePitch).." Y:"..convertToHex(AME.grab.obj.oFaceAngleYaw).." R:"..convertToHex(AME.grab.obj.oFaceAngleRoll)
    
    for i, txt in pairs(AME.grab.properties) do
      local x = djui_hud_get_screen_width() - djui_hud_measure_text(txt)*scl
      local y = (scl*28)*i
      
      djui_hud_print_text(txt, x, 36 + y, scl)
    end
  end


    local cols = 3
    local m = gMarioStates[0]
    
    local offsetRow = math.floor(spawner.id / cols)
      local offsetCol = spawner.id % cols
      
    if (AME.spawning == true) then
      
    djui_hud_set_color(0x91, 0x6c, 0xca, 255)
      djui_hud_render_rect(6 + squareW*offsetCol + AME.ui.critterbox.pos.x, squareW*3 - 2, squareW, squareW)
      djui_hud_reset_color()
    end
    
    for i, obj in ipairs(BMOD_OBJ_LIST) do
      local row = math.floor(i / cols)
      local col = i % cols
      
      final = {
        x = (squareW * col + 8) + AME.ui.critterbox.pos.x,
        y = squareW * row + (squareW*2)
      }
      
      local txtScale = squareW/(djui_hud_measure_text(obj.name) + 1)
    
    if (final.y - squareW*offsetRow < djui_hud_get_screen_height() and final.y - squareW*offsetRow > -16) then
      djui_hud_set_color(32, 32, 32, 255)
      djui_hud_render_rect(final.x, final.y + squareW - squareW*offsetRow, squareW - 4, squareW - 4)
        djui_hud_set_color(255, 255, 255, 255)
        djui_hud_print_text(obj.name, final.x, final.y + squareW - squareW*offsetRow, .8*txtScale)
      djui_hud_reset_color()
      end
    end
		
		showBuiltObject = AME.spawning == true and AME.spawnMode == SPAWN_MODE_BUILD
		
		if showBuiltObject == true then
		  AME.ui.builtobj.pos.x = lerp(AME.ui.builtobj.pos.x, 0, .1)
		else	
			AME.ui.builtobj.pos.x = lerp(AME.ui.builtobj.pos.x, -128, .1)
		end
		
		djui_hud_set_color(32, 32, 32, 192)
		djui_hud_render_rect(AME.ui.builtobj.pos.x + 12, djui_hud_get_screen_height()/2 - 16, 64, 12)
		djui_hud_render_rect(AME.ui.builtobj.pos.x + 12, djui_hud_get_screen_height()/2, 64, 12)
		djui_hud_render_rect(AME.ui.builtobj.pos.x + 12, djui_hud_get_screen_height()/2 - 32, 64, 12)
		
		djui_hud_reset_color()
		djui_hud_print_text(behaviors[AME.builtObj.bhv] or "???", AME.ui.builtobj.pos.x + 16, djui_hud_get_screen_height()/2 - 16, .3)
    djui_hud_print_text(models[AME.builtObj.model] or "???", AME.ui.builtobj.pos.x + 16, djui_hud_get_screen_height()/2, .3)
		djui_hud_print_text("Object Builder", AME.ui.builtobj.pos.x + 16, djui_hud_get_screen_height()/2 - 32, .35)
		
		
		showComboObjects = AME.spawning == true and AME.spawnMode == SPAWN_MODE_COMBO
		
    if showComboObjects == false then
     AME.ui.critterbox.pos.x = lerp(AME.ui.critterbox.pos.x, -128, .1)
		else
		 AME.ui.critterbox.pos.x = lerp(AME.ui.critterbox.pos.x, 1, .1)
    end
		
		if djui_is_chatbox_open() then
		  AME.ui.top.pos.y = math.lerp(AME.ui.top.pos.y, 0, .1)
		else
		  AME.ui.top.pos.y = math.lerp(AME.ui.top.pos.y, -50, .1)
		end
		
    
    djui_hud_set_color(36, 36, 36, 255)
    djui_hud_render_rect(AME.ui.top.pos.x, AME.ui.top.pos.y, width, (120*.35))
    djui_hud_reset_color()
    djui_hud_print_text("Critterbox [s]", AME.ui.top.pos.x + 4, AME.ui.top.pos.y + (120*.35) - 12, .35)
    
end

hook_event(HOOK_ON_HUD_RENDER_BEHIND, render)