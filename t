local repo = 'https://raw.githubusercontent.com/deividcomsono/Obsidian/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()
local Options = Library.Options
local Toggles = Library.Toggles

local MainESP, CullingSystem = loadstring(game:HttpGet(
    'https://raw.githubusercontent.com/Breadido/Main/refs/heads/master/utils/esp/source.lua'))()
MainESP.Options = {
  Enabled = false,
  Bounties = false,
  Box = false,
  Health = false,
  Tracer = false,
  TracerOrigin = "Bottom",
  Name = false,
  Distance = false,
  Direction = false,
  Skeleton = false,
  TextOutline = false,
  Color = Color3.new(1, 1, 1),
  UseTeamColor = true,
  Rainbow = false,
  Font = 1,
  FontSize = 15,
  TeamCheck = false,
  BoxThickness = 0,
  TracerThickness = 0,
  DirectionThickness = 0,
  SkeletonThickness = 0,
}

CullingSystem.maxRenderDistance = 20000
CullingSystem.nearDistance = 10000
CullingSystem.farDistance = 15000

Library:Notify("Loading...", 3)

local setclipboard = setclipboard or toclipboard or set_clipboard or nil
local setthreadcontext = setthreadidentity or set_thread_identity or setthreadcontext or set_thread_context or
    function() Library:Notify("missing setthreadidentity/sethreadcontext") end
local firesignal = firesignal or function() Library:Notify("missing firesignal") end

local workspace = game:GetService("Workspace")
local replicatedstorage = game:GetService("ReplicatedStorage")

configs = {
  player = {
    fspeed = 10,
    ftog = false,
    fx = 0,
    fy = 0,
    fz = 0,
    walktog = false,
    walkval = 0,
    infjump = false,
    respawndeathloc = false,
    nofall = false,
    norag = false,
    noislow = false,
    nosky = false,
    nostun = false,
    nocslow = false,
    nocircwait = false,
    nopwait = false,
    nocwait = false,
    alwayssilentp = false,
    alwaysp = false,
    alwayssp = false,
    juiced = false,
    crawlequip = false,
    backbone = false,
    dogs = {
      dogshephardsp = 50,
      bulldogsp = 40,
      instantleadattack = false,
      alwaysbarking = false,
    },
  },
  vehicle = {
    fspeed = 10,
    ftog = false,
    fx = 0,
    fy = 0,
    fz = 0,
    engine = false,
    enginesp = 0,
    brake = false,
    brakesp = 0,
    suspension = false,
    suspensionhe = 0,
    turnsp = 0,
    turn = false,
    inftrac = false,
    reducebounce = false,
    tirepop = false,
    nopop = false,
    infnitro = false,
    nojumpcd = false,
    rinfnitro = false,
    autoflip = false,
    helibreak = false,
    helienginesp = 0,
    heliverticalsp = 0,
    heliturnsp = 0,
    heliengine = false,
    helipick = false,
    -- helivertical = false;
    -- heliturn = false;
    heliheight = false,
    instanttow = false,
    driveonwater = false,
    tanksus = false,
    tanksushe = 5.3,
    tankengine = false,
    tankenginesp = 0,
    --voltengine = false;
    voltenginesp = 0,
  },
  robbery = {
    bank = {
      disablelasers = false,
    },
    jewelry = {
      disablelasers = false,
    },
    casino = {
      disablelasers = false,
      fixcomputer = false,
      elevatorfloor = 1,
    },
    museum = {
      disablelasers = false,
    },
    tomb = {
      disableplanks = false,
      disablespikes = false,
      disablesdarts = false,
    },
    oilrig = {
      disablelasers = false,
      nooilblow = false,
      disableturret = false,
    },
    cargoship = {
      disableturret = false,
    },
    mansion = {
      disabletraps = false,
      disablelasers = false,
    },
  },
  combat = {
    hitboxradius = 3,
    noequipt = false,
    nospread = false,
    norecoil = false,
    nobulletg = false,
    alwaysauto = false,
    alwaysheadshot = false,
    pistolswat = false,
    snipernoblur = false,
    snipernogui = false,
    wallbang = false,
    nogrenadesmoke = false,
    nogrenadesmokelimit = false,
    tasermodz = false,
    instantrocketseek = false,
    forcefieldnomiss = false,
    increasetakedowndamage = false,
    increaseforcedamage = false,
    forcefieldreload = false,
    shootthroughforce = false,
    instantc4throw = false,
    antic4limit = false,
    instantbullethit = false,
    getweapon = false,
    silentaim = {
      enabled = false,
      targetnpcs = false,
      radius = 50,
      range = 300,
      wallcheck = true,
      fovcirc = false,
      fovthick = 5,
      fovtransp = 0,
    },
    arrestaura = {
      enabled = false,
      showtargeted = false,
    },
    batonsword = {
      noreloadtime = false,
      spamlunge = false,
      spamswoosh = false,
    },
  },
  nametags = {},
  others = {
    disablehometurret = false,
    disablemilitaryturret = false,
    guardnodmg = false,
    opendoor = false,
    prisonelevator = false,
    breakelevator = false,
    disablelaser = false,
    opensewer = false,
  },
}
local client = {
  _guardFolders = {},
  _guardLoop = nil,
  tankdata = {},
  inprogress = false,
  lastvehiclestats = {
    GarageEngineSpeed = nil,
    GarageBrakes = nil,
    Height = nil,
    TurnSpeed = nil,
  },
  lastmotorcyclestats = {
    f = nil,
    Height = nil,
  },
  lastvehiclemodel = nil,
  vehicleEntered = false,
  originalequippeddata = {},
  activeaction = {},
  activel = {},
  simulatedphysicsprojectile = require(game:GetService("ReplicatedStorage").Module.SimulatedPhysicsProjectile),
  guardnpcbinder = require(game:GetService("ReplicatedStorage").GuardNPC.GuardNPCBinder),
  combatconst = require(game:GetService("ReplicatedStorage").Combat.CombatConsts),
  militaryturretconst = require(game:GetService("ReplicatedStorage").Game.MilitaryTurret.MilitaryTurretConsts),
  combatutils = require(game:GetService("ReplicatedStorage").Combat.CombatUtils),
  playerutil = require(game:GetService("ReplicatedStorage").Game.PlayerUtils),
  actionbuttonservice = require(game:GetService("ReplicatedStorage").ActionButton.ActionButtonService),
  settingss = require(game:GetService("ReplicatedStorage").Resource.Settings),
  characterutil = require(game:GetService("ReplicatedStorage").Game.CharacterUtil),
  paraglide = require(game:GetService("ReplicatedStorage").Game.Paraglide),
  alexchassis = require(game:GetService("ReplicatedStorage").Module.AlexChassis),
  alexchassis2 = require(game:GetService("ReplicatedStorage").Module.AlexChassis2),
  dog = require(game:GetService("ReplicatedStorage").Game.Dog.Dog),
  dogconst = require(game:GetService("ReplicatedStorage").Game.Dog.DogConsts),
  dogsystem = require(game:GetService("ReplicatedStorage").Game.Dog.DogSystem),
  itemgun = require(game:GetService("ReplicatedStorage").Game.Item.Gun),
  itemsys = require(game:GetService("ReplicatedStorage").Game.ItemSystem.ItemSystem),
  gunutil = require(game:GetService("ReplicatedStorage").Game.GunShop.GunUtils),
  gamepasssystem = require(game:GetService("ReplicatedStorage").Gamepass.GamepassSystem),
  pistolitem = require(game:GetService("ReplicatedStorage").Game.Item.Pistol),
  smokegrenadeitem = require(game:GetService("ReplicatedStorage").Game.SmokeGrenade.SmokeGrenade),
  movementrollservice = require(game:GetService("ReplicatedStorage").MovementRoll.MovementRollService),
  circleac = require(game:GetService("ReplicatedStorage").Module.UI).CircleAction,
  tase = require(game:GetService("ReplicatedStorage").Game.Item.Taser),
  plasmagun = require(game:GetService("ReplicatedStorage").Game.Item.PlasmaGun),
  geomUtils = require(game:GetService("ReplicatedStorage"):WaitForChild("Std"):WaitForChild("GeomUtils")),
  vehiclelinkbinder = require(game:GetService("ReplicatedStorage").VehicleLink.VehicleLinkBinder),
  duck = require(game:GetService("ReplicatedStorage").Game.Robbery.TombRobbery.TombRobberySystem).duck,
  vehicleutils = require(game:GetService("ReplicatedStorage").Vehicle.VehicleUtils),
  onvehicleentered = require(game:GetService("ReplicatedStorage").Vehicle.VehicleUtils).OnVehicleEntered,
  onvehicleexited = require(game:GetService("ReplicatedStorage").Vehicle.VehicleUtils).OnVehicleExited,
  onlocalitemequipped = require(game:GetService("ReplicatedStorage").Game.ItemSystem.ItemSystem).OnLocalItemEquipped,
  onlocalitemunequipped = require(game:GetService("ReplicatedStorage").Game.ItemSystem.ItemSystem).OnLocalItemUnequipped,
  raycast = require(game:GetService("ReplicatedStorage").Module.RayCast),
  bulletemitter = require(game:GetService("ReplicatedStorage").Game.ItemSystem.BulletEmitter),
  c4 = require(game:GetService("ReplicatedStorage").Game.Item.C4),
  wheel = require(game:GetService("ReplicatedStorage").Module.Wheel.Wheel),
  localization = require(game:GetService("ReplicatedStorage").Module.Localization),
  rocketconsts = require(game:GetService("ReplicatedStorage").RocketLauncher.RocketLauncherConsts),
  dartdispenser = require(game:GetService("ReplicatedStorage").Game.DartDispenser.DartDispenser),
  rocketworld = require(game:GetService("ReplicatedStorage").Game.RocketWorld),
  turret = require(game:GetService("ReplicatedStorage").Turret2.Turret),
  oilrigbinder = require(game:GetService("ReplicatedStorage").OilRig.OilRigBinder)._constructor,
  gunshopui = require(game:GetService("ReplicatedStorage").Game.GunShop.GunShopUI),
  spotlightbinder = require(game:GetService("ReplicatedStorage").TrackingSpotlight.TrackingSpotlightBinder),
  inventoryitemsystem = require(game:GetService("ReplicatedStorage").Inventory.InventoryItemSystem),
  interval = require(game:GetService("ReplicatedStorage").Std.Interval),
  tankbinder = require(game:GetService("ReplicatedStorage").Tank.TankBinder)._constructor,
}

client.ori = {
  hookNearest = client.vehiclelinkbinder._constructor._hookNearest,
  bulletemitteronlocalhitplayer = client.itemgun.BulletEmitterOnLocalHitPlayer,
  hittargetwithspeed = client.simulatedphysicsprojectile.HitTargetWithSpeed,
  isflying = client.paraglide.IsFlying,
  tase = client.tase.Tase,
  doesplayerowncached = client.gamepasssystem.doesPlayerOwnCached,
  update = client.circleac.Update,
  getequiptime = client.gunutil.getEquipTime,
  rayignorenon = client.raycast.RayIgnoreNonCollide,
  plasmashootother = client.plasmagun.ShootOther,
  pistolsetupmodel = client.pistolitem.SetupModel,
  rayignore = client.raycast.RayIgnoreNonCollideWithIgnoreList,
  shoot = client.itemgun.Shoot,
  circleactionpress = client.circleac.Press,
  oillaunchblow = client.oilrigbinder._launchBlowUp,
};

client.rayParamsVehicleEnter = getupvalue(client.alexchassis.VehicleEnter, 17)
client.originalIgnoreWater = client.rayParamsVehicleEnter.IgnoreWater

client.tagfuninstance = getupvalue(
  getconnections(game:GetService("CollectionService"):GetInstanceAddedSignal("SewerHatch"))[1].Function, 3)
client.dooraddedsignal = getconnections(game:GetService("CollectionService"):GetInstanceAddedSignal("Door"))[1].Function
-- client.opendoor = getupvalue(getupvalue(client.dooraddedsignal, 2), 4) comment back
client.doors = getupvalue(client.dooraddedsignal, 1)
client.doors.cellz = {}
client.oilexplosion = workspace.OilRig.OpenCloseSignal.Explosion

client.rocketworld.yousuck = (function() end)

