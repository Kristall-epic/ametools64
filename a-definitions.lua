modFs = mod_fs_get() or mod_fs_create()

BEHAVIOR = 1
MODEL = 2
BEH = 3
SPACE_TRANSFORM = 4
TRANSFORM = 5
POSITION = 6
ANGLE = 7
lerp = math.lerp

SPAWN_MODE_COMBO = 0
SPAWN_MODE_BUILD = 1

AME = {
  spawning = false,
	spawnMode = SPAWN_MODE_COMBO,
	builtObj = {
	  bhv = id_bhvStaticObject,
		model = E_MODEL_GOOMBA
	},
	EDITOR = false,
  xray = false,
	mario = true,
  camPos = {x = 0, y = 0, z = 0},
  camVel = 50,
  turnVel = 50,
  info = {
    gizmo = {
      visible = true,
      scale = .85
    }
  },
	ui = {
	  critterbox = {
		  vis = false,
			pos = {x = 0, y = 0}
		},
		builtobj = {
		  pos = {x = 0, y = 0}
	  },
		top = {
		  vis = false,
			pos = {x = 0, y = 0}
		}
	},
  grab = {
    obj = nil,
    bhv = 0,
    model = 0,
		rawModel = nil,
    dist = 500,
		rotating = false,
		rotY = 1,
		rotP = 1,
    goalPos = {
      x = 0,
      y = 0,
      z = 0
    },
    pos = {
      x = 0,
      y = 0,
      z = 0
    },
    properties = {
      [BEHAVIOR] = "id_bhvNone",
      [MODEL] = "E_MODEL_NONE",
      [BEH] = "[00 0c 00 00]",
      [SPACE_TRANSFORM] = "",
      [TRANSFORM] = "Transform",
      [POSITION] = "6, 26, 2004",
      [ANGLE] = "P:0x0, Y:0x0, R:0x0"
    }
  }
}

spawner = {
  id = 1
}

keybindList = {}

function object_model(o, model, exmodel)

if get_id_from_behavior(o.behavior) == id_bhvMario then return end
  
	if obj_get_model_id_extended(o) == E_MODEL_ERROR_MODEL or obj_get_model_id_extended(o) == E_MODEL_NONE then
    o.oUnk94 = find_model_by_behavior(get_id_from_behavior(o.behavior)) or E_MODEL_ERROR_MODEL
	end
end

hook_event(HOOK_ON_OBJECT_LOAD, object_model)

excludedExports = {
  [id_bhvChainChompChainPart] = true,
	[id_bhvBobombAnchorMario] = true,
	[id_bhvCannonBarrelBubbles] = true,
	[id_bhvCannonBarrel] = true,
	[id_bhvCheckerboardPlatformSub] = true,
	[id_bhvCoinFormation] = true,
	[id_bhvMario] = true,
	[id_bhvPiranhaPlantBubble] = true
}

behaviors = {}
models = {}

function gen_tables()

for k, v in pairs(_G) do
    if type(v) == "number" then
      
      
      if k:find("id_bhv") == 1 then
        behaviors[v] = k
      end

      if k:find("E_MODEL_") == 1 then
        models[v] = k
      end
      
    end
  end
end

hook_event(HOOK_ON_MODS_LOADED, gen_tables)

function objectGrabberInit(o)
  o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
  o.oForwardVel = 500
  o.oFaceAngleYaw = -angleYaw + 0x4000
  o.oFaceAnglePitch = -anglePitch - 0x4000
end

function objectGrabberLoop(o)
  o.oTimer = o.oTimer + 1
  
  generate_yellow_sparkles(o.oPosX, o.oPosY, o.oPosZ, 250)
  
  o.oVelX = coss(o.oFaceAngleYaw)*(sins(o.oFaceAnglePitch)*o.oForwardVel)
  o.oVelY = coss(o.oFaceAnglePitch)*(o.oForwardVel)
  o.oVelZ = sins(o.oFaceAngleYaw)*(sins(o.oFaceAnglePitch)*o.oForwardVel)
  
  o.oPosX = o.oPosX + o.oVelX
  o.oPosY = o.oPosY + o.oVelY
  o.oPosZ = o.oPosZ + o.oVelZ
  
  if o.oTimer > 300 then
    obj_mark_for_deletion(o)
  end
 
  local object = obj_get_nearest_object(o, 250)
  if object then
		i = get_id_from_behavior(object.behavior)
		
		object.oFlags = object.oFlags | OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    
    if i ~= id_bhvSparkle and i ~= id_bhvSparkleParticleSpawner and i ~= id_bhvSparkleSpawn then
      obj_mark_for_deletion(o)
      
      local model = obj_get_model_id_extended(object)
      
      AME.grab.bhv = object.behavior
      AME.grab.model = model
      
      AME.grab.obj = object
      AME.grab.pos = {
        x = object.oPosX,
        y = object.oPosY,
        z = object.oPosZ
      }
      AME.spawning = false
      
      if model == E_MODEL_NONE then
        obj_set_model_extended(AME.grab.obj, E_MODEL_ERROR_MODEL)
      end
    end
    
  end
  
end

id_bhvObjectGrabber = hook_behavior(nil, OBJ_LIST_DEFAULT, true, objectGrabberInit, objectGrabberLoop)