client.getnumactivec4 = getupvalue(client.c4.ShootBegin, 4)
client.gethrowablesmokegrenade = getupvalue(
  require(game:GetService("ReplicatedStorage").Game.Item.SmokeGrenade).ShootBegin, 1)
client.getnearestplayer = getupvalue(require(game:GetService("ReplicatedStorage").Home.HomeItem.Fabricate.Turret).setup,
  12)
client.motorupdatewheel = getupvalue(client.alexchassis2.UpdateHQ, 16)
client.circleupdateui = getupvalue(client.circleac.Update, 1)

client.rollratelimiter = getupvalue(client.movementrollservice.attemptRoll, 6)
client.vclasses = client.vehicleutils.Classes
client.ori.heliupdate = client.vclasses.Heli.Update
client.ori.voltupdate = client.vclasses.Volt.Update
client.ori.chassisupdate = client.vclasses.Chassis.UpdateEngine

setreadonly(client.combatconst, isreadonly(client.combatconst) and false)
setreadonly(client.militaryturretconst, isreadonly(client.militaryturretconst) and false)
setreadonly(client.dogconst, isreadonly(client.dogconst) and false)
setreadonly(client.rocketconsts, isreadonly(client.rocketconsts) and false)
setconstant(client.motorupdatewheel, 17, "die")

for i, v in next, client.ori do
  client.ori[i] = clonefunction(v)
end

for i, v in next, getgc() do
  if type(v) == "function" and islclosure(v) then
    local infoname = tostring(getinfo(v).name)
    local constants = getconstants(v)

    if tostring(getfenv(v).script) == "LocalScript" then
      if table.find(constants, "StartRagdolling") then
        client.stunnedragdoll = v
      end
      if table.find(constants, "PlusCash") then
        client.cashthingy = v
      end
      if infoname == "HasPerm" then
        client.hasperm = v
        client.ori.hasperm = v
      end
      if infoname == "AttemptArrest" then
        client.attemptarrest = v
      end
      if infoname == "UpdatePlayer" then
        client.updateplayer = v
      end
      if infoname == "StartNitro" then
        client.startnitro = v
        client.nitro = getupvalue(v, 8)
      end
      if infoname == "StopNitro" then
        client.stopnitro = v
      end
      if infoname:find("CheatCheck") then
        hookfunction(v, function() end)
      end
    end
  end
end

if getfenv(v).script == game:GetService("ReplicatedStorage").Std.Binder and infoname == "" and getupvalues(v)[1] and type(getupvalues(v)[1]) == "table" then
  local upvalue = getupvalue(v, 1)
  if typeof(upvalue) == "table" and upvalue._tagName == "BarbedWireClient" then
    client.barbedwireclient = upvalue
  end
end

for i, v in next, getconnections(game:GetService("RunService").Heartbeat) do
  if v.Function and islclosure(v.Function) then
    if getconstants(v.Function)[13] == "Time/UI" then
      client.walkspeedfun = getupvalue(v.Function, 6)
    end
    if getconstants(v.Function)[4] == "LQVehicle Heartbeat" then
      setconstant(v.Function, 27, "plzdie")
      setconstant(v.Function, 28, "plzdie")
    end
  end
end

for i, v in next, client.actionbuttonservice.active do
  if table.find(v.keyCodes, Enum.KeyCode.V) then
    client.activeaction.flip = v
  end
  if table.find(v.keyCodes, Enum.KeyCode.LeftControl) then
    client.activeaction.roll = v
  end
end

for i, v in next, client.doors do
  if v.Model and v.Model.Parent.Name == "Cell" then
    table.insert(client.doors.cellz, v)
  end
end

local itemConfigClone = game:GetService("ReplicatedStorage").Game.ItemConfig:Clone()
itemConfigClone.Name = "ItemConfigBackup"

local Circle = MainESP.CreateCircle()
Circle.Radius = configs.combat.silentaim.radius
Circle.Color = Color3.fromRGB(255, 255, 255)
Circle.Position = MainESP.TracerOrigins.Middle
Circle.NumSides = 500

local CircleOutline = MainESP.CreateCircle()
CircleOutline.Radius = configs.combat.silentaim.radius + 2
CircleOutline.Color = Color3.fromRGB(0, 0, 0)
CircleOutline.Filled = false
CircleOutline.Visible = false
CircleOutline.Position = MainESP.TracerOrigins.Middle
CircleOutline.NumSides = 500

local CircleFilled = MainESP.CreateCircle()
CircleFilled.Radius = configs.combat.silentaim.radius - 1
CircleFilled.Color = Color3.fromRGB(0, 0, 0)
CircleFilled.Filled = true
CircleFilled.Visible = false
CircleFilled.Transparency = 0.5
CircleFilled.Position = MainESP.TracerOrigins.Middle
CircleFilled.NumSides = 500

client.getremotekeyfromdecompiledsource = (function(decompiledstr, keytabletoremove)

  local strkey = {}
  for i, v in ipairs(string.split(decompiledstr, "\n")) do
    if string.find(v, ":FireServer", 0) then
      local currentstr = string.gsub(string.gsub(tostring(v), ":FireServer", ""), " ", "")
      for i2, v2 in next, keytabletoremove do
        currentstr = string.gsub(currentstr, v2, "")
      end
      strkey[#strkey + 1] = loadstring("return" .. currentstr:sub(2, currentstr:len() - 1))()
    end
  end
  return strkey
end)

client.ispc = (function()
  local UserInputService = game:GetService("UserInputService")
  if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not UserInputService.MouseEnabled then
    return false
  elseif not UserInputService.TouchEnabled and UserInputService.KeyboardEnabled and UserInputService.MouseEnabled then
    return true
  end
  return false
end)

client.duckLoop = (function()
  repeat
    client.duck()
    task.wait(2)
  until configs.player.backbone == false
end)
client.flipLoop = (function()
  repeat
    task.wait(.0001)
    pcall(function()
      for i, v in next, client.actionbuttonservice.active do
        if table.find(v.keyCodes, Enum.KeyCode.V) then
          v.onPressed(true)
        end
      end
    end)
  until configs.vehicle.autoflip == false
end)
client.smokeGrenadeHook = (function(boolean)
  if boolean then
    hookfunction(client.smokegrenadeitem._playExplosionFx, function() end)
  else
    if isfunctionhooked(client.smokegrenadeitem._playExplosionFx) then
      restorefunction(client.smokegrenadeitem
        ._playExplosionFx)
    end
  end
end)
client.getNearestPlayerHook = (function(boolean)
  if boolean then
    hookfunction(client.getnearestplayer, function() return nil end)
  else
    if isfunctionhooked(client.getnearestplayer) then restorefunction(client.getnearestplayer) end
  end
end)
client.isCrawlingLoop = (function()
  repeat
    task.wait(.1)
    if client.characterutil.IsCrawling then
      client.characterutil.IsCrawling = false
    end
  until configs.player.crawlequip == false
end)
client.setnpcignorelp = (function(a)
  for i, v in next, getupvalue(client.itemsys.GetEquipped, 1) do
    if v.Character and v.BulletEmitter and v.BulletEmitter.IgnoreGuards then
      v.BulletEmitter.IgnoreLocalPlayer = a
    end
  end
end)
client.npcnodamageloop = (function()
  repeat
    task.wait(0.1)
    client.setnpcignorelp(false)
  until configs.others.guardnodmg == false
end)
client.nitroLoop = function()
    local RunService = game:GetService("RunService")
    local nitro = nil

    for _, v in pairs(getgc(true)) do
        if type(v) == "table" 
        and rawget(v, "Nitro") 
        and rawget(v, "NitroLastMax") then
            nitro = v
            break
        end
    end

    assert(nitro, "nitro table not found")

    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not configs.vehicle.infnitro then
            connection:Disconnect()
            return
        end
        nitro.NitroLastMax = 250
        nitro.Nitro = configs.vehicle.rinfnitro and math.random(10, 249) or 249
        nitro.NitroForceUIUpdate = true
    end)
end
client.sprintLoop = (function()
  repeat
    task.wait()
    setupvalue(client.walkspeedfun, 9, true)
  until not configs.player.alwayssp
end)
client.getOldWeaponData = (function(name, dataname)
  return rawget(require(itemConfigClone[name]), dataname)
end)
client.setBatonSwordTime = (function(bool)
  local baton = require(game:GetService("ReplicatedStorage").Game.Item.Baton)
  local sword = require(game:GetService("ReplicatedStorage").Game.Item.Sword)
  getupvalue(baton.new, 2).ReloadTime = bool and 0 or 0.5
  getupvalue(sword.new, 2).ReloadTime = bool and 0 or 0.5
end)
client.spamBatonSwordSwoosh = (function()
  repeat
    task.wait()
    local a = client.itemsys.GetLocalEquipped()
    if a and (a.__ClassName == "Sword" or a.__ClassName == "Baton") then
      require(game:GetService("ReplicatedStorage").Game.Item[a.__ClassName]).SwingSwoosh(a)
    end
  until configs.combat.batonsword.spamswoosh == false
end)
client.spamBatonSwordLunge = (function()
  repeat
    task.wait()
    local a = client.itemsys.GetLocalEquipped()
    if a and (a.__ClassName == "Sword" or a.__ClassName == "Baton") then
      require(game:GetService("ReplicatedStorage").Game.Item[a.__ClassName]).SwingLunge(a)
    end
  until configs.combat.batonsword.spamlunge == false
end)

client.notInWall = (function(pos, ilist, wallCheck)
  if not wallCheck then
    return true
  end
  local workspace = game:GetService("Workspace")
  local camera = workspace.CurrentCamera or nil
  if camera == nil then
    return false
  end
  local direction = (pos - camera.CFrame.Position).Unit * (pos - camera.CFrame.Position).Magnitude
  local rayParams = RaycastParams.new()
  rayParams.FilterType = Enum.RaycastFilterType.Blacklist
  rayParams.FilterDescendantsInstances = ilist or {}
  rayParams.IgnoreWater = true
  local result = workspace:Raycast(camera.CFrame.Position, direction, rayParams)
  return result == nil
end)

client.isEnemies = (function(a, b)
  local a, b = tostring(a), tostring(b)
  if a == "Criminal" and b == "Police" then
    return true
  elseif a == "Criminal" and b == "Prisoner" then
    return false
  elseif a == "Police" and b == "Criminal" then
    return true
  elseif a == "Police" and b == "Prisoner" then
    return false
  elseif a == "Prisoner" and b == "Police" then
    return true
  elseif a == "Prisoner" and b == "Criminal" then
    return false
  end
end)
client.getNearestToCursor = (function()
    local Target = nil
    local notInWall = client.notInWall
    local isEnemies = client.isEnemies
    local middlepos = MainESP.TracerOrigins.Middle
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    for i, v in next, Players:GetPlayers() do
        if isEnemies(LocalPlayer.Team, v.Team) and v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health ~= 0 then
            local magnitude = (LocalPlayer.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).magnitude
            if magnitude <= configs.combat.silentaim.range then
                local Point, OnScreen = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
                local targetPart = v.Character:FindFirstChild("Head") and (v.Character.Head:FindFirstChild("Geo") or v.Character.Head:FindFirstChild("Head_Geo"))
                if not targetPart then
                    targetPart = v.Character.HumanoidRootPart
                end
                local targetPoint, targetOnScreen = Camera:WorldToViewportPoint(targetPart.Position)

                if OnScreen and targetOnScreen and notInWall(targetPart.Position, { LocalPlayer.Character, v.Character }, configs.combat.silentaim.wallcheck) then
                    local Distance = (Vector2.new(targetPoint.X, targetPoint.Y) - Vector2.new(middlepos.X, middlepos.Y)).magnitude
                    if Distance < configs.combat.silentaim.radius then
                        Target = v
                        return Target
                    end
                end
            end
        end
    end

    if configs.combat.silentaim.targetnpcs then
        local npcs = {}
        local mansion = workspace:FindFirstChild("MansionRobbery")
        if mansion then
            local boss = mansion:FindFirstChild("ActiveBoss")
            if boss and boss:FindFirstChild("HumanoidRootPart") and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 then
                table.insert(npcs, { Character = boss, HumanoidRootPart = boss.HumanoidRootPart })
            end
        end

        local drop = workspace:FindFirstChild("Drop")
        if drop then
            local npcsFolder = drop:FindFirstChild("NPCs")
            if npcsFolder then
                for _, npc in ipairs(npcsFolder:GetChildren()) do
                    if npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
                        table.insert(npcs, { Character = npc, HumanoidRootPart = npc.HumanoidRootPart })
                    end
                end
            end
        end

        local oilrig = workspace:FindFirstChild("OilRig")
        if oilrig then
            local guardsFolder = oilrig:FindFirstChild("GuardsFolder")
            if guardsFolder then
                for _, guard in ipairs(guardsFolder:GetChildren()) do
                    if guard:IsA("Model") and guard:FindFirstChild("HumanoidRootPart") and guard:FindFirstChild("Humanoid") and guard.Humanoid.Health > 0 then
                        table.insert(npcs, { Character = guard, HumanoidRootPart = guard.HumanoidRootPart })
                    end
                end
            end
        end

        for _, npc in ipairs(npcs) do
            local magnitude = (LocalPlayer.Character.HumanoidRootPart.Position - npc.HumanoidRootPart.Position).magnitude
            if magnitude <= configs.combat.silentaim.range then
                local Point, OnScreen = Camera:WorldToViewportPoint(npc.HumanoidRootPart.Position)
                local targetPart = npc.Character:FindFirstChild("Head") and (npc.Character.Head:FindFirstChild("Geo") or npc.Character.Head:FindFirstChild("Head_Geo"))
                if not targetPart then
                    targetPart = npc.HumanoidRootPart
                end
                local targetPoint, targetOnScreen = Camera:WorldToViewportPoint(targetPart.Position)

                if OnScreen and targetOnScreen and notInWall(targetPart.Position, { LocalPlayer.Character }, configs.combat.silentaim.wallcheck) then
                    local Distance = (Vector2.new(targetPoint.X, targetPoint.Y) - Vector2.new(middlepos.X, middlepos.Y)).magnitude
                    if Distance < configs.combat.silentaim.radius then
                        Target = { Character = npc.Character, IsNPC = true }
                        return Target
                    end
                end
            end
        end
    end

    return Target
end)
client.getDog = (function()
  for i, v in next, client.dogsystem.getAll() do
    if tostring(client.dog.GetOwner(v)) == game:GetService("Players").LocalPlayer.Name then
      return v
    end
  end
  return nil
end)
client.getPlayerVehicle = (function(plrname)
  local uh = nil
  for i, v in next, game:GetService("CollectionService"):GetTagged("Vehicle") do
    for i2, v2 in next, v:GetChildren() do
      if v2.Name == "Seat" or v2.Name == "Passenger" then
        local whateverSeatName = v2:FindFirstChild("PlayerName")
        if whateverSeatName and whateverSeatName.Value == plrname then
          return uh
        end
      end
    end
  end
  return uh
end)

client.getNearestVehicle = (function()
  local char = game:GetService("Players").LocalPlayer.Character
  local target, distance = nil, 100
  for i, v in next, game:GetService("CollectionService"):GetTagged("Vehicle") do
    if v:FindFirstChild("Seat") or v:FindFirstChild("Passenger") then
      local targetDistance = (char:FindFirstChild("HumanoidRootPart").Position - v:GetModelCFrame().Position).magnitude
      if targetDistance < distance then
        distance = targetDistance
        target = v
      end
    end
  end
  return target
end)

client.getNearestPlayerNoCuffed = (function()
  local maxdistance = 18
  local player = nil;
  for i, v in next, game:GetService("Players"):GetPlayers() do
    if tostring(v.Team) == "Criminal" then
      local character = v.Character or nil
      if character ~= nil and not v.Character:GetAttribute("Handcuffs") then
        local hrp = character:FindFirstChild("Head") or nil
        local hum = character:FindFirstChild("Humanoid") or nil
        if hrp ~= nil and hum ~= nil then
          local mag = (game:GetService("Players").LocalPlayer.Character:GetModelCFrame().Position - hrp.Position)
              .magnitude
          if mag < maxdistance then
            player = v
            if player ~= nil then
              return player
            end
          end
        end
      end
    end
  end
  return false
end)

client.launchArrestAura = (function()
  local getNearestPlayerNoCuffed = client.getNearestPlayerNoCuffed
  repeat
    task.wait(0.15)
    pcall(function()
      local plr = getNearestPlayerNoCuffed()
      if plr then
        client.attemptarrest(game:GetService("Players"):FindFirstChild(tostring(plr)))
        print(game:GetService("Players"):FindFirstChild(tostring(plr)))
      end
    end)
  until configs.combat.arrestaura.enabled == false
end)

client.updateToOriginalChassisStats = (function()
  local gvp = require(game:GetService("ReplicatedStorage").Vehicle.VehicleUtils).GetLocalVehiclePacket()
  if gvp ~= nil and client.lastvehiclestats ~= nil and client.lastvehiclemodel ~= nil and gvp.Model ~= gvp.lastvehiclemodel then
    local stats = client.lastvehiclestats
    if configs.vehicle.engine == false then
      gvp.GarageEngineSpeed = stats.GarageEngineSpeed
    end
    if configs.vehicle.brake == false then
      gvp.GarageBrakes = stats.GarageBrakes
    end
    if configs.vehicle.suspension == false then
      gvp.Height = stats.Height
    end
    if configs.vehicle.turn == false then
      gvp.TurnSpeed = stats.TurnSpeed
    end
  end
end)

client.onHitSurfaceHook = (function()
  local a = client.itemsys.GetLocalEquipped()
  a.FakeName = "Sniper"
  if configs.combat.increasetakedowndamage and a.BulletEmitter ~= nil then
    for i, v in next, getconstants(a.BulletEmitter.OnHitSurface._handlerListHead._fn) do
      if v == "__ClassName" then
        setconstant(a.BulletEmitter.OnHitSurface._handlerListHead._fn, i, "FakeName")
      end
    end
  elseif configs.combat.increasetakedowndamage == false and a.BulletEmitter ~= nil then
    for i, v in next, getconstants(a.BulletEmitter.OnHitSurface._handlerListHead._fn) do
      if v == "FakeName" then
        setconstant(a.BulletEmitter.OnHitSurface._handlerListHead._fn, i, "__ClassName")
      end
    end
  end
end)

client.opendoorloop = (function()
  repeat
    for i, v in next, client.tagfuninstance do
      v["Fun"]()
    end
    task.wait(1.5)
  until configs.others.opendoor == false
end)

client.getprisonelevator = (function()
  for i, v in next, workspace:GetChildren() do
    if v:IsA("Model") and v.Name == "Elevator" and v:FindFirstChild("Car") and v.Car:FindFirstChild("InnerModel") and v.Car.InnerModel:FindFirstChild("Calls") and v.Car.InnerModel.Calls[1]:FindFirstChild("SurfaceGui").TextLabel.Text == "1*" then
      return v
    end
  end
  return nil
end)

client.callprisonelevator = (function(flor)
  pcall(function()
    if client.getprisonelevator() ~= nil then
      fireclickdetector(client.getprisonelevator().Car.InnerModel.Calls[1].ClickDetector)
    end
  end)
end)

client.prisonelevatorloop = (function()
  repeat
    task.wait(0.5)
    client.callprisonelevator(1)
  until configs.others.prisonelevator == false
end)

client.showgunstore = (function()
  setthreadcontext(2)
  client.gunshopui.open()
  setthreadcontext(10)
end)

client.getallgun = (function()
  local grabguns = (function()
    for i, v in next, game:GetService("Players").LocalPlayer.PlayerGui.GunShopGui.Container.Container.Main.Container.Slider:GetChildren() do
      if v.ClassName == "ImageLabel" and v.Bottom.Action.Text == "EQUIP" then
        firesignal(v.Bottom.Action.MouseButton1Down)
      end
    end
  end)
  client.showgunstore()
  for i, v in next, game:GetService("Players").LocalPlayer.PlayerGui.GunShopGui.Container.Container.Sidebar:GetChildren() do
    if v.ClassName == "ImageButton" then
      task.wait()
      for i = 1, 3 do
        grabguns()
      end
      firesignal(v.MouseButton1Down)
    end
  end
  client.gunshopui.close()
end)

client.barbedwiremodify = (function(a)
  local hooklaser = (function()
    for i, v in next, getproto(client.barbedwireclient._constructor, 1, true) do
      hookfunction(v, function()
        return
      end)
    end
  end)
  local unhooklaser = (function()
    for i, v in next, getproto(client.barbedwireclient._constructor, 1, true) do
      if isfunctionhooked(v) then
        restorefunction(v)
      end
    end
  end)
  if a then hooklaser() else unhooklaser() end
end)

client.barbedwireloop = (function()
  repeat
    task.wait(1)
    client.barbedwiremodify(true)
  until configs.others.disablelaser == false
end)

local TouchStorage = workspace:FindFirstChild("Rendex_TouchStorage")
if not TouchStorage then
  TouchStorage = Instance.new("Folder")
  TouchStorage.Name = "Rendex_TouchStorage"
  TouchStorage.Parent = workspace
end

local function disableLaserPart(part, enable, prefix)
  if not part:IsA("BasePart") then return end
  prefix = prefix or ""

  if enable then
    storeOriginal(part, prefix)

    part.Transparency = 0.8
    part.CanTouch = false

    local ti = part:FindFirstChildOfClass("TouchTransmitter") or part:FindFirstChild("TouchInterest")
    if ti then
      ti.Parent = TouchStorage
      part:SetAttribute("Rendex_" .. prefix .. "HasTI", true)
    end
  else
    local origTrans = part:GetAttribute("Rendex_" .. prefix .. "OrigTrans")
    if origTrans ~= nil then part.Transparency = origTrans end
    part:SetAttribute("Rendex_" .. prefix .. "OrigTrans", nil)

    local origCanTouch = part:GetAttribute("Rendex_" .. prefix .. "OrigCanTouch")
    if origCanTouch ~= nil then part.CanTouch = origCanTouch end
    part:SetAttribute("Rendex_" .. prefix .. "OrigCanTouch", nil)

    if part:GetAttribute("Rendex_" .. prefix .. "HasTI") then
      for _, ti in ipairs(TouchStorage:GetChildren()) do
        ti.Parent = part
        break
      end
      part:SetAttribute("Rendex_" .. prefix .. "HasTI", nil)
    end
  end
end

local TouchStorage = workspace:FindFirstChild("Rendex_TouchStorage")
if not TouchStorage then
  TouchStorage = Instance.new("Folder")
  TouchStorage.Name = "Rendex_TouchStorage"
  TouchStorage.Parent = workspace
end

local function storeOriginal(part, prefix)
  prefix = prefix or ""
  if not part:GetAttribute("Rendex_" .. prefix .. "OrigTrans") then
    part:SetAttribute("Rendex_" .. prefix .. "OrigTrans", part.Transparency)
  end
  if not part:GetAttribute("Rendex_" .. prefix .. "OrigCanTouch") then
    part:SetAttribute("Rendex_" .. prefix .. "OrigCanTouch", part.CanTouch)
  end
end

local function disableLaserPart(part, enable, prefix)
  if not part:IsA("BasePart") then return end
  prefix = prefix or ""
  if enable then
    if part.Transparency < 1 then
      storeOriginal(part, prefix)
      part.Transparency = 0.8
    end

    part.CanTouch = false
    local ti = part:FindFirstChildOfClass("TouchTransmitter") or part:FindFirstChild("TouchInterest")
    if ti and ti.Parent == part then
      ti.Parent = TouchStorage
      part:SetAttribute("Rendex_" .. prefix .. "HasTI", true)
    end
  else
    local origTrans = part:GetAttribute("Rendex_" .. prefix .. "OrigTrans")
    if origTrans ~= nil then
      part.Transparency = origTrans
    end
    part:SetAttribute("Rendex_" .. prefix .. "OrigTrans", nil)

    local origCanTouch = part:GetAttribute("Rendex_" .. prefix .. "OrigCanTouch")
    if origCanTouch ~= nil then part.CanTouch = origCanTouch end
    part:SetAttribute("Rendex_" .. prefix .. "OrigCanTouch", nil)

    if part:GetAttribute("Rendex_" .. prefix .. "HasTI") then
      for _, ti in ipairs(TouchStorage:GetChildren()) do
        if ti:IsA("TouchTransmitter") or ti.Name == "TouchInterest" then
          ti.Parent = part
          break
        end
      end
      part:SetAttribute("Rendex_" .. prefix .. "HasTI", nil)
    end
  end
end

local function applyToParts(parts, enable, prefix)
  for _, p in ipairs(parts) do
    disableLaserPart(p, enable, prefix)
  end
end

local function getDescendantsOfClass(inst, class)
  local list = {}
  for _, d in ipairs(inst:GetDescendants()) do
    if d:IsA(class) then table.insert(list, d) end
  end
  return list
end

client.disableBankLasers = function(enabled)
  local Banks = workspace:FindFirstChild("Banks")
  if not Banks then return end

  local allLasers = {}
  for _, bank in ipairs(Banks:GetChildren()) do
    if bank:IsA("Model") and bank:FindFirstChild("Layout") then
      for _, layout in ipairs(bank.Layout:GetChildren()) do
        if layout:FindFirstChild("Lasers") then
          for _, part in ipairs(getDescendantsOfClass(layout.Lasers, "BasePart")) do
            table.insert(allLasers, part)
          end
        end
      end
    end
  end

  applyToParts(allLasers, enabled, "Bank_")
end

client.disableJewelryLasers = function(enabled)
  local Jewelrys = workspace:FindFirstChild("Jewelrys")
  if not Jewelrys then return end

  local allLasers = {}
  local Jewelry = Jewelrys:FindFirstChild("Jewelry")
  if not Jewelry then return end

  local Floors = Jewelry:FindFirstChild("Floors")
  if Floors and Floors:FindFirstChild("Model") then
    local Model = Floors.Model
    local Lasers = Model:FindFirstChild("Lasers")
    if Lasers then
      for _, laser in ipairs(Lasers:GetChildren()) do
        if laser.Name == "Laser" and laser:FindFirstChild("InnerModel") then
          for _, part in ipairs(laser.InnerModel:GetChildren()) do
            if part:IsA("BasePart") then
              table.insert(allLasers, part)
            end
          end
        end
      end
    end
  end

  if Floors and Floors:FindFirstChild("Model") then
    local Model = Floors.Model
    local InteractiveButtonLasers = Model:FindFirstChild("InteractiveButtonLasers")
    if InteractiveButtonLasers then
      for _, laserFloor in ipairs(InteractiveButtonLasers:GetChildren()) do
        if laserFloor.Name == "LaserFloor" then
          for _, child in ipairs(laserFloor:GetChildren()) do
            if child:IsA("BasePart") then
              table.insert(allLasers, child)
            end
          end
        end
      end
    end
  end

  if Floors and Floors:FindFirstChild("Model") then
    local Model = Floors.Model
    for _, part in ipairs(Model:GetChildren()) do
      if part.Name == "Part" and part:IsA("BasePart") then
        local ti = part:FindFirstChildOfClass("TouchTransmitter") or part:FindFirstChild("TouchInterest")
        if ti and ti.Parent == part then
          table.insert(allLasers, part)
        end
      end
    end
  end

  applyToParts(allLasers, enabled, "Jewelry_")
end

client.disableMuseumLasers = function(enabled)
    local Museum = workspace:FindFirstChild("Museum")
    if not Museum then return end

    local Lights = Museum:FindFirstChild("Lights")
    if not Lights then return end

    local allLasers = {}

    for _, spotlightModel in ipairs(Lights:GetChildren()) do
        if spotlightModel.Name == "Spotlight" and spotlightModel:IsA("Model") then
            local lightPart = spotlightModel:FindFirstChild("Light")
            if lightPart and lightPart:IsA("BasePart") then
                table.insert(allLasers, lightPart)
            end
        end
    end

    applyToParts(allLasers, enabled, "Museum_")
end

client.disableCasinoLasers = function(enabled)
  local Casino = workspace:FindFirstChild("Casino")
  if not Casino then return end
  local allLasers = {}

  local carousel = Casino:FindFirstChild("LaserCarousel")
  if carousel and carousel:FindFirstChild("InnerModel") then
    for _, p in ipairs(getDescendantsOfClass(carousel.InnerModel, "BasePart")) do
      table.insert(allLasers, p)
    end
  end

  local lasers = Casino:FindFirstChild("Lasers")
  if lasers then
    for _, p in ipairs(getDescendantsOfClass(lasers, "BasePart")) do
      table.insert(allLasers, p)
    end
  end

  for _, folder in ipairs({ Casino:FindFirstChild("CamerasMoving"), Casino:FindFirstChild("LasersMoving") }) do
    if folder then
      for _, child in ipairs(folder:GetChildren()) do
        local im = child:FindFirstChild("InnerModel")
        if im then
          local part = im:FindFirstChild("Part")
          if part and part:IsA("BasePart") then
            table.insert(allLasers, part)
          end
        end
      end
    end
  end

  local vaultLaserControl = Casino:FindFirstChild("VaultLaserControl")
  if vaultLaserControl then
    for _, laser in ipairs(vaultLaserControl:GetChildren()) do
      if laser.Name == "Laser" and laser:FindFirstChild("InnerModel") then
        local innerModel = laser.InnerModel
        for _, part in ipairs(innerModel:GetChildren()) do
          if part:IsA("BasePart") then
            table.insert(allLasers, part)
          end
        end
      end
    end

    for _, part in ipairs(vaultLaserControl:GetChildren()) do
      if part:IsA("BasePart") and part.Name == "Part" then
        table.insert(allLasers, part)
      end
    end
  end

  applyToParts(allLasers, enabled, "Casino_")
end

client.getcasinoelevator = (function()
  local Casino = workspace:FindFirstChild("Casino")
  if not Casino then return nil end
  local Elevator = Casino:FindFirstChild("Elevator")
  if not Elevator or not Elevator:FindFirstChild("Car") then return nil end
  return Elevator
end)

client.callcasinoelevator = (function(floor)
  pcall(function()
    local elevator = client.getcasinoelevator()
    if elevator and elevator.Car and elevator.Car.InnerModel and elevator.Car.InnerModel.Calls then
      local callButton = elevator.Car.InnerModel.Calls[tostring(floor)]
      if callButton and callButton:FindFirstChild("ClickDetector") then
        fireclickdetector(callButton.ClickDetector)
      end
    end
  end)
end)

client.casinoelevatorloop = (function()
  repeat
    task.wait(0.1)
    local elevator = client.getcasinoelevator()
    if elevator and elevator.Car and elevator.Car.InnerModel and elevator.Car.InnerModel.Calls then
      local callButton = elevator.Car.InnerModel.Calls["4"]
      if callButton and callButton:FindFirstChild("ClickDetector") then
        fireclickdetector(callButton.ClickDetector)
      end
    end
  until configs.others.breakelevator == false
end)

client.disableOilRigLasers = function(enabled)
  local oilRig = workspace:FindFirstChild("OilRig")
  if not oilRig then return end

  local allLasers = {}
  local movingLasers = oilRig:FindFirstChild("MovingLasers")

  if movingLasers then
    for _, laser in ipairs(movingLasers:GetChildren()) do
      if laser.Name == "Laser" and laser:FindFirstChild("InnerModel") then
        local part = laser.InnerModel:FindFirstChild("Part")
        if part and part:IsA("BasePart") then
          table.insert(allLasers, part)
        end
      end
    end
  end

  applyToParts(allLasers, enabled, "OilRig_")
end

client.disableTombPlanks = function(enabled)
  local tomb = workspace:FindFirstChild("RobberyTomb")
  if not tomb or not tomb:FindFirstChild("Cart") then return end
  local planks = tomb.Cart:FindFirstChild("Planks")
  if not planks then return end

  local allPlanks = {}

  for _, child in ipairs(planks:GetChildren()) do
    if child.Name == "Wood" and child:IsA("BasePart") then
      table.insert(allPlanks, child)
    end
  end

  applyToParts(allPlanks, enabled, "TombPlank_")
end

client.disableTombSpikes = function(enabled)
  local tomb = workspace:FindFirstChild("RobberyTomb")
  if not tomb or not tomb:FindFirstChild("SpikeRoom") then return end
  local spikes = tomb.SpikeRoom:FindFirstChild("Spikes")
  if not spikes then return end

  for i = 1, 11 do
    local spike = spikes:FindFirstChild(tostring(i))
    if spike then
      local tiles = {}
      for _, child in ipairs(spike:GetChildren()) do
        if child.Name == "Tile" and child:IsA("Model") then
          table.insert(tiles, child)
        end
      end

      for _, tile in ipairs(tiles) do
        if tile:FindFirstChild("Model") then
          local model = tile.Model
          local innerModel = model:FindFirstChild("InnerModel")

          if innerModel then
            local door = innerModel:FindFirstChild("Door")
            if door and door:IsA("BasePart") then
              storeOriginal(door, "TombSpike_")
              if enabled then
                door.CanTouch = false
                local ti = door:FindFirstChildOfClass("TouchTransmitter") or door:FindFirstChild("TouchInterest")
                if ti and ti.Parent == door then
                  ti.Parent = TouchStorage
                  door:SetAttribute("Rendex_TombSpike_HasTI", true)
                end
              else
                local origCanTouch = door:GetAttribute("Rendex_TombSpike_OrigCanTouch")
                if origCanTouch ~= nil then door.CanTouch = origCanTouch end
                door:SetAttribute("Rendex_TombSpike_OrigCanTouch", nil)

                if door:GetAttribute("Rendex_TombSpike_HasTI") then
                  for _, ti in ipairs(TouchStorage:GetChildren()) do
                    if (ti:IsA("TouchTransmitter") or ti.Name == "TouchInterest") then
                      ti.Parent = door
                      break
                    end
                  end
                  door:SetAttribute("Rendex_TombSpike_HasTI", nil)
                end
              end
            end

            local spikePart = innerModel:FindFirstChild("Spikes")
            if spikePart and spikePart:IsA("BasePart") then
              storeOriginal(spikePart, "TombSpike_Visibility")
              if enabled then
                spikePart.Transparency = 0.8
              else
                local origTrans = spikePart:GetAttribute("Rendex_TombSpike_Visibility_OrigTrans")
                if origTrans ~= nil then spikePart.Transparency = origTrans end
                spikePart:SetAttribute("Rendex_TombSpike_Visibility_OrigTrans", nil)
              end
            end
          end
        end
      end
    end
  end
end

client._tombDartsDisabled = false

local mt = getrawmetatable(game)
setreadonly(mt, false)

local old = mt.__namecall

mt.__namecall = newcclosure(function(self, ...)
  local method = getnamecallmethod()

  if client._tombDartsDisabled then
    if method == "FireServer" and self.Name == "DartDamage" then
      return
    end

    if (method == "FireClient" or method == "FireAllClients") and self.Name == "DartFire" then
      return
    end
  end

  return old(self, ...)
end)

setreadonly(mt, true)

function client.disableTombDarts(enabled)
  client._tombDartsDisabled = enabled
end

client.fixCasinoComputerLoop = (function()
  repeat
    local Casino = workspace:FindFirstChild("Casino")
    if not Casino or not Casino:FindFirstChild("Computers") then
      task.wait(0.1)
      continue
    end
    for _, computer in ipairs(Casino.Computers:GetChildren()) do
      if computer:FindFirstChild("CasinoComputerHack") then
        computer.CasinoComputerHack:FireServer()
      end
    end
    task.wait(0.1)
  until configs.robbery.casino.fixcomputer == false
end)

client.disableMansionLasers = function(enabled)
    local MansionRobbery = workspace:FindFirstChild("MansionRobbery")
    if not MansionRobbery then return end

    local LasersParent = MansionRobbery:FindFirstChild("Lasers")
    if not LasersParent then return end

    local allLasers = {}
    for i = 1, 7 do
        local doorNumber = LasersParent:FindFirstChild(tostring(i))
        if doorNumber then
            local doorModel = doorNumber:FindFirstChild("Door")
            if doorModel then
                local innerModel = doorModel:FindFirstChild("InnerModel")
                if innerModel then
                    local laserPart = innerModel:FindFirstChild("Laser")
                    if laserPart and laserPart:IsA("BasePart") then
                        table.insert(allLasers, laserPart)
                    end
                end
            end
        end
    end
    applyToParts(allLasers, enabled, "Mansion_Laser_")
end

client.disableMansionTraps = function(enabled)
    local MansionRobbery = workspace:FindFirstChild("MansionRobbery")
    if not MansionRobbery then return end

    local LaserTraps = MansionRobbery:FindFirstChild("LaserTraps")
    if not LaserTraps then return end

    local allTrapLasers = {}
    local trapModel = LaserTraps:FindFirstChild("Trap")
    if trapModel then
        local trapLasers = trapModel:FindFirstChild("Lasers")
        if trapLasers then
            for _, part in ipairs(trapLasers:GetChildren()) do
                if part.Name == "Part" and part:IsA("BasePart") then
                    table.insert(allTrapLasers, part)
                end
            end
        end
    end
    applyToParts(allTrapLasers, enabled, "Mansion_Trap_")

    local allTrapButtons = {}
    local trapButtons = trapModel and trapModel:FindFirstChild("Buttons")
    local trapButtonModel = trapButtons and trapButtons:FindFirstChild("TrapButton")
    if trapButtonModel then
        local innerModel = trapButtonModel:FindFirstChild("InnerModel")
        if innerModel then
            local touchPart = innerModel:FindFirstChild("Touch")
            if touchPart and touchPart:IsA("BasePart") then
                table.insert(allTrapButtons, touchPart)
            end
        end
    end
    applyToParts(allTrapButtons, enabled, "Mansion_Trap_Button_")
end

client.disableGuards = function(enabled)
  local ReplicatedStorage = game:GetService("ReplicatedStorage")
  local CollectionService = game:GetService("CollectionService")

  local NPCConsts = require(ReplicatedStorage.NPC.NPCConsts)
  local BossNPCConsts = require(ReplicatedStorage.MansionRobbery.BossNPCConsts)
  local GuardNPCConsts = require(ReplicatedStorage.GuardNPC.GuardNPCConsts)
  local BossNPCUtils = require(ReplicatedStorage.MansionRobbery.BossNPCUtils)

  if enabled then
    for _, npc in pairs(CollectionService:GetTagged(BossNPCConsts.TAG_NAME)) do
      pcall(function()
        BossNPCUtils.setAttackState(npc, BossNPCConsts.ATTACK_STATE.None)
      end)
    end

    for _, npc in pairs(CollectionService:GetTagged(GuardNPCConsts.TAG_NAME)) do
      pcall(function()
        npc:SetAttribute(NPCConsts.DEST_TYPE_ATTR_NAME, NPCConsts.DEST_TYPE.IDLE)
        npc:SetAttribute(GuardNPCConsts.TARGET_TYPE_ATTR_NAME, "IDLE")
        npc:SetAttribute(GuardNPCConsts.MAX_SHOOT_DIST_ATTR_NAME, 0)
        npc:SetAttribute(GuardNPCConsts.IS_DOCILE_ATTR_NAME, false)
      end)
    end

    for _, npc in pairs(CollectionService:GetTagged(NPCConsts.TAG_NAME)) do
      pcall(function()
        npc:SetAttribute(NPCConsts.DEST_TYPE_ATTR_NAME, NPCConsts.DEST_TYPE.IDLE)
      end)
    end
  else
    for _, npc in pairs(CollectionService:GetTagged(BossNPCConsts.TAG_NAME)) do
      pcall(function()
        BossNPCUtils.setAttackState(npc, BossNPCConsts.ATTACK_STATE.LockedNone)
      end)
    end

    for _, npc in pairs(CollectionService:GetTagged(GuardNPCConsts.TAG_NAME)) do
      pcall(function()
        npc:SetAttribute(GuardNPCConsts.TARGET_TYPE_ATTR_NAME, "DEFAULT")
        npc:SetAttribute(NPCConsts.DEST_TYPE_ATTR_NAME, NPCConsts.DEST_TYPE.POS)
        npc:SetAttribute(GuardNPCConsts.MAX_SHOOT_DIST_ATTR_NAME, GuardNPCConsts.MAX_SHOOT_DIST)
        npc:SetAttribute(GuardNPCConsts.IS_DOCILE_ATTR_NAME, true)
      end)
    end

    for _, npc in pairs(CollectionService:GetTagged(NPCConsts.TAG_NAME)) do
      pcall(function()
        npc:SetAttribute(NPCConsts.DEST_TYPE_ATTR_NAME, NPCConsts.DEST_TYPE.POS)
      end)
    end
  end
end

client.disableMilitaryTurrets = function(state)
  if state then
    client.militaryturretconst.FIRE_RATE = math.huge
  else
    client.militaryturretconst.FIRE_RATE = 1
  end
end

client.opensewerhatch = (function()
  for i, v in next, client.tagfuninstance do
    if v["_DEBUG"] == "SewerHatch" then
      v["Fun"]()
    end
  end
end)

client.oepnsewerloop = (function()
  repeat
    task.wait(0.05)
    client.opensewerhatch()
  until configs.others.opensewer == false
end)

client.dropall = (function()
  for i, v in next, client.inventoryitemsystem.getInventoryItemsFor(game:GetService("Players").LocalPlayer) do
    local ignore = { "Bag", "Crate", "Gem", "Taser", "Handcuffs", "RoadSpike", "MansionInvite" }
    if not table.find(ignore, v.obj.Name) then
      v:AttemptSetEquipped(true)
      v:AttemptDrop()
    end
  end
end)

client.deathtp = (function(cframe)
  game:GetService("Players").LocalPlayer.Character:FindFirstChild("Humanoid").Health = 0
  repeat
    task.wait()
  until game:GetService("Players").LocalPlayer.Character and game:GetService("Players").LocalPlayer.Character:FindFirstChild("Humanoid") and game:GetService("Players").LocalPlayer.Character:FindFirstChild("Humanoid").Health > 0
  local Timeout = os.time()
  repeat
    game:GetService("Players").LocalPlayer.Character:PivotTo(CFrame.new(cframe.Position))
    task.wait()
  until os.time() - Timeout > 1
  client.inprogress = false
end)

client.openclosedcell = (function()
  for i, v in next, client.doors.cellz do
    if v.State.Open == false then
      v.State.Open = true
      v:OpenFun()
    end
  end
end)

client.cellloop = (function()
  repeat
    task.wait(0.1)
    client.openclosedcell()
  until configs.player.nocwait == false
end)

task.spawn(function()
  hookfunction(getcallbackvalue(game:GetService("ReplicatedStorage").HawkeyeRemoteFunction, "OnClientInvoke"),
    function()
  end)

  client.simulatedphysicsprojectile.HitTargetWithSpeed = (function(...)
    local args = { ... }
    if configs.combat.forcefieldnomiss and args[3] == 75 then
      args[3] = 1
    end
    return client.ori.hittargetwithspeed(unpack(args))
  end)

  client.itemgun.BulletEmitterOnLocalHitPlayer = (function(...)
    local args = { ... }
    if configs.combat.alwaysheadshot then
      args[15].isHeadshot = true
      args[15].isWallbang = false
    end
    return client.ori.bulletemitteronlocalhitplayer(unpack(args))
  end)

  client.itemgun.Shoot = (function(self, a)
    if configs.combat.silentaim.enabled then
      local character = client.getNearestToCursor() and client.getNearestToCursor().Character
      local hrp = character and character:FindFirstChild("HumanoidRootPart")
      if hrp then
        self.TipDirection = (hrp.Position - self.Tip.Position).Unit
      end
    end
    local oldLastUpdate = self.BulletEmitter.LastUpdate
    local oldignorelist = self.BulletEmitter.IgnoreList
    self.BulletEmitter.LastUpdate = configs.combat.instantbullethit and -9e9 or oldLastUpdate
    self.BulletEmitter.IgnoreList = configs.combat.wallbang and { workspace } or oldignorelist
    client.ori.shoot(self, a)
  end)

  client.plasmagun.ShootOther = (function(self, a)
    if configs.combat.silentaim.enabled and configs.combat.silentaim.includeplasma then
      local character = client.getNearestToCursor() and client.getNearestToCursor().Character
      local hrp = character and character:FindFirstChild("HumanoidRootPart")
      if hrp then
        self.TipDirection = (hrp.Position - self.Tip.Position).Unit
      end
    end
    client.ori.plasmashootother(self, a)
  end)

  client.tase.Tase = (function(self, ...)
    if configs.combat.tasermodz then
      self._lastDraw = 0
    end
    return client.ori.tase(self, ...)
  end)

  client.raycast.RayIgnoreNonCollideWithIgnoreList = (function(...)
    if debug.traceback():find("Taser") and configs.combat.silentaim.enabled and configs.combat.silentaim.includetaser then
      local character = client.getNearestToCursor() and client.getNearestToCursor().Character
      local hrp = character and character:FindFirstChild("HumanoidRootPart")
      if hrp then
        return hrp, hrp.Position, hrp.Position,
            ...
      end
    end
    return client.ori.rayignore(...)
  end)

  do
    local originalVehicleEnter = client.alexchassis.VehicleEnter
    client.ori.alexchassisvehicleenter = originalVehicleEnter

    client.alexchassis.VehicleEnter = function(self, ...)
      local result = originalVehicleEnter(self, ...)

      if configs.vehicle.driveonwater then
        local upvalue17 = getupvalue(originalVehicleEnter, 17)
        if upvalue17 and upvalue17.IgnoreWater ~= nil then
          upvalue17.IgnoreWater = false
        end
      end

      return result
    end
  end

  client.gamepasssystem.doesPlayerOwnCached = (function(...)
    local args = { ... }
    if configs.combat.pistolswat and tostring(args[1]) == game:GetService("Players").LocalPlayer.Name and debug.traceback():find("tem.Pistol") then
      return true
    end
    return client.ori.doesplayerowncached(...)
  end)

  client.gunutil.getEquipTime = (function(...)
    return configs.combat.noequipt and 0 or client.ori.getequiptime(...)
  end)

  client.paraglide.IsFlying = (function(...)
    return configs.player.nosky and debug.traceback():find("Falling") and true or client.ori.isflying(...)
  end)

  client.vehiclelinkbinder._constructor._hookNearest = (function(...)
    local args = { ... }
    local rope = args[1].obj
    local obj = args[1].nearestObj
    local requestLink = args[1].manifest.reqLinkRemote
    if configs.vehicle.helipick and rope.Name == "RopePull" then
      local cf = obj.PrimaryPart.CFrame:PointToObjectSpace(
        client.geomUtils.closestPointInPart(obj.PrimaryPart, rope.Position), rope.Position)
      requestLink:FireServer(obj, cf)
      return
    elseif configs.vehicle.instanttow and rope.Name == "MetalHook" then
      local cf = obj.PrimaryPart.CFrame:PointToObjectSpace(
        client.geomUtils.closestPointInPart(obj.PrimaryPart, rope.Position), rope.Position)
      requestLink:FireServer(obj, cf)
      return
    end
    return client.ori.hookNearest(...)
  end)

  client.vclasses.Heli.Update = (function(self, ...)
    --Vector3.new(configs.vehicle.helienginesp, configs.vehicle.heliverticalsp, configs.vehicle.helienginesp)
    client.ori.heliupdate(self, ...)
    if configs.vehicle.heliengine then
      self.Velocity.Velocity *= Vector3.new(configs.vehicle.helienginesp, configs.vehicle.heliverticalsp,
        configs.vehicle.helienginesp)
      --self.Rotate.AngularVelocity *= Vector3.new(configs.vehicle.heliturnsp, configs.vehicle.heliturnsp, configs.vehicle.heliturnsp)
    end
  end)

  client.ori.voltupdate = client.vclasses.Volt.Update
  client.vclasses.Volt.Update = function(volt)
    client.ori.voltupdate(volt)

    --Vector3.new(configs.vehicle.helienginesp, configs.vehicle.heliverticalsp, configs.vehicle.helienginesp)
    volt.Force.Force = volt.Force.Force * (1 + configs.vehicle.voltenginesp)
    --if configs.vehicle.voltengine then
    --self.Rotate.AngularVelocity *= Vector3.new(configs.vehicle.heliturnsp, configs.vehicle.heliturnsp, configs.vehicle.heliturnsp)
    --end
  end

  local blacklistedaction = {
    "Rob",
    "Hack",
    "Open Crate",
    "Break In",
    "Pull Lever",
    "Place TNT",
    "Switch",
    "Crack",
    "Change Direction"
  }
  client.circleac.Press = (function()
    local spec = getupvalue(client.ori.circleactionpress, 1).Spec
    if configs.player.nocircwait and spec and not table.find(blacklistedaction, spec.Name) then
      spec:Callback(true)
    end
    return client.ori.circleactionpress()
  end)

  client.oilrigbinder._launchBlowUp = (function(a)
    if configs.robberies.nooilblow then
      return
    end
    return client.ori.oillaunchblow(a)
  end)

  game:GetService("Players").LocalPlayer:GetMouse().Move:Connect(function()
    if client.ispc() then
      local Mouse = game:GetService "UserInputService":GetMouseLocation()
      Circle.Position = Vector2.new(Mouse.X, Mouse.Y)
      CircleFilled.Position = Vector2.new(Mouse.X, Mouse.Y)
      CircleOutline.Position = Vector2.new(Mouse.X, Mouse.Y)
    end
  end)

  if game:GetService("Players").LocalPlayer.Character and game:GetService("Players").LocalPlayer.Character:FindFirstAncestorOfClass("Humanoid") then
    game:GetService("Players").LocalPlayer.Character.Humanoid.Died:Connect(function(a)
      --local celltime = game:GetService("Players").LocalPlayer.PlayerGui.MainGui.CellTime
      if client.inprogress == false and configs.player.respawndeathloc then
        client.inprogress = true
        local cf = game:GetService("Players").LocalPlayer.Character:GetModelCFrame()
        -- if celltime.Visible then
        -- 	print("waiting for your cell to be opened, please wait")
        -- 	repeat task.wait() until celltime.Visible == false
        -- end
        client.deathtp(cf)
      end
    end)
  end

  game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function(a)
    local hrp = game:GetService("Players").LocalPlayer.Character:WaitForChild("HumanoidRootPart")
    if hrp then
      if configs.player.nofall then
        hrp:AddTag("NoFallDamage")
      end
      if configs.player.norag then
        hrp:AddTag("NoRagdoll")
      end
    end
    if configs.combat.getweapon then
      task.delay(0.1, function()
        client.getallgun()
      end)
    end
    repeat task.wait() until a:FindFirstChildOfClass("Humanoid")
    task.wait(0.1)
    a.Humanoid.Died:Connect(function(a)
      -- local celltime = game:GetService("Players").LocalPlayer.PlayerGui.MainGui.CellTime
      if client.inprogress == false and configs.player.respawndeathloc then
        client.inprogress = true
        local cf = game:GetService("Players").LocalPlayer.Character:GetModelCFrame()
        -- if celltime.Visible then
        -- 	print("waiting for your cell to be opened, please wait")
        -- 	repeat task.wait() until celltime.Visible == false
        -- end
        client.deathtp(cf)
      end
    end)
    --[[
      task.wait(0.1)
      for i,v in next, getconnections(game:GetService("Players").LocalPlayer.Character.Humanoid.StateChanged) do -- useless
        if v.Function ~= nil and tostring(getfenv(v.Function).script) == "LocalScript" then
          setconstant(v.Function, 2, "EasingStyle") -- i did this cuz it's funni :>
          setconstant(v.Function, 3, "Linear")
        end
      end
      --]]
  end)
  game:GetService("UserInputService").JumpRequest:Connect(function()
    if configs.player.infjump then
      game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
  end)
  game.Lighting.ChildAdded:connect(function(mama)
    if configs.combat.snipernoblur and mama.Name == "Blur" then
      mama:GetPropertyChangedSignal("Size"):connect(function()
        mama.Enabled = false
      end)
    end
  end)
  client.onvehicleentered:Connect(function(arg1)
    client.vehicleEntered = true
    if arg1.Model ~= client.lastvehiclemodel and arg1.Type == "Chassis" then
      client.lastvehiclemodel = arg1.Model
      client.lastvehiclestats.GarageEngineSpeed = arg1.GarageEngineSpeed
      client.lastvehiclestats.GarageBrakes = arg1.GarageBrakes
      client.lastvehiclestats.TurnSpeed = arg1.TurnSpeed
      client.lastvehiclestats.Height = arg1.Height
    end
    if configs.vehicle.ftog then
      client.launchVehicleFlight()
    end
    if arg1.Type == "Heli" then
      arg1.MaxHeight = configs.vehicle.heliheight and 9e9 or 400
      arg1.FallOutOfSkyDuration = configs.vehicle.helibreak and 0 or 10
      arg1.DisableDuration = configs.vehicle.helibreak and 0 or 10
    elseif arg1.Type == "Chassis" then
      arg1.TirePopDuration = configs.vehicle.nopop and 0 or 7.5
      arg1.DisableDuration = configs.vehicle.nopop and 0 or 7.5
      arg1.TirePopProportion = configs.vehicle.nopop and 0 or 0.5
    end
  end)
  client.onvehicleexited:Connect(function()
    client.vehicleEntered = false
  end)
  client.onlocalitemequipped:Connect(function(equippeddata)
    --client.originalequippeddata = equippeddata
    local getdata = client.getOldWeaponData
    local a = client.itemsys.GetLocalEquipped()
    a.FakeName = "Sniper"
    task.spawn(function()
      client.onHitSurfaceHook()
    end)
    if getdata(a.__ClassName, "FireAuto") ~= nil then
      a.Config.FireAuto = configs.combat.alwaysauto and true or getdata(a.__ClassName, "FireAuto")
    end
    if getdata(a.__ClassName, "BulletSpread") ~= nil then
      a.Config.BulletSpread = configs.combat.nospread and 0 or getdata(a.__ClassName, "BulletSpread")
    end
    if getdata(a.__ClassName, "CamShakeMagnitude") ~= nil then
      a.Config.CamShakeMagnitude = configs.combat.norecoil and 0 or getdata(a.__ClassName, "CamShakeMagnitude")
    end
    if a.__ClassName == "Taser" and getdata(a.__ClassName, "ReloadTimeHit") ~= nil and getdata(a.__ClassName, "ReloadTime") ~= nil then
      a.Config.ReloadTimeHit = configs.combat.tasermodz and 0 or getdata(a.__ClassName, "ReloadTimeHit")
      a.Config.ReloadTime = configs.combat.tasermodz and 0 or getdata(a.__ClassName, "ReloadTime")
    end
    if a and a.BulletEmitter and a.BulletEmitter.GravityVector then
      a.BulletEmitter.GravityVector = configs.combat.nobulletg and nil or Vector3.new(0, -workspace.Gravity / 10, 0)
    end
    if a.__ClassName == "ForcefieldLauncher" then
      a.Config.Reload = configs.combat.forcefieldreload and 0 or 4
    end
  end)

  task.spawn(function()
    while true do
      task.wait(.1)
      pcall(function()
        local humanoid = game:GetService("Players").LocalPlayer.Character.Humanoid or nil
        local gvp = require(game:GetService("ReplicatedStorage").Vehicle.VehicleUtils).GetLocalVehiclePacket() or nil
        if humanoid ~= nil and gvp ~= nil and client.vehicleEntered then
          if gvp.Type == "Chassis" then
            if configs.vehicle.engine then
              gvp.GarageEngineSpeed = configs.vehicle.enginesp
            end
            if configs.vehicle.brake then
              gvp.GarageBrakes = configs.vehicle.brakesp
            end
            if configs.vehicle.suspension then
              gvp.Height = configs.vehicle.suspensionhe
            end
            if configs.vehicle.turn then
              gvp.TurnSpeed = configs.vehicle.turnsp
            end
          end
        end
      end)
    end
  end)
end)
client.noJumpCD = function(a)
    local AlexChassisModule = require(game:GetService("ReplicatedStorage").Module.AlexChassis)

    if not AlexChassisModule then
        return
    end

    if a then
        if not AlexChassisModule.originalRunAction then
            AlexChassisModule.originalRunAction = AlexChassisModule.runAction

            AlexChassisModule.runAction = function(actionName)
                local result = AlexChassisModule.originalRunAction(actionName)
                if actionName == "Jump" and result then
                    local VehicleUtils = require(game:GetService("ReplicatedStorage").Module.VehicleUtils)
                    local vehiclePacket = VehicleUtils.GetLocalVehiclePacket()
                    if vehiclePacket then
                        vehiclePacket._lastJumpAt = 0
                    end
                end
                return result
            end
        end
    else
        if AlexChassisModule.originalRunAction then
            AlexChassisModule.runAction = AlexChassisModule.originalRunAction
            AlexChassisModule.originalRunAction = nil
        end
    end
end

AddToggle = (function(groupboxes, txt, clbck, default, tooltip)
  default = default or false
  local tbl = {
    Text = txt,
    Default = default,
    Callback = function(a)
      task.spawn(function()
        if clbck then
          clbck(a)
        end
      end)
    end,
  }

  if tooltip and type(tooltip) == "string" then
    tbl.Tooltip = tooltip
  end

  groupboxes:AddToggle(string.gsub(txt, " ", ""), tbl)
end)

AddSlider = (function(groupboxes, txt, clbck, default, min, max, round, tootip)
  default = default or false
  tootip = tootip or nil
  round = round or 0
  local tbl = {
    Text     = txt,
    Default  = default,
    Max      = max,
    Min      = min,
    Rounding = round,
    Callback = clbck,
    Tooltip  = tootip,
  }
  if tootip == nil then
    table.remove(tbl, 4)
  end
  groupboxes:AddSlider(string.gsub(txt, " ", ""), tbl)
end)

Library.ShowToggleFrameInKeybinds = true
Library.ShowCustomCursor = false
Library.ForceCheckbox = true
-- Library.Font = Enum.Font.Code

Library:Notify("Loaded!", 3)
Library:Notify("Right shift to open on pc", 3)

local Window = Library:CreateWindow({
  Title = "Rendex",
  Footer = "Game: "..game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name..", Version: 0.0.4R",
  Icon = 'rbxassetid://104882957553580',
  CornerRadius = 10,
  Center = true,
  AutoShow = false,
  Resizable = true,
  ShowCustomCursor = false,
  NotifySide = "Right",
  TabPadding = 1,
  MenuFadeTime = 0.2,
  EnableSidebarResize = true,
  GlobalSearch = true,
  --  Size = UDim2.fromOffset(500, 385)
})

local tab = Window:AddTab("Main", "layout-grid", "Main Features")

local group = tab:AddLeftGroupbox("Player")

AddToggle(group, "Always Sprinting", function(a)
  configs.player.alwayssp = a
  if a then
    client.sprintLoop()
  end
end)
local AlwaysJuicedToggle = group:AddToggle("AlwaysJuicedKey", {
  Text = "Always Juiced",
  Default = configs.player.juiced,
  Callback = function(a)
    configs.player.juiced = a
    if a then
      if not getgenv()._juiceConn then
        local CharacterUtil = require(game:GetService("ReplicatedStorage").Game.CharacterUtil)
        local RunService = game:GetService("RunService")

        getgenv()._juiceConn = RunService.Heartbeat:Connect(function()
          CharacterUtil.IsJuiced = true
          CharacterUtil.WalkSpeedSpring:Accelerate(0.05)
        end)
      end
    else
      if getgenv()._juiceConn then
        getgenv()._juiceConn:Disconnect()
        getgenv()._juiceConn = nil

        local CharacterUtil = require(game:GetService("ReplicatedStorage").Game.CharacterUtil)
        CharacterUtil.IsJuiced = false
        CharacterUtil.WalkSpeedSpring:Accelerate(-0)
      end
    end
  end
})
local InfJumpToggle = group:AddToggle("InfJumpKey", {
  Text = "Infinite Jump",
  Default = configs.player.infjump,
  Callback = function(a)
    configs.player.infjump = a
  end
})
configs.player.respawndeathloc = false
AddToggle(group, "Anti Ragdoll", function(a)
  configs.player.norag = a
  local hrp = game:GetService("Players").LocalPlayer.Character:WaitForChild("HumanoidRootPart") or nil
  if configs.player.norag == false and hrp ~= nil then
    hrp:RemoveTag("NoRagdoll")
  elseif configs.player.norag == true and hrp ~= nil then
    hrp:AddTag("NoRagdoll")
  end
end)
AddToggle(group, "Anti Fall Injury", function(a)
  configs.player.nofall = a
  local hrp = game:GetService("Players").LocalPlayer.Character:WaitForChild("HumanoidRootPart") or nil
  if configs.player.nofall == false and hrp ~= nil then
    hrp:RemoveTag("NoFallDamage")
  elseif configs.player.nofall == true and hrp ~= nil then
    hrp:AddTag("NoFallDamage")
  end
end)
AddToggle(group, "Anti Skydiving", function(a)
  configs.player.nosky = a
end)
AddToggle(group, "Anti Ragdoll Stun", function(a)
  configs.player.nostun = a
  client.settingss.Time.Stunned = configs.player.nostun and 0 or 5
  setupvalue(client.stunnedragdoll, 1, configs.player.nostun and nil)
end)
AddToggle(group, "Anti Injury Slow", function(a)
  configs.player.noislow = a
  setconstant(client.walkspeedfun, 8, configs.player.noislow and 1 or 0.5)
end)
AddToggle(group, "Anti Crawling Slow", function(a)
  configs.player.nocslow = a
  setconstant(client.walkspeedfun, 16, configs.player.nocslow and 1 or 0.4)
end)
AddToggle(group, "Allow Equip When Crawling", function(a)
  configs.player.crawlequip = a
  if configs.player.crawlequip then
    client.isCrawlingLoop()
  end
end)
AddToggle(group, "Anti Spotlight Slow", function(a)
  configs.player.nopslow = a
  setconstant(client.walkspeedfun, 31, configs.player.nospslow and "hey_plainrocky123" or "IsLocalInSpotlight")
  setconstant(client.walkspeedfun, 33, configs.player.nospslow and "yourmomma" or "IsInTrackingSpotlight")
  setconstant(client.walkspeedfun, 35, a and 0 or 0.8)
  setconstant(getproto(client.spotlightbinder._constructor.TrackPlayer, 1), 14, a and 0 or 2.5)
end)
AddToggle(group, "Anti Cell Wait", function(a)
  configs.player.nocwait = a
  if a then
    client.cellloop()
  end
end)
local NoCircleHoldToggle = group:AddToggle("NoCircleHoldKey", {
  Text = "No Circle Hold",
  Default = configs.player.nocircwait,
  Callback = function(a)
    configs.player.nocircwait = a
    setconstant(client.updateplayer, 38, a and 0 or 0.5)
  end
})
AddToggle(group, "Circle Anti Clipping", function(a)
  setconstant(client.circleupdateui, 32, a and "Duration" or "NoRay")
end)
AddToggle(group, "Break Your Back Bone", function(a)
  configs.player.backbone = a
  if a then
    client.duckLoop()
  end
end)

local tab = Window:AddTab("Vehicle", "car")

local group = tab:AddLeftGroupbox("Utilities", "wrench")
AddToggle(group, "Infinite Nitro", function(a)
  configs.vehicle.infnitro = a
  if configs.vehicle.infnitro then
    client.nitroLoop()
  end
end)
AddToggle(group, "No Jump Cooldown", function(a)
    configs.vehicle.nojumpcd = a
    client.noJumpCD(a)
end)
local group = tab:AddLeftGroupbox("Car")
AddSlider(group, "Engine Speed", function(a)
  configs.vehicle.enginesp = a
end, configs.vehicle.enginesp, 0, 200, 0)
AddToggle(group, "Apply Engine Speed", function(a)
  configs.vehicle.engine = a
  if configs.vehicle.engine == false then
    client.updateToOriginalChassisStats()
  end
end)
AddSlider(group, "Brakes", function(a)
  configs.vehicle.brakesp = a
end, configs.vehicle.brakesp, 0, 30, 0)
AddToggle(group, "Apply Breaks", function(a)
  configs.vehicle.brake = a
  if configs.vehicle.brake == false then
    client.updateToOriginalChassisStats()
  end
end)
AddSlider(group, "Suspension Height", function(a)
  configs.vehicle.suspensionhe = a
end, configs.vehicle.suspensionhe, 0, 200, 0)
local ApplySusHeightToggle = group:AddToggle("ApplySusHeightKey", {
  Text = "Apply Suspension Height",
  Default = configs.vehicle.suspension,
  Callback = function(a)
    configs.vehicle.suspension = a
    client.updateToOriginalChassisStats()
  end
})
AddSlider(group, "Turn Speed", function(a)
  configs.vehicle.turnsp = a
end, configs.vehicle.turnsp, 0, 5, 0)
AddToggle(group, "Apply Turn Speed", function(a)
  configs.vehicle.turn = a
  if configs.vehicle.turn == false then
    client.updateToOriginalChassisStats()
  end
end)
AddToggle(group, "Anti Tire Pop", function(a)
  configs.vehicle.nopop = a
end)
AddToggle(group, "Drive On Water", function(a)
  configs.vehicle.driveonwater = a
  if client.rayParamsVehicleEnter then
    client.rayParamsVehicleEnter.IgnoreWater = not a
  end
end)
local AlwaysFlipToggle = group:AddToggle("AlwaysFlipKey", {
  Text = "Always Flip",
  Default = configs.vehicle.autoflip,
  Callback = function(a)
    configs.vehicle.autoflip = a
    client.flipLoop()
  end
})
AddToggle(group, "Instant Tow", function(a)
  configs.vehicle.instanttow = a
end)

local group = tab:AddLeftGroupbox("Helicopter")
AddSlider(group, "Engine Forward Speed", function(a)
  configs.vehicle.helienginesp = a / 10
end, 0, 0, 500, 0)
AddSlider(group, "Engine Vertical Speed", function(a)
  configs.vehicle.heliverticalsp = a / 10
end, 0, 0, 300, 0)
AddToggle(group, "Apply Modification", function(a)
  configs.vehicle.heliengine = a
end)
AddToggle(group, "Instant Heli Pickup", function(a)
  configs.vehicle.helipick = a
end)
AddToggle(group, "Anti Heli Down", function(a)
  configs.vehicle.helibreak = a
end)
AddToggle(group, "Infinite Heli Height", function(a)
  configs.vehicle.heliheight = a
end)

local group = tab:AddRightGroupbox("Garage slots")
local slotDrop = group:AddDropdown("Slot", {
  Text = "Choose Slot",
  Values = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "10" },
  Default = 1,
})

group:AddButton("Load Selected Slot", function()
  local remote = replicatedstorage:FindFirstChild("GarageSlotLoad")
  if remote then
    remote:FireServer("s" .. slotDrop.Value)
    Library:Notify("Loaded slot " .. slotDrop.Value, 2)
  else
    Library:Notify("Game not loaded properly", 2)
  end
end)

local group = tab:AddRightGroupbox("Motorbike")
AddSlider(group, "Speed Multiplier", function(a)
  setconstant(client.alexchassis2.UpdateHQ, 76, 1.2 + a)
end, 0, 0, 100, 0)
AddSlider(group, "Suspension Height Multiplier", function(a)
  setconstant(client.motorupdatewheel, 16, a)
end, 0, 0, 50, 0)

local group = tab:AddRightGroupbox("Tank")
-- AddSlider(group, "Engine Speed Multiplier", function(a)
-- 	configs.vehicle.tankenginesp = a
-- end, 0, 0, 500, 0)
-- AddToggle(group, "Apply Engine Speed", function(a)
-- 	print(configs.vehicle.tankenginesp)
-- 	setconstant(getproto(client.tankbinder._handleSeatedDriver, 4), 20, tonumber(configs.vehicle.tankenginesp))
-- 	print(getconstant(getproto(client.tankbinder._handleSeatedDriver, 4), 20))
-- end)
AddSlider(group, "Tracks Height", function(a)
  setconstant(client.tankbinder._buildWheelWorld, 28, 5.3 + a)
end, 0, 0, 50, 0)

local group = tab:AddRightGroupbox("Volt")
AddSlider(group, "Speed Multiplier", function(a)
  configs.vehicle.voltenginesp = a
end, 0, 0, 25, 0)
AddSlider(group, "Wheel Height", function(a)
  setconstant(client.vclasses.Volt.VehicleEnter, 30, 6.5 + a)
end, 0, 0, 19, 0)

local tab = Window:AddTab("Robberies", "landmark")

local group = tab:AddLeftGroupbox("Bank")
local NoLaserDamageToggle = group:AddToggle("NoBankLaserDamage", {
  Text = "No Laser Damage",
  Default = configs.robbery.bank.disablelasers,
  Callback = function(a)
    configs.robbery.bank.disablelasers = a
    client.disableBankLasers(a)
  end
})

local group = tab:AddRightGroupbox("Jewelry Store")
local NoJewelryLaserToggle = group:AddToggle("NoJewelryLaserDamage", {
  Text = "No Laser Damage",
  Default = configs.robbery.jewelry.disablelasers,
  Callback = function(a)
    configs.robbery.jewelry.disablelasers = a
    client.disableJewelryLasers(a)
  end
})

local group = tab:AddRightGroupbox("Museum")
local NoLaserDamageToggle = group:AddToggle("NoMuseumLaserDamage", {
  Text = "No Laser Damage",
  Default = configs.robbery.museum.disablelasers,
  Callback = function(a)
    configs.robbery.museum.disablelasers = a
    client.disableMuseumLasers(a)
  end
})

local group = tab:AddLeftGroupbox("Casino")
local NoLaserDamageToggle = group:AddToggle("NoCasinoLaserDamage", {
  Text = "No Laser Damage",
  Default = configs.robbery.casino.disablelasers,
  Callback = function(a)
    configs.robbery.casino.disablelasers = a
    client.disableCasinoLasers(a)
  end
})
local HackComputerToggle = group:AddToggle("HackComputer", {
  Text = "Hack computer",
  Default = configs.robbery.casino.fixcomputer,
  Callback = function(a)
    configs.robbery.casino.fixcomputer = a
    task.spawn(client.fixCasinoComputerLoop)
  end
})
local elevatorFloorDropdown = group:AddDropdown("CasinoElevatorFloor", {
  Text = "Choose Elevator Floor",
  Values = { "1", "2", "3", "4" },
  Default = 1,
  Callback = function(value)
    configs.robbery.casino.elevatorfloor = tonumber(value)
  end
})
group:AddButton("Call Elevator", function()
  client.callcasinoelevator(configs.robbery.casino.elevatorfloor)
end)

local group = tab:AddLeftGroupbox("Tomb")
AddToggle(group, "No Planks", function(a)
  configs.robbery.tomb.disableplanks = a
  client.disableTombPlanks(a)
end)
AddToggle(group, "No Spikes", function(a)
  configs.robbery.tomb.disablespikes = a
  client.disableTombSpikes(a)
end)
AddToggle(group, "No Darts", function(a)
  configs.robbery.tomb.disabledarts = a
  client.disableTombDarts(a)
end)

local group = tab:AddRightGroupbox("Oil Rig")
local NoLaserDamageToggle = group:AddToggle("NoLaserDamageKey", {
  Text = "No Laser Damage",
  Default = configs.robbery.oilrig.disablelasers,
  Callback = function(a)
    configs.robbery.oilrig.disablelasers = a
    client.disableOilRigLasers(a)
  end
})
local OilRigDisableTurretToggle = group:AddToggle("OilRigDisableTurretKey", {
  Text = "Disable Turret",
  Default = configs.robbery.oilrig.disableturret,
  Callback = function(a)
    configs.robbery.oilrig.disableturret = a
    setconstant(client.turret.ShootLaser, 31, a and 9e9 or 0.5)
  end
})
local DisableSelfDestructToggle = group:AddToggle("DisableSelfDestructKey", {
  Text = "Disable Self Destruct",
  Default = configs.robbery.oilrig.nooilblow,
  Callback = function(a)
    configs.robbery.oilrig.nooilblow = a
    client.oilexplosion.Name = a and "plainrocky123" or "Explosion"
    print(client.oilexplosion.Name)
  end
})

local group = tab:AddRightGroupbox("Cargo Ship")
local CargoShipDisableTurretToggle = group:AddToggle("CargoShipDisableTurretKey", {
  Text = "Disable Turret",
  Default = configs.robbery.cargoship.disableturret,
  Callback = function(a)
    configs.robbery.cargoship.disableturret = a
    setconstant(client.turret.ShootRocket, 16, a and "yousuck" or "Launch")
  end
})

local group = tab:AddRightGroupbox("Mansion")
AddToggle(group, "No Laser", function(a)
  configs.robbery.mansion.disablelasers = a
  client.disableMansionLasers(a)
end)
AddToggle(group, "No Traps", function(a)
  configs.robbery.mansion.disabletraps = a
  client.disableMansionTraps(a)
end)

local tab = Window:AddTab("Combat", "hand-fist")

local group = tab:AddLeftGroupbox("Utilities")
AddToggle(group, "Always Auto", function(a)
  configs.combat.alwaysauto = a
end)
AddToggle(group, "Anti Recoil", function(a)
  configs.combat.norecoil = a
end)
AddToggle(group, "Anti Spread", function(a)
  configs.combat.nospread = a
end)
AddToggle(group, "Anti Equip Time", function(a)
  configs.combat.noequipt = a
end)
AddToggle(group, "Bullet Criticals", function(a)
  configs.combat.alwaysheadshot = a
end)
AddToggle(group, "Instant Bullet Hit", function(a)
  configs.combat.instantbullethit = a
end)
AddToggle(group, "Increase Takedown Damage", function(a)
  configs.combat.increasetakedowndamage = a
end)
AddToggle(group, "Increase Forcefield Damage", function(a)
  configs.combat.increaseforcedamage = a
end)
--[[ AddToggle(group, "Shoot Through Wall", function(a)
  configs.combat.wallbang = a
end) ]]
AddToggle(group, "Shoot Through Forcefield", function(a)
  configs.combat.shootthroughforce = a
  setconstant(client.bulletemitter.Update, 26, configs.combat.shootthroughforce and 0 or 1)
end)
AddToggle(group, "Rocket Instant Seek", function(a)
  configs.combat.instantrocketseek = a
  client.rocketconsts.SEEKING_LOCK_MIN_DURATION = configs.combat.instantrocketseek and 0 or 2
end)
AddToggle(group, "Free Pistol Swat", function(a)
  configs.combat.pistolswat = a
end)
AddToggle(group, "Fast Taser", function(a)
  configs.combat.tasermodz = a
end)
AddToggle(group, "Faster Forcefield Reload", function(a)
  configs.combat.forcefieldreload = a
end)
AddToggle(group, "Anti Forcefield Misses", function(a)
  configs.combat.forcefieldnomiss = a
end)
AddToggle(group, "Anti Smoke Grenande Effect", function(a)
  configs.combat.nogrenadesmoke = a
  client.smokeGrenadeHook(a)
end)
AddToggle(group, "Anti Smoke Grenade Limit", function(a)
  configs.combat.nogrenadesmokelimit = a
  setconstant(client.gethrowablesmokegrenade, 6, a and 0 or 1)
end)

local group = tab:AddLeftGroupbox("Melee")
AddToggle(group, "Anti Reload Time", function(a)
  configs.combat.batonsword.noreloadtime = a
  if configs.combat.batonsword.noreloadtime then
    client.setBatonSwordTime(configs.combat.batonsword.noreloadtime)
  end
end)
AddToggle(group, "Always Swoosh", function(a)
  configs.combat.batonsword.spamswoosh = a
  if configs.combat.batonsword.spamswoosh then
    client.spamBatonSwordSwoosh()
  end
end)
AddToggle(group, "Always Lunge", function(a)
  configs.combat.batonsword.spamlunge = a
  if configs.combat.batonsword.spamlunge then
    client.spamBatonSwordLunge()
  end
end)

local group = tab:AddRightGroupbox("Silent Aim")

local SlientAimToggle = group:AddToggle("SlientAimKey", {
  Text = "Enabled",
  Default = configs.combat.silentaim.enabled,
  Callback = function(a)
    configs.combat.silentaim.enabled = a
  end
})
AddSlider(group, "Range", function(a)
  configs.combat.silentaim.range = a
end, 300, 50, 1000, 0)
local TargetNpcsToggle = group:AddToggle("TargetNpcsKey", {
  Text = "Target NPCs",
  Default = configs.combat.silentaim.targetnpcs,
  Callback = function(a)
    configs.combat.silentaim.targetnpcs = a
  end
})
--[[ AddToggle(group, "Wallcheck", function(a)
  configs.combat.silentaim.wallcheck = a
end) ]]
AddToggle(group, "Include Taser", function(a)
  configs.combat.silentaim.includetaser = a
end)
AddToggle(group, "Include Plasma", function(a)
  configs.combat.silentaim.includeplasma = a
end)
AddToggle(group, "FOV Circle", function(a)
  configs.combat.silentaim.fovcirc = a
  Circle.Visible = a
  CircleOutline.Visible = a
end)
AddToggle(group, "FOV Circle Filled", function(a)
  CircleFilled.Visible = a
end)
AddSlider(group, "Radius", function(a)
  configs.combat.silentaim.radius = a
  Circle.Radius = a
  CircleOutline.Radius = a + 2
  CircleFilled.Radius = a - 1
end, 50, 10, 1000, 0)

local group = tab:AddRightGroupbox("Handcuff aura")
AddToggle(group, "Arrest Aura", function(a)
  configs.combat.arrestaura.enabled = a
  if configs.combat.arrestaura.enabled then
    client.launchArrestAura()
  end
end)

local group = tab:AddRightGroupbox("Gun Store")
group:AddLabel("This only works near a gun store.", true)
group:AddButton({
  Text = 'Get All Owned Gun',
  Func = function()
    client.getallgun()
  end,
  DoubleClick = false,
  Disabled = false,
  Visible = true
})
group:AddButton({
  Text = 'Open Gunstore UI',
  Func = function()
    client.showgunstore()
  end,
  DoubleClick = false,
  Disabled = false,
  Visible = true
})

local tab = Window:AddTab("Visual", "eye")

local group = tab:AddLeftGroupbox("ESP Options")
AddToggle(group, "Enabled", function(a)
  MainESP.Options.Enabled = a
end)
AddToggle(group, "Bounties", function(a)
  MainESP.Options.Bounties = a
end)
AddToggle(group, "Box", function(a)
  MainESP.Options.Box = a
end)
AddToggle(group, "Tracer", function(a)
  MainESP.Options.Tracer = a
end)
AddToggle(group, "Name", function(a)
  MainESP.Options.Name = a
end)
AddToggle(group, "Distance", function(a)
  MainESP.Options.Distance = a
end)
AddToggle(group, "Health", function(a)
  MainESP.Options.Health = a
end)
AddToggle(group, "Skeleton", function(a)
  MainESP.Options.Skeleton = a
end)

local group = tab:AddRightGroupbox("ESP Settings")
AddToggle(group, "Team Check", function(a)
  MainESP.Options.Enabled = a
end)
AddToggle(group, "Use Team Color", function(a)
  MainESP.Options.UseTeamColor = a
end, true)
AddToggle(group, "Rainbow", function(a)
  MainESP.Options.Rainbow = a
end)
AddToggle(group, "Text Outline", function(a)
  MainESP.Options.TextOutline = a
end)
AddSlider(group, "Text Size", function(a)
  MainESP.Options.FontSize = a
end, 15, 1, 50, 0)
group:AddDropdown('TracerOrigins', {
  Values = { "Top", "Middle", "Bottom" },
  Default = 3,
  Multi = false,
  Text = "Tracer Origins",
  Searchable = false,
  Callback = function(Value)
    MainESP.Options.TracerOrigin = Value
  end,
  Visible = true,
})

local tab = Window:AddTab("Miscellaneous", "flask-conical")

local group = tab:AddLeftGroupbox("Protections")
AddToggle(group, "Disable Home Turret", function(a)
  configs.others.disablehometurret = a
  client.getNearestPlayerHook(a)
end)
AddToggle(group, "Disable Military Turrets", function(a)
  configs.others.disablemilitaryturret = a
  client.disableMilitaryTurrets(a)
end, configs.others.disablemilitaryturret)
AddToggle(group, "Disable Guards", function(a)
  configs.others.guardnodmg = a
  client.disableGuards(a)
end)
local group = tab:AddRightGroupbox("Fun")
AddToggle(group, "Open All Doors & Gates", function(a)
  configs.others.opendoor = a
  if a then
    client.opendoorloop()
  end
end)
AddToggle(group, "Open All Sewer Hatch", function(a)
  configs.others.opensewer = a
  if a then
    client.oepnsewerloop()
  end
end)
AddToggle(group, "Break Prison Elevator", function(a)
  configs.others.prisonelevator = a
  if a then
    client.prisonelevatorloop()
  else
    client.callprisonelevator(2)
  end
end)
local BreakElevatorToggle = group:AddToggle("BreakCasinoElevator", {
  Text = "Break Casino Elevator",
  Default = configs.others.breakelevator,
  Callback = function(a)
    configs.others.breakelevator = a
    if a then
      client.casinoelevatorloop()
    else
      local elevator = client.getcasinoelevator()
      if elevator and elevator.Car and elevator.Car.InnerModel and elevator.Car.InnerModel.Calls then
        local callButton = elevator.Car.InnerModel.Calls["2"]
        if callButton and callButton:FindFirstChild("ClickDetector") then
          fireclickdetector(callButton.ClickDetector)
        end
      end
    end
  end
})

--// keybinds

local Keybind = InfJumpToggle:AddKeyPicker("InfJumpKey", {
  Default = "O",
  Text = "Infinite Jump",
  SyncToggleState = true,
  Mode = "Toggle",
  Callback = function(a)
    configs.player.infjump = a
  end
})

local Keybind = AlwaysJuicedToggle:AddKeyPicker("AlwaysJuicedKey", {
  Default = "O",
  Text = "Always Juiced",
  SyncToggleState = true,
  Mode = "Toggle",
  Callback = function(a)
    configs.player.juiced = a
  end
})

local Keybind = NoCircleHoldToggle:AddKeyPicker("NoCircleHoldKey", {
  Default = "O",
  Text = "No Circle Hold",
  SyncToggleState = true,
  Mode = "Toggle",
  Callback = function(a)
    configs.player.nocircwait = a
  end
})

local Keybind = AlwaysFlipToggle:AddKeyPicker("AlwaysFlipKey", {
  Default = "O",
  Text = "Always Flip",
  SyncToggleState = true,
  Mode = "Toggle",
  Callback = function(a)
    configs.vehicle.flipLoop = a
  end
})

local Keybind = ApplySusHeightToggle:AddKeyPicker("ApplySusHeightKey", {
  Default = "O",
  Text = "Apply Suspension Height",
  SyncToggleState = true,
  Mode = "Toggle",
  Callback = function(a)
    configs.vehicle.suspension = a
  end
})

local tab = Window:AddTab("Credits", "circle-user")
local group = tab:AddLeftGroupbox("Credits")
group:AddLabel("credits to codecoat for the source", true)

local tab = Window:AddTab("Settings", "settings")
local MenuGroup = tab:AddLeftGroupbox("Menu")
MenuGroup:AddLabel("Join Our Discord For Receiving The Latest News About Rendex!", true)
MenuGroup:AddButton("Copy Discord Invite", function()
  if setclipboard == nil then
    Library:Notify("Copy Discord Invite Failed!, Missing Function: setclipboard")
    return
  end
  setclipboard("https://discord.gg/X4GW8N5GdW")
  Library:Notify("Success!")
end)
MenuGroup:AddLabel("Menu bind")
    :AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
MenuGroup:AddToggle("KeybindMenuOpen", {
  Default = Library.KeybindFrame.Visible,
  Text = "Open Keybind Menu",
  Callback = function(value)
    Library.KeybindFrame.Visible = value
  end,
})
MenuGroup:AddButton("Unload", function() Library:Unload() end)
Library.ToggleKeybind = Options.MenuKeybind
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
ThemeManager:SetFolder('Rendex')
SaveManager:SetFolder('Rendex/Jailbreak')
SaveManager:BuildConfigSection(tab)
ThemeManager:ApplyToTab(tab)
SaveManager:LoadAutoloadConfig()

Library.ToggleKeybind = Options.MenuKeybind

task.spawn(function()
  while true do
    task.wait(2)
    if configs.robbery.bank.disablelasers then client.disableBankLasers(true) end
    if configs.robbery.museum.disablelasers then client.disableMuseumLasers(true) end
    if configs.robbery.casino.disablelasers then client.disableCasinoLasers(true) end
    if configs.robbery.oilrig.disablelasers then client.disableOilRigLasers(true) end
    if configs.robbery.tomb.disableplanks then client.disableTombPlanks(true) end
    if configs.robbery.tomb.disabledarts then client.disableTombDarts(true) end
    if configs.robbery.tomb.disablespikes then client.disableTombSpikes(true) end
    if configs.robbery.jewelry.disablelasers then client.disableJewelryLasers(true) end
    if configs.robbery.mansion.disablelasers then client.disableMansionLasers(true) end
    if configs.robbery.mansion.disabletraps then client.disableMansionTraps(true) end
    if configs.others.guardnodmg then client.disableGuards(true) end
  end
end)
