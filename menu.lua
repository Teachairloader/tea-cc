local v0 = "https://raw.githubusercontent.com/panduh16/juju/main/ui.lua";
local v1 = "drift";
local v2 = v1 .. "/ui.lua";
local v3 = 6 * 60 * 60;
local v4 = "--[[tea.cc cache:";
getgenv().script_name = "Drift";
getgenv().script_version = "";
getgenv().custom_folder = v1;
local function v8()
local FlatIdent_95CAC = 0;
local v64;
local v65;
local v66;
local v67;
local v68;
while true do
if (FlatIdent_95CAC == 3) then
v68 = v65:sub(v66 + 2);
if ((1404 == 1404) and (#v68 < 1000)) then
return nil;
end
return v68;
end
if (FlatIdent_95CAC == 1) then
if (not v64 or (type(v65) ~= "string") or (#v65 < 1000) or (4593 <= 2672)) then
return nil;
end
if ((v65:sub(1, #v4) ~= v4) or (1168 > 3156)) then
return nil;
end
v66 = v65:find("]]", #v4 + 1, true);
FlatIdent_95CAC = 2;
end
if (FlatIdent_95CAC == 0) then
if ((4797 >= 3895) and ((type(isfile) ~= "function") or (type(readfile) ~= "function"))) then
return nil;
end
if not isfile(v2) then
return nil;
end
v64, v65 = pcall(readfile, v2);
FlatIdent_95CAC = 1;
end
if (FlatIdent_95CAC == 2) then
if not v66 then
return nil;
end
v67 = tonumber(v65:sub(#v4 + 1, v66 - 1));
if ((3577 == 3577) and (not v67 or ((os.time() - v67) > v3) or (572 > 4486))) then
return nil;
end
FlatIdent_95CAC = 3;
end
end
end
local function v9(v69)
local FlatIdent_67C40 = 0;
while true do
if (FlatIdent_67C40 == 0) then
if ((type(writefile) ~= "function") or (3748 < 2212)) then
return;
end
pcall(function()
local FlatIdent_89ECE = 0;
while true do
if (FlatIdent_89ECE == 0) then
if ((3794 > 3693) and (type(isfolder) == "function") and (type(makefolder) == "function") and not isfolder(v1)) then
makefolder(v1);
end
writefile(v2, v4 .. tostring(os.time()) .. "]]\n" .. v69);
break;
end
end
end);
break;
end
end
end
local function v10()
local FlatIdent_2661B = 0;
while true do
if (FlatIdent_2661B == 0) then
if ((type(delfile) ~= "function") or (type(isfile) ~= "function") or (1180 == 2180)) then
return;
end
if ((4090 < 4653) and isfile(v2)) then
pcall(delfile, v2);
end
break;
end
end
end
local function v11()
local FlatIdent_475BC = 0;
local v70;
local v71;
while true do
if (FlatIdent_475BC == 0) then
v70, v71 = pcall(function()
return game:HttpGet(v0 .. "?t=" .. tostring(os.time()));
end);
if (not v70 or (type(v71) ~= "string") or (#v71 < 1000) or (2652 < 196)) then
return nil, tostring(v71);
end
FlatIdent_475BC = 1;
end
if (FlatIdent_475BC == 1) then
v9(v71);
return v71;
end
end
end
local v12 = v8();
if ((4135 < 4817) and v12 and not loadstring(v12)) then
v10();
v12 = nil;
end
local v13;
if (((272 == 272) and not v12) or (1275 == 4100)) then
v12, v13 = v11();
end
if ((100 <= 3123) and not v12) then
return warn("[tea.cc] could not fetch juju: " .. tostring(v13));
end
local function v14(v72, v73, v74)
local FlatIdent_43862 = 0;
local v75;
while true do
if (0 == FlatIdent_43862) then
v75 = v73:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%1");
return (v72:gsub(v75, v74));
end
end
end
local v15 = "154, 213, 222";
if not v12:find(v15, 1, true) then
warn("[tea.cc] accent triple not found in juju source - upstream changed, colours left stock");
end
v12 = v14(v12, "color3_fromrgb(" .. v15 .. ")", "color3_fromrgb(255, 255, 255)");
v12 = v14(v12, "color3_fromrgb(51, 65, 70)", "color3_fromrgb(30, 30, 30)");
v12 = v14(v12, "color3_fromrgb(70, 85, 87)", "color3_fromrgb(140, 140, 140)");
v12 = v14(v12, "color3_fromrgb(39, 60, 96)", "color3_fromrgb(58, 58, 58)");
v12 = v14(v12, "color3_fromrgb(30, 51, 61)", "color3_fromrgb(38, 38, 38)");
if ((type(v12) == "string") or (1369 > 4987) or (1591 >= 3580)) then
local FlatIdent_3B561 = 0;
local v288;
while true do
if (FlatIdent_3B561 == 0) then
v288 = nil;
function v288(v781, v782, v783)
if ((type(v781) ~= "string") or (v782 == "") or (863 >= 4584)) then
return v781;
end
local v784, v785 = {}, 1;
while true do
local v945, v946 = v781:find(v782, v785, true);
if ((983 <= 1808) and (not v945 or (724 >= 1668))) then
break;
end
v784[#v784 + 1] = v781:sub(v785, v945 - 1);
v784[#v784 + 1] = v783;
v785 = v946 + 1;
end
v784[#v784 + 1] = v781:sub(v785);
return table.concat(v784);
end
v12 = v288(v12, "575", "690");
FlatIdent_3B561 = 1;
end
if (FlatIdent_3B561 == 3) then
v12 = v288(v12, '["Position"] = udim2_new(1, 5, 0, 19)', '["Position"] = udim2_new(1, 8, 0, 27)');
pcall(function()
if isfile(getgenv().custom_folder .. "/assets/logo.png") then
v12 = v288(v12, 'safeHttp("https://raw.githubusercontent.com/panduh16/juju/main/assets/logo.png")', 'readfile(getgenv().custom_folder .. "/assets/logo.png")');
end
end);
break;
end
if (FlatIdent_3B561 == 2) then
v12 = v288(v12, "\r\n", "\n");
if ((428 < 1804) and not v12:find("udim2_new(0, 690, 0, 710)", 1, true)) then
warn("[drift] juju window anchors moved - frame left at stock 575x450");
end
v12 = v288(v12, '["Position"] = udim2_new(1, 5, 0, 3)', '["Position"] = udim2_new(1, 8, 0, 12)');
FlatIdent_3B561 = 3;
end
if (FlatIdent_3B561 == 1) then
v12 = v288(v12, "450", "710");
v12 = v288(v12, "405", "665");
v12 = v288(v12, "udim2_new(0, 35, 0, 35)", "udim2_new(0, 40, 0, 40)");
FlatIdent_3B561 = 2;
end
end
end
local v16, v17 = loadstring(v12);
if (not v16 or (3325 > 4613)) then
v10();
return warn("[tea.cc] juju failed to compile (cache cleared): " .. tostring(v17));
end
local v18, v19 = pcall(v16);
if (not v18 or (type(v19) ~= "table") or (type(v19.menu) ~= "table") or (4950 <= 4553) or (2150 <= 1197)) then
return warn("[tea.cc] juju failed to load: " .. tostring(v19));
end
local v20 = v19.menu;
local v21 = v19.flags;
v20['colors']['accent'] = Color3.fromRGB(255, 255, 255);
v20['colors']['shadow'] = Color3.fromRGB(255, 255, 255);
v20['colors']['success'] = Color3.fromRGB(255, 255, 255);
v20['colors']['logo'] = Color3.fromRGB(255, 255, 255);
v20['colors']['juju'] = Color3.fromRGB(255, 255, 255);
v20['colors']['build'] = Color3.fromRGB(255, 255, 255);
v20['colors']['cursor'] = Color3.fromRGB(255, 255, 255);
pcall(function()
writefile(v1 .. "/themes/default.th", '{"!image_color":[89,89,89],"!error_color":[58,58,58],"!accent_color":[255,255,255],' .. '"!build_color":[255,255,255],"!success_color":[255,255,255],"!active_border_color":[30,30,30],' .. '"!dark_text_color":[140,140,140],"!juju_color":[255,255,255],"!background_color":[0,0,0],' .. '"!border_color":[24,25,24],"!keybind_text_color":[197,197,197],"!inactive_text_color":[75,72,72],' .. '"!shadow_color":[255,255,255],"!active_text_color":[197,197,197],"!alert_color":[38,38,38],' .. '"!logo_color":[255,255,255],"!section_color":[6,6,6]}');
end);
local v29 = 690;
local v30 = {toggle=17,keybind=17,slider=31,dropdown=35,textbox=35,button=21,colorpicker=17,info=17};
local v31 = Color3.fromRGB(255, 255, 255);
local function v32(v76, v77)
local v78 = {};
if ((3769 >= 1173) and (v77.k == "toggle")) then
v78.toggle = {flag=v77.f,default=v77.d};
elseif ((2665 <= 3933) and (v77.k == "keybind")) then
v78.keybind = {flag=v77.f,default=v77.d};
elseif ((1485 == 1485) and (3273 == 3273) and (v77.k == "slider")) then
v78.slider = {flag=v77.f,min=v77.min,max=v77.max,default=v77.d,decimals=(v77.dec or 0),suffix=v77.suffix,prefix=v77.prefix,min_text=v77.min_text,max_text=v77.max_text};
elseif ((3824 > 409) and (v77.k == "dropdown")) then
v78.dropdown = {flag=v77.f,options=v77.o,default=v77.d,multi=v77.multi,requires_one=v77.req};
elseif (v77.k == "textbox") then
v78.textbox = {flag=v77.f,default=v77.d};
elseif (v77.k == "button") then
v78.button = {confirmation=v77.conf};
elseif ((2087 == 2087) and (v77.k == "colorpicker")) then
v78.colorpicker = {color_flag=v77.f,transparency_flag=(v77.f .. "_transparency"),default_color=(v77.d or v31),default_transparency=(v77.t or 0)};
elseif (v77.k ~= "info") then
else
v78.info = {};
end
local v79 = v76:create_element({name=v77.n}, v78, true);
if (((v77.k == "keybind") and v79 and v79['set_key'] and not v21[v77.f]) or (3404 > 4503) or (3315 <= 2782)) then
v79:set_key(v77.d);
end
return v79;
end
local function v33(v80, v81, v82, v83, v84, v85)
local FlatIdent_781F8 = 0;
local v86;
local v87;
local v88;
while true do
if (FlatIdent_781F8 == 3) then
return v83 + v87;
end
if (1 == FlatIdent_781F8) then
v87 = math.min(v86 / v29, 1);
v88 = v80:create_section(v81, v84, v82, v87, v83);
FlatIdent_781F8 = 2;
end
if (2 == FlatIdent_781F8) then
if (not v88 or (3506 <= 1309) or (876 >= 2964)) then
warn("[tea.cc] section failed: " .. tostring(v84));
return v83;
end
for v291, v292 in ipairs(v85) do
v32(v88, v292);
end
FlatIdent_781F8 = 3;
end
if (FlatIdent_781F8 == 0) then
v86 = 20;
for v289, v290 in ipairs(v85) do
v86 = v86 + (v30[v290.k] or 17);
end
FlatIdent_781F8 = 1;
end
end
end
local v34 = "2026-10-25g";
local v35 = v20.create_group("main");
v35:create_tab("combat");
v35:create_tab("visuals");
v35:create_tab("rage");
v35:create_tab("misc");
local v36 = 0;
v36 = v33(v35, "combat", 1, v36, "camlock", {{k="toggle",n="enabled",f="aim_enabled",d=false},{k="dropdown",n="activation",f="aim_activation",o={"Toggle","Hold"},d={"Toggle"},req=true},{k="keybind",n="aim key",f="aim_key",d=Enum.UserInputType.MouseButton2},{k="dropdown",n="hit part",f="aim_hit_part",o={"Head","Torso","Closest Part","Nearest Bone"},d={"Head"},req=true},{k="slider",n="y offset",f="aim_y_offset",min=-3,max=3,d=-0.6,dec=2},{k="slider",n="fov size",f="aim_fov",min=0,max=1000,d=120},{k="toggle",n="visualise fov",f="aim_fov_visualise",d=false},{k="slider",n="smoothing",f="aim_smooth",min=0,max=100,d=0},{k="slider",n="prediction",f="aim_prediction",min=0,max=0.3,d=0,dec=3},{k="toggle",n="wall check",f="aim_wall_check",d=false},{k="toggle",n="team check",f="aim_team_check",d=false}});
v36 = 0;
v36 = v33(v35, "combat", 2, v36, "rapid fire", {{k="toggle",n="enabled",f="rapid_enabled",d=false},{k="slider",n="shots per second",f="rapid_rate",min=60,max=1000,d=300},{k="toggle",n="require ammo",f="rapid_require_ammo",d=true}});
v36 = v33(v35, "combat", 2, v36, "hitbox expander", {{k="toggle",n="enabled",f="hitbox_enabled",d=false},{k="dropdown",n="target",f="hitbox_target",o={"All Players","Aim Target"},d={"All Players"},req=true},{k="slider",n="size",f="hitbox_size",min=1,max=60,d=12,dec=1},{k="slider",n="transparency",f="hitbox_transparency",min=0,max=1,d=0.6,dec=2},{k="dropdown",n="part",f="hitbox_part",o={"HumanoidRootPart","Head","Torso","UpperTorso","LowerTorso","All Body"},d={"HumanoidRootPart"},req=true}});
v36 = v33(v35, "combat", 2, v36, "targets", {{k="toggle",n="prefer closest",f="target_closest",d=true},{k="toggle",n="prefer lowest health",f="target_lowest",d=false},{k="toggle",n="ignore friends",f="target_friends",d=false},{k="slider",n="max distance",f="target_distance",min=0,max=1000,d=500}});
v36 = 0;
v36 = v33(v35, "visuals", 1, v36, "esp", {{k="toggle",n="enabled",f="esp_enabled",d=false},{k="toggle",n="box",f="esp_box",d=true},{k="slider",n="box width",f="esp_width",min=0.1,max=1,d=0.28,dec=2},{k="toggle",n="name",f="esp_name",d=true},{k="toggle",n="distance",f="esp_distance",d=true},{k="toggle",n="skeleton",f="esp_skeleton",d=false},{k="toggle",n="health bar",f="esp_health",d=true},{k="toggle",n="armor bar",f="esp_armor",d=false},{k="toggle",n="held tool",f="esp_tool",d=false},{k="toggle",n="highlight",f="esp_highlight",d=false},{k="toggle",n="team check",f="esp_team",d=true},{k="slider",n="text size",f="esp_text_size",min=10,max=24,d=14},{k="slider",n="max distance",f="esp_max_distance",min=50,max=2000,d=2000}});
v36 = 0;
v36 = v33(v35, "visuals", 2, v36, "interface", {{k="toggle",n="watermark",f="ui_watermark",d=false},{k="toggle",n="keybind list",f="ui_keybind_list",d=false},{k="slider",n="menu scale",f="ui_scale",min=80,max=120,d=100,suffix="%"}});
v36 = v33(v35, "visuals", 2, v36, "crosshair", {{k="toggle",n="enabled",f="crosshair_enabled",d=false},{k="colorpicker",n="colour",f="crosshair_color",d=Color3.fromRGB(255, 255, 255)},{k="toggle",n="spin",f="crosshair_spin",d=true},{k="toggle",n="resize",f="crosshair_resize",d=true}});
v36 = v33(v35, "visuals", 2, v36, "avatar", {{k="toggle",n="aura",f="avatar_aura",d=false},{k="toggle",n="china hat",f="avatar_china_hat",d=false}});
v36 = 0;
v36 = v33(v35, "misc", 1, v36, "world", {{k="dropdown",n="lighting",f="world_preset",o={"Off","Red","Night","Overcast","Storm","Dusk","Void","Custom"},d={"Off"},req=true},{k="colorpicker",n="sky tint",f="world_sky_top",d=Color3.fromRGB(255, 255, 255)},{k="colorpicker",n="ground tint",f="world_sky_bottom",d=Color3.fromRGB(255, 255, 255)},{k="colorpicker",n="ambient",f="world_ambient",d=Color3.fromRGB(255, 255, 255)},{k="colorpicker",n="fog",f="world_fog",d=Color3.fromRGB(255, 255, 255)},{k="slider",n="brightness",f="world_brightness",min=0,max=4,d=2,dec=2},{k="slider",n="time of day",f="world_clock",min=0,max=24,d=14,dec=1},{k="slider",n="fog distance",f="world_fog_end",min=0,max=5000,d=800},{k="slider",n="exposure",f="world_exposure",min=-3,max=3,d=0,dec=2},{k="toggle",n="fullbright",f="world_fullbright",d=false},{k="toggle",n="remove fog",f="world_no_fog",d=false}});
v36 = v33(v35, "misc", 1, v36, "weather", {{k="dropdown",n="type",f="world_weather",o={"None","Snow","Rain","Storm"},d={"None"},req=true},{k="slider",n="density",f="world_weather_rate",min=0,max=100,d=55},{k="slider",n="size",f="world_weather_size",min=0.2,max=4,d=1,dec=1},{k="slider",n="fall speed",f="world_weather_speed",min=20,max=200,d=100},{k="slider",n="wind",f="world_weather_wind",min=-80,max=80,d=14},{k="colorpicker",n="colour",f="world_weather_color",d=Color3.fromRGB(235, 244, 255)},{k="toggle",n="lightning",f="world_lightning",d=false}});
v36 = 0;
v36 = v33(v35, "misc", 2, v36, "skin changer", {{k="toggle",n="enabled",f="skin_enabled",d=false},{k="dropdown",n="skin",f="skin_choice",o={"Inferno","Galaxy","Matrix","RedDeath","GoldGlory"},d={"Inferno"},req=true}});
v36 = v33(v35, "misc", 2, v36, "legit macro", {{k="toggle",n="enabled",f="legit_enabled",d=false},{k="keybind",n="bind",f="legit_key",d=Enum.KeyCode.X},{k="slider",n="delay",f="legit_delay",min=0,max=200,d=0,suffix="ms"}});
v36 = 0;
v36 = v33(v35, "rage", 1, v36, "anti lock", {{k="toggle",n="enabled",f="misc_antilock",d=false},{k="toggle",n="resolver",f="misc_resolver",d=false}});
v36 = v33(v35, "rage", 1, v36, "cframe speed", {{k="toggle",n="enabled",f="cspeed_enabled",d=false},{k="keybind",n="bind",f="cspeed_key",d=Enum.KeyCode.LeftAlt},{k="slider",n="speed",f="cspeed_value",min=10,max=400,d=60,suffix=" s/s"},{k="toggle",n="hold",f="cspeed_hold",d=false}});
v36 = v33(v35, "rage", 1, v36, "fake macro", {{k="toggle",n="enabled",f="macro_enabled",d=false},{k="slider",n="walkspeed",f="macro_walkspeed",min=16,max=500,d=100}});
v36 = 0;
v36 = v33(v35, "rage", 2, v36, "orbit", {{k="toggle",n="enabled",f="orbit_enabled",d=false},{k="keybind",n="bind",f="orbit_key",d=Enum.KeyCode.Q},{k="slider",n="height",f="orbit_height",min=0,max=16,d=5.4,dec=1},{k="slider",n="radius",f="orbit_radius",min=0.5,max=8,d=8,dec=1},{k="slider",n="speed",f="orbit_speed",min=5,max=80,d=12}});
do
local FlatIdent_7FAC9 = 0;
local v89;
local v90;
while true do
if (FlatIdent_7FAC9 == 1) then
function v90(v293, v294, v295, v296, v297, v298)
local FlatIdent_2D245 = 0;
local v299;
local v300;
local v301;
while true do
if (0 == FlatIdent_2D245) then
v299 = 20;
for v788, v789 in ipairs(v298) do
v299 = v299 + (v30[v789.k] or 17);
end
FlatIdent_2D245 = 1;
end
if (FlatIdent_2D245 == 3) then
return v296 + v300;
end
if (FlatIdent_2D245 == 2) then
if (not v301 or (2232 > 2497)) then
warn("[drift] section failed: " .. tostring(v297));
return v296;
end
for v790, v791 in ipairs(v298) do
v89[v791.f] = v32(v301, v791);
end
FlatIdent_2D245 = 3;
end
if (FlatIdent_2D245 == 1) then
v300 = math.min(v299 / v29, 1);
v301 = v293:create_section(v294, v297, v295, v300, v296);
FlatIdent_2D245 = 2;
end
end
end
v36 = v90(v35, "rage", 2, v36, "super jump", {{k="toggle",n="enabled",f="sjump_enabled",d=false},{k="keybind",n="bind",f="sjump_key",d=Enum.KeyCode.J},{k="slider",n="jump power",f="sjump_power",min=50,max=500,d=180}});
FlatIdent_7FAC9 = 2;
end
if (0 == FlatIdent_7FAC9) then
v89 = getgenv().DriftMoveElements or {};
v90 = nil;
FlatIdent_7FAC9 = 1;
end
if (FlatIdent_7FAC9 == 2) then
v36 = v90(v35, "rage", 2, v36, "fly", {{k="toggle",n="enabled",f="fly_enabled",d=false},{k="keybind",n="bind",f="fly_key",d=Enum.KeyCode.F},{k="slider",n="speed",f="fly_speed",min=10,max=300,d=80}});
getgenv().DriftMoveElements = v89;
break;
end
end
end
pcall(function()
v20:setup_configs("settings");
end);
print("[tea.cc] build " .. v34 .. " loaded - aim key " .. tostring(v21['aim_key']));
local v37 = game:GetService("Players");
local v38 = game:GetService("RunService");
local v39 = game:GetService("UserInputService");
local v40 = game:GetService("TweenService");
local v41 = workspace;
local v42 = v37.LocalPlayer;
local function v43(v92, v93)
local v94 = v21[v92];
if ((2955 == 2955) and (v94 == nil)) then
return v93;
end
return v94;
end
local function v44(v95, v96)
local FlatIdent_8F59B = 0;
while true do
if (FlatIdent_8F59B == 0) then
if ((type(v95) == "table") or (2110 <= 332)) then
return v95[1] or v96;
end
if ((3686 > 3172) and (type(v95) == "string")) then
return v95;
end
FlatIdent_8F59B = 1;
end
if (FlatIdent_8F59B == 1) then
if ((v95 == nil) or (2903 == 1495) or (4474 < 820)) then
return v96;
end
return v95;
end
end
end
local function v45(v97)
local FlatIdent_56024 = 0;
local v98;
while true do
if (FlatIdent_56024 == 1) then
return v98;
end
if (FlatIdent_56024 == 0) then
v98 = v97.AssemblyLinearVelocity;
if ((4279 >= 2882) and (v98.Magnitude == 0)) then
v98 = v97.Velocity;
end
FlatIdent_56024 = 1;
end
end
end
local function v46(v99)
if (typeof(v99) ~= "EnumItem") then
else
return v99;
end
if (type(v99) == "table") then
local FlatIdent_890DA = 0;
local v794;
while true do
if (0 == FlatIdent_890DA) then
v794 = v99.key or v99[1] or v99.value;
if ((4546 >= 2275) and (typeof(v794) == "EnumItem")) then
return v794;
end
FlatIdent_890DA = 1;
end
if (FlatIdent_890DA == 1) then
if (type(v794) == "string") then
local v1045, v1046 = pcall(function()
return Enum.KeyCode[v794];
end);
if ((819 >= 22) and v1045) then
return v1046;
end
end
return nil;
end
end
end
if ((type(v99) == "string") or (2029 >= 3521)) then
local FlatIdent_8CEDF = 0;
local v795;
local v796;
while true do
if (FlatIdent_8CEDF == 0) then
v795, v796 = pcall(function()
return Enum.KeyCode[v99];
end);
if v795 then
return v796;
end
break;
end
end
end
return nil;
end
local function v47(v100)
local FlatIdent_33EA4 = 0;
local v101;
while true do
if (FlatIdent_33EA4 == 1) then
return v39:IsKeyDown(v101);
end
if (FlatIdent_33EA4 == 0) then
v101 = v46(v100);
if (not v101 or (2037 >= 4642)) then
return false;
end
FlatIdent_33EA4 = 1;
end
end
end
if not v46(v21['aim_key']) then
v21['aim_key'] = Enum.UserInputType.MouseButton2;
elseif ((3162 == 3162) and (v21['aim_key'] == Enum.KeyCode.Q)) then
v21['aim_key'] = Enum.UserInputType.MouseButton2;
end
local v48 = {player=nil,part=nil,locked=nil};
do
local v102 = {"Head","UpperTorso","Torso","HumanoidRootPart"};
local v103 = nil;
if ((typeof(Drawing) == "table") and (type(Drawing.new) == "function")) then
local FlatIdent_74348 = 0;
local v797;
local v798;
while true do
if (FlatIdent_74348 == 0) then
v797, v798 = pcall(Drawing.new, "Circle");
if ((1720 < 4458) and v797 and v798) then
v103 = v798;
v103.Thickness = 1;
v103.Filled = false;
v103.Color = Color3.fromRGB(255, 255, 255);
v103.Visible = false;
end
break;
end
end
end
local function v104(v304, v305)
local FlatIdent_759F1 = 0;
local v306;
local v307;
while true do
if (FlatIdent_759F1 == 1) then
if ((4615 == 4615) and (4513 > 2726) and v306 and v306:IsA("BasePart")) then
return v306;
end
v307 = v304:FindFirstChild("HumanoidRootPart");
FlatIdent_759F1 = 2;
end
if (0 == FlatIdent_759F1) then
if (v305 == "Torso") then
local FlatIdent_52551 = 0;
local v950;
while true do
if (FlatIdent_52551 == 0) then
v950 = v304:FindFirstChild("UpperTorso") or v304:FindFirstChild("Torso");
if ((v950 and v950:IsA("BasePart")) or (2369 > 4429) or (436 > 3021)) then
return v950;
end
break;
end
end
elseif (v305 == "Closest Part") then
local v1127 = v42.Character and v42.Character:FindFirstChild("HumanoidRootPart");
local v1128, v1129 = nil, math.huge;
for v1164, v1165 in v102 do
local FlatIdent_60BB = 0;
local v1166;
while true do
if (FlatIdent_60BB == 0) then
v1166 = v304:FindFirstChild(v1165);
if ((713 <= 847) and v1166 and v1166:IsA("BasePart") and v1127) then
local FlatIdent_2D88C = 0;
local v1200;
while true do
if (FlatIdent_2D88C == 0) then
v1200 = (v1166.Position - v1127.Position).Magnitude;
if ((4095 >= 3183) and (v1200 < v1129)) then
v1128, v1129 = v1166, v1200;
end
break;
end
end
end
break;
end
end
end
if ((2154 <= 4031) and (v1128 or (3711 < 1008))) then
return v1128;
end
elseif ((v305 == "Nearest Bone") or (1049 <= 906)) then
for v1201, v1202 in v102 do
local v1203 = v304:FindFirstChild(v1202);
if (v1203 and v1203:IsA("BasePart")) then
return v1203;
end
end
end
v306 = v304:FindFirstChild("Head");
FlatIdent_759F1 = 1;
end
if (2 == FlatIdent_759F1) then
if (v307 and v307:IsA("BasePart")) then
return v307;
end
return nil;
end
end
end
local function v105(v308, v309, v310)
local FlatIdent_97786 = 0;
local v311;
while true do
if (FlatIdent_97786 == 1) then
v311.FilterDescendantsInstances = {v42.Character,v310};
v311.IgnoreWater = true;
FlatIdent_97786 = 2;
end
if (FlatIdent_97786 == 2) then
return v41:Raycast(v308, v309 - v308, v311) ~= nil;
end
if (FlatIdent_97786 == 0) then
v311 = RaycastParams.new();
v311.FilterType = Enum.RaycastFilterType.Exclude;
FlatIdent_97786 = 1;
end
end
end
local function v106(v316)
local FlatIdent_D79D = 0;
local v317;
local v318;
local v319;
local v320;
while true do
if (FlatIdent_D79D == 0) then
if (not v316 or (v316 == v42)) then
return false;
end
v317 = v316.Character;
if not v317 then
return false;
end
FlatIdent_D79D = 1;
end
if (FlatIdent_D79D == 1) then
v318 = v317:FindFirstChildOfClass("Humanoid");
if (not v318 or (v318.Health <= 0) or (1481 >= 2658) or (3790 == 500)) then
return false;
end
if ((89 < 221) and v43("aim_team_check", false) and v42.Team and (v316.Team == v42.Team)) then
return false;
end
FlatIdent_D79D = 2;
end
if (3 == FlatIdent_D79D) then
if ((692 < 3058) and (v317:FindFirstChild("GRABBING_CONSTRAINT") or (3220 == 1364))) then
return false;
end
if (v317:FindFirstChildOfClass("ForceField") or (1054 > 3392) or (3254 == 1655)) then
return false;
end
return true;
end
if (2 == FlatIdent_D79D) then
v319 = v317:FindFirstChild("BodyEffects");
v320 = v319 and v319:FindFirstChild("K.O");
if ((2054 >= 1421) and v320 and v320.Value) then
return false;
end
FlatIdent_D79D = 3;
end
end
end
local function v107()
local v321 = v41.CurrentCamera;
if (not v321 or (1296 == 4910)) then
return nil, nil;
end
local v322 = v43("aim_fov", 120);
local v323 = Vector2.new(v321.ViewportSize.X / 2, v321.ViewportSize.Y / 2);
local v324 = v42.Character and v42.Character:FindFirstChild("HumanoidRootPart");
local v325 = v43("target_distance", 500);
local v326 = v44(v43("aim_hit_part", {"Head"}), "Head");
local v327 = v43("aim_prediction", 0);
local v328 = v43("aim_wall_check", false);
local v329 = v321.CFrame.Position;
local v330, v331, v332 = nil, nil, math.huge;
for v799, v800 in v37:GetPlayers() do
if ((3368 == 3368) and v106(v800)) then
local FlatIdent_2E9CB = 0;
local v1051;
local v1052;
while true do
if (FlatIdent_2E9CB == 1) then
if ((2643 < 3815) and v1052) then
local FlatIdent_8BC55 = 0;
local v1167;
local v1168;
local v1169;
while true do
if (FlatIdent_8BC55 == 1) then
v1169 = not v328 or not v105(v329, v1168, v1051);
if ((v1167 and v1169) or (676 >= 1642)) then
local FlatIdent_8B336 = 0;
local v1204;
local v1205;
while true do
if (FlatIdent_8B336 == 0) then
v1204, v1205 = v321:WorldToViewportPoint(v1168);
if ((1913 > 493) and v1205) then
local FlatIdent_2BE02 = 0;
local v1249;
while true do
if (FlatIdent_2BE02 == 0) then
v1249 = (Vector2.new(v1204.X, v1204.Y) - v323).Magnitude;
if ((v1249 <= v322) and (v1249 < v332)) then
v330, v331, v332 = v800, v1052, v1249;
end
break;
end
end
end
break;
end
end
end
break;
end
if (FlatIdent_8BC55 == 0) then
v1167 = not v324 or ((v324.Position - v1052.Position).Magnitude <= v325);
v1168 = v1052.Position + (v45(v1052) * v327);
FlatIdent_8BC55 = 1;
end
end
end
break;
end
if (FlatIdent_2E9CB == 0) then
v1051 = v800.Character;
v1052 = v104(v1051, v326);
FlatIdent_2E9CB = 1;
end
end
end
end
return v330, v331;
end
local v108 = {Right=Enum.UserInputType.MouseButton2,Left=Enum.UserInputType.MouseButton1};
local function v109()
return v108[v44(v43("aim_mouse", {"None"}), "None")];
end
local function v110(v333)
local FlatIdent_7B716 = 0;
local v334;
while true do
if (FlatIdent_7B716 == 0) then
v334 = v109();
if ((4136 > 2397) and v334) then
return v333.UserInputType == v334;
end
FlatIdent_7B716 = 1;
end
if (FlatIdent_7B716 == 1) then
return v333.KeyCode == v46(v43("aim_key", Enum.KeyCode.Q));
end
end
end
local function v111()
local FlatIdent_5FF12 = 0;
local v335;
while true do
if (FlatIdent_5FF12 == 1) then
return v47(v43("aim_key", Enum.KeyCode.Q));
end
if (FlatIdent_5FF12 == 0) then
v335 = v109();
if ((4755 > 3428) and (v335 or (4334 == 4245))) then
return v39:IsMouseButtonPressed(v335);
end
FlatIdent_5FF12 = 1;
end
end
end
local function v112(v336)
local FlatIdent_494F6 = 0;
local v337;
while true do
if (FlatIdent_494F6 == 0) then
v337 = v46(v43("aim_key", Enum.UserInputType.MouseButton2));
if ((1381 <= 2369) and (typeof(v337) ~= "EnumItem")) then
return false;
end
FlatIdent_494F6 = 1;
end
if (FlatIdent_494F6 == 1) then
if ((v337.EnumType == Enum.UserInputType) or (4843 == 4084)) then
return v336.UserInputType == v337;
end
return v336.KeyCode == v337;
end
end
end
v39.InputBegan:Connect(function(v338, v339)
local FlatIdent_5EE26 = 0;
local v340;
local v341;
while true do
if (FlatIdent_5EE26 == 0) then
v340 = (v338.UserInputType == Enum.UserInputType.MouseButton1) or (v338.UserInputType == Enum.UserInputType.MouseButton2);
if ((4669 > 363) and ((v339 and not v340) or (4276 <= 3031))) then
return;
end
FlatIdent_5EE26 = 1;
end
if (FlatIdent_5EE26 == 1) then
if not v43("aim_enabled", true) then
return;
end
if (v44(v43("aim_activation", {"Toggle"}), "Toggle") == "Toggle") then
else
return;
end
FlatIdent_5EE26 = 2;
end
if (FlatIdent_5EE26 == 3) then
v341 = v107();
if (((4839 >= 3700) and v341) or (1877 >= 3138)) then
v48.locked = v341;
end
break;
end
if (FlatIdent_5EE26 == 2) then
if (not v112(v338) or (4782 <= 1199)) then
return;
end
if (v48.locked or (4864 < 1902)) then
local FlatIdent_4508F = 0;
while true do
if (FlatIdent_4508F == 0) then
v48.locked = nil;
return;
end
end
end
FlatIdent_5EE26 = 3;
end
end
end);
v48.step = function(v342)
local FlatIdent_284EA = 0;
local v343;
local v344;
local v345;
local v346;
local v349;
local v350;
local v351;
while true do
if (FlatIdent_284EA == 0) then
v343 = v41.CurrentCamera;
if ((4742 >= 3626) and not v343) then
return;
end
if (v103 or (4540 == 916)) then
local FlatIdent_4FF01 = 0;
while true do
if (FlatIdent_4FF01 == 1) then
v103.Visible = v43("aim_enabled", true) and v43("aim_fov_visualise", false);
break;
end
if (FlatIdent_4FF01 == 0) then
v103.Position = Vector2.new(v343.ViewportSize.X / 2, v343.ViewportSize.Y / 2);
v103.Radius = v43("aim_fov", 120);
FlatIdent_4FF01 = 1;
end
end
end
FlatIdent_284EA = 1;
end
if (FlatIdent_284EA == 4) then
v350 = math.clamp(v43("aim_smooth", 0) / 100, 0, 1);
v351 = CFrame.new(v343.CFrame.Position, v349);
if ((3373 <= 3556) and (v350 <= 0)) then
v343.CFrame = v351;
else
local FlatIdent_6E2DE = 0;
local v962;
local v963;
while true do
if (FlatIdent_6E2DE == 1) then
v343.CFrame = v343.CFrame:Lerp(v351, v963);
break;
end
if (FlatIdent_6E2DE == 0) then
v962 = 1 - ((v350 ^ 0.6) * 0.97);
v963 = 1 - ((1 - v962) ^ (v342 * 60));
FlatIdent_6E2DE = 1;
end
end
end
break;
end
if (FlatIdent_284EA == 2) then
if ((2237 < 4249) and ((v344 == "Hold") or (1075 > 1918))) then
local v959 = false;
local v960 = v46(v43("aim_key", Enum.UserInputType.MouseButton2));
if (((396 <= 3804) and (typeof(v960) == "EnumItem")) or (2683 < 23)) then
if (v960.EnumType == Enum.UserInputType) then
v959 = v39:IsMouseButtonPressed(v960);
else
v959 = v47(v960);
end
end
if v959 then
v345 = v107();
end
elseif ((697 <= 826) and (v48.locked or (4169 == 2187))) then
local FlatIdent_1A6D6 = 0;
local v1130;
local v1131;
while true do
if (FlatIdent_1A6D6 == 0) then
v1130 = v48.locked.Character;
v1131 = v1130 and v1130:FindFirstChildOfClass("Humanoid");
FlatIdent_1A6D6 = 1;
end
if (FlatIdent_1A6D6 == 1) then
if ((1406 == 1406) and v1130 and v1131 and (v1131.Health > 0)) then
v345 = v48.locked;
else
v48.locked = nil;
end
break;
end
end
end
v346 = nil;
if ((1531 < 4271) and v345 and v345.Character) then
v346 = v104(v345.Character, v44(v43("aim_hit_part", {"Head"}), "Head"));
end
FlatIdent_284EA = 3;
end
if (FlatIdent_284EA == 3) then
v48.player, v48.part = v345, v346;
if ((1105 <= 1176) and (635 == 635) and not v346) then
return;
end
v349 = v346.Position + (v45(v346) * v43("aim_prediction", 0)) + Vector3.new(0, v43("aim_y_offset", -0.6), 0);
FlatIdent_284EA = 4;
end
if (1 == FlatIdent_284EA) then
if (not v43("aim_enabled", true) or (1156 > 4345)) then
local FlatIdent_E2D0 = 0;
while true do
if (FlatIdent_E2D0 == 0) then
v48.player, v48.part, v48.locked = nil, nil, nil;
return;
end
end
end
v344 = v44(v43("aim_activation", {"Toggle"}), "Toggle");
v345 = nil;
FlatIdent_284EA = 2;
end
end
end;
getgenv().TeaAim = v48;
end
do
local v115 = {};
local v116 = getgenv().config or {};
getgenv().config = v116;
v115.get_gun = function()
local FlatIdent_86BC3 = 0;
local v352;
while true do
if (FlatIdent_86BC3 == 0) then
v352 = v42.Character;
if (not v352 or (3291 < 3280)) then
return nil;
end
FlatIdent_86BC3 = 1;
end
if (FlatIdent_86BC3 == 1) then
for v801, v802 in next, v352:GetChildren() do
if ((3379 <= 3812) and v802:IsA("Tool") and v802:FindFirstChild("Ammo")) then
return v802;
end
end
return nil;
end
end
end;
v115.rapid = function(v353)
v353:Activate();
end;
getgenv().is_firing = false;
local function v121()
while getgenv().is_firing do
v116.enable = v43("rapid_enabled", false);
v116.rate = math.max(v43("rapid_rate", 300), 1);
v116.delay = 1 / v116.rate;
if (((4386 >= 873) and not v116.enable) or (788 >= 1616)) then
getgenv().is_firing = false;
break;
end
local v806 = v115.get_gun();
if ((921 <= 1102) and v806) then
local FlatIdent_32BB2 = 0;
local v1054;
while true do
if (FlatIdent_32BB2 == 0) then
v1054 = 1;
if ((1854 <= 3379) and (v116.rate >= 60)) then
v1054 = math.max(1, math.floor((v116.rate / 60) + 0.5));
end
FlatIdent_32BB2 = 1;
end
if (FlatIdent_32BB2 == 1) then
for v1132 = 1, v1054 do
if ((4549 == 4549) and not getgenv().is_firing) then
break;
end
v115.rapid(v806);
end
break;
end
end
elseif (((4706 >= 963) and v43("rapid_require_ammo", true)) or (3022 >= 3024)) then
getgenv().is_firing = false;
break;
end
if ((v116.rate >= 60) or (960 <= 876)) then
v38.Heartbeat:Wait();
else
task.wait(v116.delay);
end
end
end
v39.InputBegan:Connect(function(v354)
if (v354.UserInputType == Enum.UserInputType.MouseButton1) then
else
return;
end
if ((4820 > 2198) and not v43("rapid_enabled", false)) then
return;
end
if ((v115.get_gun() == nil) or (2066 == 932) or (1061 >= 4891)) then
return;
end
if ((4825 < 4843) and getgenv().is_firing) then
return;
end
getgenv().is_firing = true;
task.spawn(v121);
end);
v39.InputEnded:Connect(function(v356)
if ((1364 <= 4473) and (v356.UserInputType == Enum.UserInputType.MouseButton1)) then
getgenv().is_firing = false;
end
end);
end
do
local v122 = {};
local function v123(v357)
local FlatIdent_125A6 = 0;
local v358;
local v359;
local v360;
while true do
if (FlatIdent_125A6 == 0) then
v358 = v44(v43("hitbox_part", {"HumanoidRootPart"}), "HumanoidRootPart");
v359 = {};
FlatIdent_125A6 = 1;
end
if (FlatIdent_125A6 == 2) then
if ((v358 == "Head") or (4315 < 1726) or (3595 <= 3)) then
v360("Head");
elseif ((v358 == "Torso") or (4672 == 3852)) then
local FlatIdent_2DA99 = 0;
while true do
if (FlatIdent_2DA99 == 0) then
v360("Torso");
v360("UpperTorso");
break;
end
end
elseif (v358 == "UpperTorso") then
v360("UpperTorso");
elseif (v358 == "LowerTorso") then
v360("LowerTorso");
elseif ((1559 == 1559) and ((v358 == "All Body") or (3679 < 625))) then
local FlatIdent_74083 = 0;
while true do
if (FlatIdent_74083 == 0) then
v360("HumanoidRootPart");
v360("Head");
FlatIdent_74083 = 1;
end
if (FlatIdent_74083 == 2) then
v360("LowerTorso");
break;
end
if (FlatIdent_74083 == 1) then
v360("Torso");
v360("UpperTorso");
FlatIdent_74083 = 2;
end
end
else
v360("HumanoidRootPart");
end
return v359;
end
if (1 == FlatIdent_125A6) then
v360 = nil;
function v360(v807)
local FlatIdent_5E109 = 0;
local v808;
while true do
if (FlatIdent_5E109 == 0) then
v808 = v357:FindFirstChild(v807);
if ((v808 and v808:IsA("BasePart")) or (3877 >= 4537)) then
table.insert(v359, v808);
end
break;
end
end
end
FlatIdent_125A6 = 2;
end
end
end
local function v124(v361)
local FlatIdent_834A0 = 0;
local v362;
while true do
if (FlatIdent_834A0 == 1) then
v122[v361] = nil;
for v809, v810 in v362 do
if ((v809 and v809.Parent) or (83 > 1780) or (3907 == 177)) then
pcall(function()
local FlatIdent_662A6 = 0;
while true do
if (FlatIdent_662A6 == 1) then
v809.CanCollide = v810.CanCollide;
break;
end
if (FlatIdent_662A6 == 0) then
v809.Size = v810.Size;
v809.Transparency = v810.Transparency;
FlatIdent_662A6 = 1;
end
end
end);
end
end
break;
end
if (FlatIdent_834A0 == 0) then
v362 = v122[v361];
if (not v362 or (4625 < 632) or (1752 <= 788)) then
return;
end
FlatIdent_834A0 = 1;
end
end
end
local function v125(v364)
local FlatIdent_3AF6C = 0;
local v365;
local v366;
local v367;
local v368;
while true do
if (FlatIdent_3AF6C == 0) then
v365 = v122[v364];
if ((3470 > 555) and not v365) then
local FlatIdent_31ECC = 0;
while true do
if (FlatIdent_31ECC == 0) then
v365 = {};
v122[v364] = v365;
break;
end
end
end
FlatIdent_3AF6C = 1;
end
if (FlatIdent_3AF6C == 2) then
v368 = Vector3.new(v366, v366, v366);
for v811, v812 in v123(v364) do
if not v365[v812] then
v365[v812] = {Size=v812.Size,Transparency=v812.Transparency,CanCollide=v812.CanCollide};
end
pcall(function()
v812.Size = v368;
v812.Transparency = v367;
v812.CanCollide = false;
end);
end
break;
end
if (1 == FlatIdent_3AF6C) then
v366 = v43("hitbox_size", 12);
v367 = v43("hitbox_transparency", 0.6);
FlatIdent_3AF6C = 2;
end
end
end
v48.sweep_hitboxes = function()
local FlatIdent_2A644 = 0;
local v369;
local v370;
while true do
if (FlatIdent_2A644 == 0) then
if ((546 <= 1077) and not v43("hitbox_enabled", false)) then
local FlatIdent_1A02A = 0;
while true do
if (FlatIdent_1A02A == 0) then
for v1056 in v122 do
v124(v1056);
end
return;
end
end
end
v369 = {};
FlatIdent_2A644 = 1;
end
if (FlatIdent_2A644 == 1) then
v370 = v44(v43("hitbox_target", {"All Players"}), "All Players");
if ((v370 == "Aim Target") or (972 == 645)) then
local FlatIdent_8E5B4 = 0;
local v970;
while true do
if (FlatIdent_8E5B4 == 0) then
v970 = v48.player and v48.player.Character;
if v970 then
v369[v970] = true;
end
break;
end
end
else
for v1057, v1058 in v37:GetPlayers() do
if ((3182 >= 2115) and (((v1058 ~= v42) and v1058.Character) or (996 > 4301))) then
local v1171 = v1058.Character:FindFirstChildOfClass("Humanoid");
if ((3893 < 4429) and v1171 and (v1171.Health > 0)) then
v369[v1058.Character] = true;
end
end
end
end
FlatIdent_2A644 = 2;
end
if (FlatIdent_2A644 == 2) then
for v813 in v122 do
if not v369[v813] then
v124(v813);
end
end
for v814 in v369 do
v125(v814);
end
break;
end
end
end;
getgenv().TeaHitboxRestore = function()
for v815 in v122 do
v124(v815);
end
end;
end
local v49 = {};
do
local v128 = {instance=nil};
local v129 = {instance=nil};
local function v130(v371)
return v371:FindFirstChild("LowerTorso") or v371:FindFirstChild("Torso");
end
local function v131(v372)
local v373 = v130(v372);
if not v373 then
return nil;
end
local v374 = Instance.new("Attachment");
v374.Name = "TeaAura";
local v376 = Instance.new("ParticleEmitter");
v376.Name = "Healing Wave 1";
v376.Lifetime = NumberRange.new(1.5, 1.5);
v376.SpreadAngle = Vector2.new(10, -10);
v376.LockedToPart = true;
v376.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1),NumberSequenceKeypoint.new(0.1702454, 0.7, 0.014881),NumberSequenceKeypoint.new(0.2254601, 0.03125, 0.03125),NumberSequenceKeypoint.new(0.2852761, 0),NumberSequenceKeypoint.new(0.702454, 0),NumberSequenceKeypoint.new(0.8374233, 0.9125, 0.0601461),NumberSequenceKeypoint.new(1, 1)});
v376.LightEmission = 0.4;
v376.Color = ColorSequence.new(Color3.fromRGB(234, 8, 255));
v376.VelocitySpread = 10;
v376.Speed = NumberRange.new(3, 6);
v376.Brightness = 10;
v376.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 3.0624998, 1.8805969),NumberSequenceKeypoint.new(0.6420546, 1.9999999, 1.7619393),NumberSequenceKeypoint.new(1, 0.7499999, 0.7499999)});
v376.Rate = 20;
v376.Texture = "rbxassetid://8047533775";
v376.RotSpeed = NumberRange.new(200, 400);
v376.Rotation = NumberRange.new(-180, 180);
v376.Orientation = Enum.ParticleOrientation.VelocityPerpendicular;
v376.Parent = v374;
local v395 = Instance.new("ParticleEmitter");
v395.Name = "Healing Wave 2";
v395.Lifetime = NumberRange.new(1.5, 1.5);
v395.SpreadAngle = Vector2.new(10, -10);
v395.LockedToPart = true;
v395.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1),NumberSequenceKeypoint.new(0.2254601, 0.03125, 0.03125),NumberSequenceKeypoint.new(0.6288344, 0.25625, 0.0593491),NumberSequenceKeypoint.new(0.8374233, 0.9125, 0.0601461),NumberSequenceKeypoint.new(1, 1)});
v395.LightEmission = 1;
v395.Color = ColorSequence.new(Color3.fromRGB(238, 3, 255));
v395.VelocitySpread = 10;
v395.Speed = NumberRange.new(3, 5);
v395.Brightness = 10;
v395.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 3.125),NumberSequenceKeypoint.new(0.4165329, 1.3749999, 1.3749999),NumberSequenceKeypoint.new(1, 0.9375, 0.9375)});
v395.Rate = 20;
v395.Texture = "rbxassetid://8047796070";
v395.RotSpeed = NumberRange.new(100, 300);
v395.Rotation = NumberRange.new(-180, 180);
v395.Orientation = Enum.ParticleOrientation.VelocityPerpendicular;
v395.Parent = v374;
local v413 = Instance.new("ParticleEmitter");
v413.Name = "Sparks";
v413.Lifetime = NumberRange.new(0.5, 2);
v413.SpreadAngle = Vector2.new(180, -180);
v413.LightEmission = 1;
v413.Color = ColorSequence.new(Color3.fromRGB(255, 21, 255));
v413.Drag = 3;
v413.VelocitySpread = 180;
v413.Speed = NumberRange.new(5, 15);
v413.Brightness = 10;
v413.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0),NumberSequenceKeypoint.new(0.14687, 0.4374999, 0.1875001),NumberSequenceKeypoint.new(1, 0)});
v413.Acceleration = Vector3.new(0, 3, 0);
v413.ZOffset = -1;
v413.Rate = 40;
v413.Texture = "rbxassetid://8611887361";
v413.RotSpeed = NumberRange.new(-30, 30);
v413.Orientation = Enum.ParticleOrientation.VelocityParallel;
v413.Parent = v374;
local v432 = Instance.new("ParticleEmitter");
v432.Name = "Star Sparks";
v432.Lifetime = NumberRange.new(1.5, 1.5);
v432.SpreadAngle = Vector2.new(180, -180);
v432.LightEmission = 1;
v432.Color = ColorSequence.new(Color3.fromRGB(226, 60, 255));
v432.Drag = 3;
v432.VelocitySpread = 180;
v432.Speed = NumberRange.new(5, 10);
v432.Brightness = 10;
v432.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0),NumberSequenceKeypoint.new(0.1492777, 0.6874996, 0.6874996),NumberSequenceKeypoint.new(1, 0)});
v432.Acceleration = Vector3.new(0, 3, 0);
v432.ZOffset = 2;
v432.Texture = "rbxassetid://8611887703";
v432.RotSpeed = NumberRange.new(-30, 30);
v432.Rotation = NumberRange.new(-30, 30);
v432.Parent = v374;
v374.Parent = v373;
return v374;
end
local function v132(v450)
local v451 = v450:FindFirstChild("Head");
if not v451 then
return nil;
end
local v452 = Instance.new("Part");
v452.Name = "TeaChinaHat";
v452.Size = Vector3.new(1, 1, 1);
v452.BrickColor = BrickColor.new("Hot pink");
v452.Material = Enum.Material.Neon;
v452.Transparency = 0.2;
v452.Anchored = false;
v452.CanCollide = false;
v452.Massless = true;
v452.CastShadow = false;
v452.Color = Color3.fromRGB(255, 105, 180);
local v464 = Instance.new("SpecialMesh");
v464.MeshType = Enum.MeshType.FileMesh;
v464.MeshId = "rbxassetid://1033714";
v464.Scale = Vector3.new(1.7, 1.1, 1.7);
v464.Parent = v452;
local v470 = Instance.new("Weld");
v470.Part0 = v451;
v470.Part1 = v452;
v470.C0 = CFrame.new(0, 0.9, 0);
v470.Parent = v452;
local v475 = Instance.new("PointLight");
v475.Color = Color3.fromRGB(255, 105, 180);
v475.Brightness = 0;
v475.Range = 12;
v475.Shadows = true;
v475.Parent = v452;
v452.Parent = v450;
return v452;
end
v49.step = function()
local FlatIdent_2593F = 0;
local v482;
local v483;
local v484;
local v485;
local v486;
while true do
if (FlatIdent_2593F == 3) then
if (v485 and not v486) then
local FlatIdent_512FF = 0;
while true do
if (FlatIdent_512FF == 0) then
if v129.instance then
v129.instance:Destroy();
end
v129.instance = v132(v482);
break;
end
end
elseif (not v485 and v129.instance) then
local FlatIdent_7093B = 0;
while true do
if (0 == FlatIdent_7093B) then
v129.instance:Destroy();
v129.instance = nil;
break;
end
end
end
break;
end
if (FlatIdent_2593F == 0) then
v482 = v42.Character;
v483 = v43("avatar_aura", false) and v482;
FlatIdent_2593F = 1;
end
if (FlatIdent_2593F == 1) then
v484 = v128.instance and v128.instance.Parent and (v128.instance.Parent == (v482 and v130(v482)));
if ((4070 > 687) and v483 and not v484) then
local FlatIdent_89917 = 0;
while true do
if (FlatIdent_89917 == 0) then
if (v128.instance or (2867 < 1905)) then
v128.instance:Destroy();
end
v128.instance = v131(v482);
break;
end
end
elseif ((not v483 and v128.instance) or (656 >= 3330) or (1796 >= 4051)) then
local FlatIdent_985A2 = 0;
while true do
if (FlatIdent_985A2 == 0) then
v128.instance:Destroy();
v128.instance = nil;
break;
end
end
end
FlatIdent_2593F = 2;
end
if (FlatIdent_2593F == 2) then
v485 = v43("avatar_china_hat", false) and v482;
v486 = v129.instance and v129.instance.Parent and (v129.instance.Parent == v482);
FlatIdent_2593F = 3;
end
end
end;
end
local v50 = {humanoid=nil,original=nil};
v50.step = function()
local FlatIdent_829F9 = 0;
local v134;
local v135;
local v136;
while true do
if (FlatIdent_829F9 == 0) then
v134 = v42.Character;
v135 = v134 and v134:FindFirstChildOfClass("Humanoid");
FlatIdent_829F9 = 1;
end
if (1 == FlatIdent_829F9) then
v136 = v43("macro_enabled", false) and v135;
if ((1619 <= 3756) and v136) then
if ((604 == 604) and ((v50.humanoid ~= v135) or (2492 <= 335))) then
local FlatIdent_3ACCC = 0;
while true do
if (FlatIdent_3ACCC == 0) then
v50.humanoid = v135;
v50.original = v135.WalkSpeed;
break;
end
end
end
local v816 = v43("macro_walkspeed", 100);
if (v135.WalkSpeed == v816) then
else
v135.WalkSpeed = v816;
end
elseif v50.humanoid then
local FlatIdent_77478 = 0;
while true do
if (FlatIdent_77478 == 0) then
if (((4322 >= 2562) and v50.humanoid.Parent and v50.original) or (4484 == 900)) then
v50.humanoid.WalkSpeed = v50.original;
end
v50.humanoid = nil;
FlatIdent_77478 = 1;
end
if (1 == FlatIdent_77478) then
v50.original = nil;
break;
end
end
end
break;
end
end
end;
local v52 = {active=false};
do
local FlatIdent_145D2 = 0;
local v137;
local v138;
local v139;
while true do
if (FlatIdent_145D2 == 3) then
getgenv().TeaLegit = v52;
break;
end
if (FlatIdent_145D2 == 0) then
v137 = game:GetService("VirtualInputManager");
v138 = nil;
FlatIdent_145D2 = 1;
end
if (FlatIdent_145D2 == 1) then
function v138(v487)
v137:SendMouseWheelEvent(0.1, 0.1, v487, game);
end
v139 = nil;
FlatIdent_145D2 = 2;
end
if (2 == FlatIdent_145D2) then
function v139()
while v52.active do
if (not v43("legit_enabled", false) or (4459 <= 1113)) then
v52.active = false;
break;
end
v38.Heartbeat:Wait();
v138(true);
local v817 = v43("legit_delay", 0) / 1000;
if (v817 <= 0) then
else
task.wait(v817);
end
v38.Heartbeat:Wait();
v138(false);
v38.Heartbeat:Wait();
end
end
v39.InputBegan:Connect(function(v488, v489)
if (v489 or (3637 >= 3770)) then
return;
end
if ((3632 > 3398) and (not v43("legit_enabled", false) or (2379 > 4578))) then
return;
end
if ((4082 <= 4917) and ((v488.KeyCode ~= v46(v43("legit_key", Enum.KeyCode.X))) or (483 > 743))) then
return;
end
if v52.active then
v52.active = false;
else
v52.active = true;
task.spawn(v139);
end
end);
FlatIdent_145D2 = 3;
end
end
end
local v53 = {};
do
local v141 = (typeof(Drawing) == "table") and (type(Drawing.new) == "function");
local v142 = {};
if ((4832 >= 1386) and (2454 > 578) and v141) then
for v975 = 1, 8 do
local FlatIdent_16C12 = 0;
local v976;
while true do
if (0 == FlatIdent_16C12) then
v976 = Drawing.new("Line");
v976.Visible = false;
FlatIdent_16C12 = 1;
end
if (FlatIdent_16C12 == 1) then
v976.Thickness = 1.5;
v142[v975] = v976;
break;
end
end
end
end
local function v143(v490, v491)
return Vector2.new(math.sin(math.rad(v490)) * v491, math.cos(math.rad(v490)) * v491);
end
v53.step = function()
local FlatIdent_C595 = 0;
local v492;
local v493;
local v494;
local v495;
local v496;
local v497;
local v498;
while true do
if (FlatIdent_C595 == 1) then
if ((137 == 137) and (930 < 4458) and (not v492 or not v41.CurrentCamera)) then
return;
end
v493 = v21['crosshair_color'] or Color3.fromRGB(255, 255, 255);
v494 = v39:GetMouseLocation();
FlatIdent_C595 = 2;
end
if (FlatIdent_C595 == 3) then
v498 = 10;
for v820 = 1, 4 do
local FlatIdent_92514 = 0;
local v821;
local v822;
local v823;
while true do
if (FlatIdent_92514 == 0) then
v821 = v142[v820];
v822 = v142[v820 + 4];
v823 = (v820 - 1) * 90;
FlatIdent_92514 = 1;
end
if (FlatIdent_92514 == 2) then
v822.From = v494 + v143(v823, v496);
v822.To = v494 + v143(v823, v496 + v498);
v822.Thickness = v497;
FlatIdent_92514 = 3;
end
if (FlatIdent_92514 == 3) then
v821.Color = v493;
v821.From = v494 + v143(v823, v496 - 1);
v821.To = v494 + v143(v823, v496 + v498 + 1);
FlatIdent_92514 = 4;
end
if (FlatIdent_92514 == 1) then
if (v43("crosshair_spin", true) or (1570 >= 4332)) then
local FlatIdent_6E214 = 0;
local v1066;
while true do
if (FlatIdent_6E214 == 0) then
v1066 = (-v495 * 150) % 340;
v823 = v823 + (v40:GetValue(v1066 / 360, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut) * 360);
break;
end
end
end
if (v43("crosshair_resize", true) or (4064 <= 1819)) then
local FlatIdent_90E07 = 0;
local v1067;
while true do
if (FlatIdent_90E07 == 0) then
v1067 = (v495 * 150) % 180;
v498 = 5 + (math.sin(math.rad(v1067)) * 22);
break;
end
end
end
v822.Color = v493;
FlatIdent_92514 = 2;
end
if (FlatIdent_92514 == 4) then
v821.Thickness = v497 + 1.5;
break;
end
end
end
break;
end
if (0 == FlatIdent_C595) then
if not v141 then
return;
end
v492 = v43("crosshair_enabled", false);
for v818 = 1, 8 do
v142[v818].Visible = v492;
end
FlatIdent_C595 = 1;
end
if (FlatIdent_C595 == 2) then
v495 = tick();
v496 = 11;
v497 = 1.5;
FlatIdent_C595 = 3;
end
end
end;
end
local v54 = {active=false,target=nil,angle=0,auto_rotate=true,auto_state=nil,last_position=nil};
do
local v145 = Vector3.zero;
local function v146(v499)
local FlatIdent_96E11 = 0;
local v500;
while true do
if (0 == FlatIdent_96E11) then
v500 = v499 and v499.Character;
return v500 and v500:FindFirstChild("HumanoidRootPart");
end
end
end
local function v147(v501)
local FlatIdent_8A9D7 = 0;
local v502;
while true do
if (FlatIdent_8A9D7 == 0) then
v502 = v501 and v501.Character;
return v502 and v502:FindFirstChildOfClass("Humanoid");
end
end
end
local function v148(v503)
local FlatIdent_14454 = 0;
local v504;
while true do
if (FlatIdent_14454 == 0) then
v504 = v147(v503);
return (v504 ~= nil) and (v504.Health > 0) and (v146(v503) ~= nil);
end
end
end
local function v149()
local v505 = v146(v37.LocalPlayer);
local v506 = v41.CurrentCamera;
if (((662 <= 972) and (not v505 or not v506)) or (4986 < 1574)) then
return nil;
end
local v507 = Vector2.new(v506.ViewportSize.X / 2, v506.ViewportSize.Y / 2);
local v508 = v43("target_distance", 500);
local v509, v510 = nil, math.huge;
for v832, v833 in v37:GetPlayers() do
if ((4370 == 4370) and (v833 ~= v37.LocalPlayer) and v148(v833)) then
local FlatIdent_2DB3E = 0;
local v1068;
while true do
if (FlatIdent_2DB3E == 0) then
v1068 = v146(v833);
if ((v1068.Position - v505.Position).Magnitude > v508) then
else
local FlatIdent_3501F = 0;
local v1174;
local v1175;
while true do
if (0 == FlatIdent_3501F) then
v1174, v1175 = v506:WorldToViewportPoint(v1068.Position);
if ((4426 > 172) and (v1175 or (4762 <= 861))) then
local v1207 = (Vector2.new(v1174.X, v1174.Y) - v507).Magnitude;
if ((586 > 455) and (v1207 < v510)) then
v509, v510 = v833, v1207;
end
end
break;
end
end
end
break;
end
end
end
end
return v509;
end
local function v150()
local v511 = v146(v37.LocalPlayer);
local v512 = v147(v37.LocalPlayer);
if ((826 == 826) and v511) then
local FlatIdent_EF32 = 0;
while true do
if (0 == FlatIdent_EF32) then
v511.Anchored = false;
v511.AssemblyLinearVelocity = v145;
FlatIdent_EF32 = 1;
end
if (FlatIdent_EF32 == 1) then
v511.AssemblyAngularVelocity = v145;
break;
end
end
end
if (v512 or (1412 == 4264)) then
local FlatIdent_15F29 = 0;
while true do
if (FlatIdent_15F29 == 0) then
v512.AutoRotate = v54.auto_rotate;
if (v54.auto_state or (3168 < 2153)) then
pcall(function()
v512:ChangeState(v54.auto_state);
end);
end
break;
end
end
end
v54.active = false;
v54.target = nil;
v54.auto_state = nil;
v54.last_position = nil;
end
local function v151()
local FlatIdent_2C980 = 0;
local v517;
local v518;
local v519;
while true do
if (FlatIdent_2C980 == 0) then
v517 = v146(v37.LocalPlayer);
v518 = v147(v37.LocalPlayer);
if (not v517 or not v518 or (v518.Health <= 0) or (4019 > 4441)) then
return;
end
v519 = (v48.locked and v148(v48.locked) and v48.locked) or v149();
FlatIdent_2C980 = 1;
end
if (1 == FlatIdent_2C980) then
if not v519 then
return;
end
v517.Anchored = false;
v54.auto_rotate = v518.AutoRotate;
v54.auto_state = v518:GetState();
FlatIdent_2C980 = 2;
end
if (FlatIdent_2C980 == 3) then
v54.last_position = v517.Position;
v54.active = true;
break;
end
if (2 == FlatIdent_2C980) then
v518.AutoRotate = false;
pcall(function()
v518:ChangeState(Enum.HumanoidStateType.Physics);
end);
v54.target = v519;
v54.angle = 0;
FlatIdent_2C980 = 3;
end
end
end
v54.release = function()
v150();
end;
v54.toggle = function()
if ((2017 < 4261) and v54.active) then
v150();
else
v151();
end
end;
v39.InputBegan:Connect(function(v529, v530)
local FlatIdent_69D54 = 0;
while true do
if (FlatIdent_69D54 == 0) then
if v530 then
return;
end
if (not v43("orbit_enabled", false) or (4976 < 1332)) then
return;
end
FlatIdent_69D54 = 1;
end
if (FlatIdent_69D54 == 1) then
if ((4628 == 4628) and (v529.KeyCode ~= v46(v43("orbit_key", Enum.KeyCode.Q)))) then
return;
end
v54.toggle();
break;
end
end
end);
v54.step = function(v531)
if (not v43("orbit_enabled", false) or (54 == 395)) then
local FlatIdent_523B3 = 0;
while true do
if (FlatIdent_523B3 == 0) then
if ((82 == 82) and v54.active) then
v150();
end
return;
end
end
end
if ((4716 > 80) and (not v54.active or (581 < 282))) then
return;
end
local v532 = v146(v37.LocalPlayer);
local v533 = v147(v37.LocalPlayer);
if (not v532 or not v533 or (v533.Health <= 0) or (4609 < 2495) or (3507 == 3272)) then
local FlatIdent_74B46 = 0;
while true do
if (FlatIdent_74B46 == 0) then
v150();
return;
end
end
end
if (((1152 == 1152) and not v148(v54.target)) or (876 >= 3075)) then
local FlatIdent_86023 = 0;
local v985;
while true do
if (FlatIdent_86023 == 1) then
v54.target = v985;
break;
end
if (0 == FlatIdent_86023) then
v985 = (v48.locked and v148(v48.locked) and v48.locked) or v149();
if ((4352 > 2554) and not v985) then
local FlatIdent_66A15 = 0;
while true do
if (FlatIdent_66A15 == 0) then
v150();
return;
end
end
end
FlatIdent_86023 = 1;
end
end
end
local v534 = v43("orbit_height", 5.4);
local v535 = v54.target.Character:FindFirstChild("Head");
local v536 = (v535 and (v535.Position + Vector3.new(0, v534, 0))) or (v146(v54.target).Position + Vector3.new(0, v534 + 1.5, 0));
v54.angle = (v54.angle + (v43("orbit_speed", 12) * v531)) % (math.pi * 2);
local v538 = v43("orbit_radius", 8);
local v539 = v536 + Vector3.new(math.cos(v54.angle) * v538, 0, math.sin(v54.angle) * v538);
v532.CFrame = CFrame.lookAt(v539, v536);
local v541 = v54.last_position or v539;
v54.last_position = v539;
local v543 = math.max(v531, 1 / 240);
local v544 = (v539 - v541) / v543;
if ((1896 <= 3422) and (v544.Magnitude > 200)) then
v544 = v544.Unit * 200;
end
v532.AssemblyLinearVelocity = v544;
v532.AssemblyAngularVelocity = v145;
end;
getgenv().TeaOrbit = v54;
end
local v55 = {active=false,held={}};
do
local function v156()
local FlatIdent_30B1F = 0;
local v547;
while true do
if (FlatIdent_30B1F == 0) then
v547 = v37.LocalPlayer and v37.LocalPlayer.Character;
return v547 and v547:FindFirstChild("HumanoidRootPart");
end
end
end
local function v157(v548, v549)
local FlatIdent_8CB90 = 0;
local v550;
while true do
if (FlatIdent_8CB90 == 0) then
v550 = v46(v549);
if ((typeof(v550) ~= "EnumItem") or (990 > 1620) or (4406 < 4043)) then
return false;
end
FlatIdent_8CB90 = 1;
end
if (FlatIdent_8CB90 == 1) then
if ((v550.EnumType == Enum.UserInputType) or (1889 >= 3383)) then
return v548.UserInputType == v550;
end
return v548.KeyCode == v550;
end
end
end
local function v158()
local FlatIdent_947A = 0;
local v551;
local v552;
while true do
if (FlatIdent_947A == 1) then
if ((1892 <= 2734) and (((v551 == 0) and (v552 == 0)) or (877 > 4695))) then
return nil;
end
return v551, v552;
end
if (FlatIdent_947A == 0) then
v551 = ((v55.held[Enum.KeyCode.W] and 1) or 0) - ((v55.held[Enum.KeyCode.S] and 1) or 0);
v552 = ((v55.held[Enum.KeyCode.D] and 1) or 0) - ((v55.held[Enum.KeyCode.A] and 1) or 0);
FlatIdent_947A = 1;
end
end
end
v39.InputBegan:Connect(function(v553, v554)
local FlatIdent_87441 = 0;
while true do
if (FlatIdent_87441 == 0) then
v55.held[v553.KeyCode] = true;
if ((1923 < 2218) and (2691 >= 1851) and v554) then
return;
end
FlatIdent_87441 = 1;
end
if (FlatIdent_87441 == 2) then
if v43("cspeed_hold", false) then
v55.active = true;
else
v55.active = not v55.active;
end
break;
end
if (FlatIdent_87441 == 1) then
if ((2173 > 379) and (not v43("cspeed_enabled", false) or (2985 >= 4856))) then
return;
end
if ((4276 >= 1195) and not v157(v553, v43("cspeed_key", Enum.KeyCode.LeftAlt))) then
return;
end
FlatIdent_87441 = 2;
end
end
end);
v39.InputEnded:Connect(function(v556)
v55.held[v556.KeyCode] = nil;
if (v43("cspeed_hold", false) or (2591 == 3409)) then
if ((3232 <= 4690) and v157(v556, v43("cspeed_key", Enum.KeyCode.LeftAlt))) then
v55.active = false;
end
end
end);
v55.step = function(v558)
local FlatIdent_52DF2 = 0;
local v559;
local v560;
local v561;
local v562;
local v563;
local v565;
local v566;
local v567;
while true do
if (FlatIdent_52DF2 == 1) then
if not v559 then
return;
end
v560, v561 = v158();
if (not v560 or (896 >= 3146)) then
return;
end
FlatIdent_52DF2 = 2;
end
if (FlatIdent_52DF2 == 3) then
v563 = v563.Unit;
v565 = Vector3.new(-v563.Z, 0, v563.X);
v566 = (v563 * v560) + (v565 * v561);
FlatIdent_52DF2 = 4;
end
if (FlatIdent_52DF2 == 0) then
if not v43("cspeed_enabled", false) then
v55.active = false;
return;
end
if ((4514 > 3324) and not v55.active) then
return;
end
v559 = v156();
FlatIdent_52DF2 = 1;
end
if (FlatIdent_52DF2 == 4) then
if (((3061 >= 2958) and (v566.Magnitude < 0.0010000000474974513)) or (1583 > 3567)) then
return;
end
v567 = math.min(v558, 1 / 20);
v559.CFrame = v559.CFrame + (v566.Unit * v43("cspeed_value", 60) * v567);
break;
end
if (FlatIdent_52DF2 == 2) then
v562 = v559.CFrame.LookVector;
v563 = Vector3.new(v562.X, 0, v562.Z);
if ((v563.Magnitude < 0.0010000000474974513) or (208 >= 4828)) then
return;
end
FlatIdent_52DF2 = 3;
end
end
end;
v55.release = function()
local FlatIdent_129E6 = 0;
while true do
if (0 == FlatIdent_129E6) then
v55.active = false;
v55.held = {};
break;
end
end
end;
getgenv().TeaSpeed = v55;
end
local v56 = {kind="None",last=0,rigs={},flash_at=0,atmo_owned=false,restored=false};
do
local v162 = game:GetService("Lighting");
local v163 = Color3.fromRGB(255, 255, 255);
local v164 = "rbxassetid://1316045217";
local v165 = {"Ambient","OutdoorAmbient","Brightness","ClockTime","ColorShift_Top","ColorShift_Bottom","FogColor","FogEnd","FogStart","ExposureCompensation"};
local v166 = {};
for v571, v572 in ipairs(v165) do
local FlatIdent_77CC3 = 0;
local v573;
local v574;
while true do
if (FlatIdent_77CC3 == 0) then
v573, v574 = pcall(function()
return v162[v572];
end);
if (v573 or (1313 == 794)) then
v166[v572] = v574;
end
break;
end
end
end
local v167 = v162:FindFirstChildOfClass("Atmosphere");
local v168 = nil;
if v167 then
v168 = {Density=v167.Density,Offset=v167.Offset,Color=v167.Color,Decay=v167.Decay,Glare=v167.Glare,Haze=v167.Haze};
end
local function v169(v575, v576, v577)
pcall(function()
v575[v576] = v577;
end);
end
local function v170(v578, v579)
return Color3.new(v578.R * v579.R, v578.G * v579.G, v578.B * v579.B);
end
local v171 = {Off={keep=true},Custom={custom=true,ambient=Color3.fromRGB(255, 255, 255),outdoor=Color3.fromRGB(255, 255, 255),top=Color3.fromRGB(255, 255, 255),bottom=Color3.fromRGB(255, 255, 255),fog=Color3.fromRGB(255, 255, 255),atmo={Density=0.34,Offset=0,Glare=1,Haze=2.5}},Red={ambient=Color3.fromRGB(120, 26, 26),outdoor=Color3.fromRGB(190, 60, 50),top=Color3.fromRGB(255, 96, 84),bottom=Color3.fromRGB(120, 22, 22),fog=Color3.fromRGB(160, 40, 36),atmo={Density=0.34,Offset=0,Decay=Color3.fromRGB(80, 14, 14),Glare=2,Haze=3}},Night={ambient=Color3.fromRGB(18, 22, 44),outdoor=Color3.fromRGB(26, 32, 60),top=Color3.fromRGB(20, 28, 70),bottom=Color3.fromRGB(6, 6, 14),fog=Color3.fromRGB(10, 14, 30),atmo={Density=0.42,Offset=-0.2,Decay=Color3.fromRGB(8, 10, 26),Glare=0,Haze=1.4}},Overcast={ambient=Color3.fromRGB(96, 102, 112),outdoor=Color3.fromRGB(128, 134, 144),top=Color3.fromRGB(170, 178, 190),bottom=Color3.fromRGB(120, 126, 136),fog=Color3.fromRGB(150, 158, 170),atmo={Density=0.46,Offset=0,Decay=Color3.fromRGB(120, 126, 136),Glare=0,Haze=5.5}},Storm={ambient=Color3.fromRGB(46, 52, 64),outdoor=Color3.fromRGB(60, 66, 78),top=Color3.fromRGB(78, 88, 104),bottom=Color3.fromRGB(38, 42, 52),fog=Color3.fromRGB(64, 70, 82),atmo={Density=0.52,Offset=0,Decay=Color3.fromRGB(40, 44, 54),Glare=0,Haze=7}},Dusk={ambient=Color3.fromRGB(62, 40, 46),outdoor=Color3.fromRGB(120, 78, 70),top=Color3.fromRGB(255, 138, 92),bottom=Color3.fromRGB(96, 44, 62),fog=Color3.fromRGB(180, 108, 92),atmo={Density=0.3,Offset=0.1,Decay=Color3.fromRGB(90, 40, 60),Glare=1.5,Haze=2.2}},Void={ambient=Color3.fromRGB(0, 0, 0),outdoor=Color3.fromRGB(0, 0, 0),top=Color3.fromRGB(0, 0, 0),bottom=Color3.fromRGB(0, 0, 0),fog=Color3.fromRGB(0, 0, 0),atmo={Density=0.6,Offset=0,Decay=Color3.fromRGB(0, 0, 0),Glare=0,Haze=0}}};
local v172 = {Snow={gravity=-3,layers={{rate=220,size=0.2,speed=NumberRange.new(4, 8),transparency=0.62,lifetime=NumberRange.new(18, 26),height=36,spread=Vector2.new(70, 70),rot=NumberRange.new(-30, 30)},{rate=340,size=0.34,speed=NumberRange.new(7, 12),transparency=0.34,lifetime=NumberRange.new(12, 18),height=27,spread=Vector2.new(50, 50),rot=NumberRange.new(-60, 60)},{rate=150,size=0.58,speed=NumberRange.new(11, 17),transparency=0.12,lifetime=NumberRange.new(8, 13),height=18,spread=Vector2.new(38, 38),rot=NumberRange.new(-90, 90)}}},Rain={gravity=-95,layers={{rate=820,size=0.55,speed=NumberRange.new(120, 165),transparency=0.32,lifetime=NumberRange.new(1.1, 1.7),height=28,spread=Vector2.new(7, 7),squash=0.05},{rate=460,size=0.34,speed=NumberRange.new(155, 205),transparency=0.55,lifetime=NumberRange.new(0.8, 1.2),height=32,spread=Vector2.new(5, 5),squash=0.04},{rate=130,size=1.1,speed=NumberRange.new(26, 44),transparency=0.9,lifetime=NumberRange.new(1.4, 2.2),height=14,spread=Vector2.new(45, 45),squash=1}}}};
v172.Storm = v172.Rain;
local v175 = nil;
local function v176()
local FlatIdent_586FF = 0;
while true do
if (FlatIdent_586FF == 0) then
for v835, v836 in ipairs(v56.rigs) do
pcall(function()
v836:Destroy();
end);
end
v56.rigs = {};
break;
end
end
end
local function v177()
local FlatIdent_8BBE3 = 0;
while true do
if (0 == FlatIdent_8BBE3) then
if ((3174 > 2902) and v175) then
return;
end
v175 = v38.RenderStepped:Connect(function()
local FlatIdent_77E47 = 0;
local v837;
while true do
if (FlatIdent_77E47 == 0) then
v837 = v41.CurrentCamera;
if ((3187 >= 644) and not v837) then
return;
end
FlatIdent_77E47 = 1;
end
if (FlatIdent_77E47 == 1) then
for v991, v992 in ipairs(v56.rigs) do
if ((4120 <= 4260) and v992.Parent) then
v992.CFrame = v837.CFrame * CFrame.new(0, v992:GetAttribute("Height") or 24, 0);
end
end
break;
end
end
end);
break;
end
end
end
local function v178(v581)
local FlatIdent_3416F = 0;
local v582;
while true do
if (FlatIdent_3416F == 1) then
v56.kind = v581;
if (((644 <= 704) and not v582) or (883 > 4778)) then
return;
end
FlatIdent_3416F = 2;
end
if (FlatIdent_3416F == 0) then
v176();
v582 = v172[v581];
FlatIdent_3416F = 1;
end
if (FlatIdent_3416F == 2) then
for v838, v839 in ipairs(v582.layers) do
local FlatIdent_2AA0C = 0;
local v840;
local v850;
while true do
if (FlatIdent_2AA0C == 4) then
v850.SpreadAngle = v839.spread;
v850.Rotation = v839.rot or NumberRange.new(0, 0);
v850.RotSpeed = NumberRange.new(-35, 35);
v850.Squash = NumberSequence.new(v839.squash or 1);
FlatIdent_2AA0C = 5;
end
if (FlatIdent_2AA0C == 3) then
v850.Name = "TeaWorldEmitter" .. v838;
v850.Texture = v164;
v850.Color = ColorSequence.new(v163);
v850.Lifetime = v839.lifetime;
FlatIdent_2AA0C = 4;
end
if (FlatIdent_2AA0C == 2) then
v840.Size = Vector3.new(190, 4, 190);
v840.Parent = v41;
v840:SetAttribute("Height", v839.height);
v850 = Instance.new("ParticleEmitter");
FlatIdent_2AA0C = 3;
end
if (FlatIdent_2AA0C == 1) then
v840.CanQuery = false;
v840.CanTouch = false;
v840.CastShadow = false;
v840.Transparency = 1;
FlatIdent_2AA0C = 2;
end
if (FlatIdent_2AA0C == 0) then
v840 = Instance.new("Part");
v840.Name = "TeaWorldRig" .. v838;
v840.Anchored = true;
v840.CanCollide = false;
FlatIdent_2AA0C = 1;
end
if (FlatIdent_2AA0C == 5) then
v850.EmissionDirection = Enum.NormalId.Bottom;
v850.LightEmission = 0;
v850.LightInfluence = 0;
v850.ZOffset = 1;
FlatIdent_2AA0C = 6;
end
if (FlatIdent_2AA0C == 6) then
v850.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, v839.transparency),NumberSequenceKeypoint.new(1, 1)});
pcall(function()
local FlatIdent_6619 = 0;
while true do
if (FlatIdent_6619 == 0) then
v850.Shape = Enum.ParticleEmitterShape.Box;
v850.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume;
FlatIdent_6619 = 1;
end
if (FlatIdent_6619 == 1) then
v850.ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward;
break;
end
end
end);
v850.Parent = v840;
table.insert(v56.rigs, v840);
break;
end
end
end
v177();
break;
end
end
end
local function v179()
local FlatIdent_59521 = 0;
local v584;
local v585;
local v586;
local v587;
local v588;
local v589;
local v590;
while true do
if (FlatIdent_59521 == 0) then
v584 = v44(v43("world_weather", {"None"}), "None");
if ((v584 ~= v56.kind) or (3620 >= 4891)) then
v178((v172[v584] and v584) or "None");
end
FlatIdent_59521 = 1;
end
if (FlatIdent_59521 == 2) then
v586 = v43("world_weather_size", 1);
v587 = v43("world_weather_speed", 100) / 100;
FlatIdent_59521 = 3;
end
if (FlatIdent_59521 == 3) then
v588 = v43("world_weather_rate", 55) / 55;
v589 = v43("world_weather_wind", 14);
FlatIdent_59521 = 4;
end
if (4 == FlatIdent_59521) then
v590 = v21['world_weather_color'] or Color3.fromRGB(235, 244, 255);
for v868, v869 in ipairs(v56.rigs) do
local v870 = v869:FindFirstChildOfClass("ParticleEmitter");
local v871 = v585.layers[v868];
if ((4258 > 937) and (958 > 947) and v870 and v871) then
local FlatIdent_7D00F = 0;
while true do
if (FlatIdent_7D00F == 2) then
v169(v870, "Acceleration", Vector3.new(v589, v585.gravity * v587, v589 * 0.35));
break;
end
if (FlatIdent_7D00F == 1) then
v169(v870, "Size", NumberSequence.new(v871.size * v586));
v169(v870, "Speed", NumberRange.new(v871.speed.Min * v587, v871.speed.Max * v587));
FlatIdent_7D00F = 2;
end
if (FlatIdent_7D00F == 0) then
v169(v870, "Rate", math.max(v871.rate * v588, 0));
v169(v870, "Color", ColorSequence.new(v590));
FlatIdent_7D00F = 1;
end
end
end
end
break;
end
if (FlatIdent_59521 == 1) then
v585 = v172[v56.kind];
if not v585 then
return;
end
FlatIdent_59521 = 2;
end
end
end
local function v180()
local FlatIdent_1246A = 0;
while true do
if (FlatIdent_1246A == 0) then
for v872, v873 in pairs(v166) do
v169(v162, v872, v873);
end
if ((v168 and v167) or (4869 < 906)) then
for v1069, v1070 in pairs(v168) do
v169(v167, v1069, v1070);
end
elseif v56.atmo_owned then
local FlatIdent_2B4B0 = 0;
local v1144;
while true do
if (FlatIdent_2B4B0 == 1) then
v56.atmo_owned = false;
break;
end
if (FlatIdent_2B4B0 == 0) then
v1144 = v162:FindFirstChild("TeaWorldAtmosphere");
if (v1144 or (1225 > 4228)) then
v1144:Destroy();
end
FlatIdent_2B4B0 = 1;
end
end
end
break;
end
end
end
local function v181()
local FlatIdent_1C72A = 0;
local v591;
local v592;
local v594;
local v595;
while true do
if (FlatIdent_1C72A == 5) then
v169(v595, "Color", v170(v592.top, v594.top));
if ((4695 >= 1415) and v592.custom) then
v169(v595, "Color", v594.top);
v169(v595, "Decay", Color3.new(v594.bottom.R * 0.55, v594.bottom.G * 0.55, v594.bottom.B * 0.55));
end
break;
end
if (FlatIdent_1C72A == 2) then
if (v43("world_fullbright", false) or (3170 <= 1464)) then
local FlatIdent_16207 = 0;
while true do
if (FlatIdent_16207 == 0) then
v169(v162, "Ambient", v163);
v169(v162, "OutdoorAmbient", v163);
break;
end
end
elseif (not v592.keep or (4797 == 4388)) then
local FlatIdent_7421A = 0;
while true do
if (FlatIdent_7421A == 0) then
v169(v162, "Ambient", v170(v592.ambient, v594.ambient));
v169(v162, "OutdoorAmbient", v170(v592.outdoor, v594.ambient));
break;
end
end
end
if v43("world_no_fog", false) then
local FlatIdent_45E15 = 0;
while true do
if (FlatIdent_45E15 == 0) then
v169(v162, "FogStart", 100000);
v169(v162, "FogEnd", 100000);
break;
end
end
else
local FlatIdent_59C45 = 0;
while true do
if (FlatIdent_59C45 == 0) then
if (((551 <= 681) and not v592.keep) or (1293 <= 507)) then
v169(v162, "FogColor", v170(v592.fog, v594.fog));
v169(v162, "FogStart", 0);
end
v169(v162, "FogEnd", v43("world_fog_end", 800));
break;
end
end
end
if (v592.keep or (2896 < 805)) then
return;
end
v169(v162, "ColorShift_Top", v170(v592.top, v594.top));
FlatIdent_1C72A = 3;
end
if (FlatIdent_1C72A == 1) then
v594 = {top=(v21['world_sky_top'] or v163),bottom=(v21['world_sky_bottom'] or v163),ambient=(v21['world_ambient'] or v163),fog=(v21['world_fog'] or v163)};
v169(v162, "Brightness", v43("world_brightness", 2));
v169(v162, "ClockTime", v43("world_clock", 14));
v169(v162, "ExposureCompensation", v43("world_exposure", 0));
FlatIdent_1C72A = 2;
end
if (FlatIdent_1C72A == 3) then
v169(v162, "ColorShift_Bottom", v170(v592.bottom, v594.bottom));
v595 = v167;
if ((2316 == 2316) and not v595) then
v595 = v162:FindFirstChild("TeaWorldAtmosphere");
if (((3277 > 407) and not v595) or (2570 == 1533)) then
local FlatIdent_31791 = 0;
while true do
if (FlatIdent_31791 == 0) then
v595 = Instance.new("Atmosphere");
v595.Name = "TeaWorldAtmosphere";
FlatIdent_31791 = 1;
end
if (1 == FlatIdent_31791) then
v595.Parent = v162;
v56.atmo_owned = true;
break;
end
end
end
end
v169(v595, "Density", v592.atmo.Density);
FlatIdent_1C72A = 4;
end
if (FlatIdent_1C72A == 4) then
v169(v595, "Offset", v592.atmo.Offset);
v169(v595, "Decay", v592.atmo.Decay);
v169(v595, "Glare", v592.atmo.Glare);
v169(v595, "Haze", v592.atmo.Haze);
FlatIdent_1C72A = 5;
end
if (FlatIdent_1C72A == 0) then
v591 = v44(v43("world_preset", {"Off"}), "Off");
v592 = v171[v591] or v171['Off'];
if ((3328 > 2238) and (4492 >= 2654) and v592.keep) then
local FlatIdent_19FC0 = 0;
while true do
if (0 == FlatIdent_19FC0) then
if ((3839 > 1405) and (3442 >= 1503) and not v56.restored) then
v180();
v56.restored = true;
end
return;
end
end
end
v56.restored = false;
FlatIdent_1C72A = 1;
end
end
end
local function v182()
local FlatIdent_58A9D = 0;
local v596;
local v597;
local v599;
while true do
if (FlatIdent_58A9D == 3) then
v599 = v43("world_brightness", 2);
task.spawn(function()
local FlatIdent_3DC2B = 0;
while true do
if (FlatIdent_3DC2B == 1) then
v169(v162, "Brightness", v599 + 1.2);
task.wait(0.05);
FlatIdent_3DC2B = 2;
end
if (FlatIdent_3DC2B == 0) then
v169(v162, "Brightness", v599 + 3.5);
task.wait(0.05);
FlatIdent_3DC2B = 1;
end
if (FlatIdent_3DC2B == 2) then
v169(v162, "Brightness", v599);
break;
end
end
end);
break;
end
if (1 == FlatIdent_58A9D) then
if ((not v43("world_lightning", false) and (v44(v43("world_weather", {"None"}), "None") ~= "Storm")) or (3096 <= 1798)) then
return;
end
v597 = os.clock();
FlatIdent_58A9D = 2;
end
if (FlatIdent_58A9D == 2) then
if (((3537 == 3537) and (v597 < v56.flash_at)) or (4619 <= 999)) then
return;
end
v56.flash_at = v597 + math.random(4, 10);
FlatIdent_58A9D = 3;
end
if (0 == FlatIdent_58A9D) then
v596 = v56.kind;
if (((v596 ~= "Rain") and (v596 ~= "Storm")) or (3212 <= 944) or (883 == 1460)) then
return;
end
FlatIdent_58A9D = 1;
end
end
end
v56.step = function()
local FlatIdent_1FF3C = 0;
local v600;
while true do
if (2 == FlatIdent_1FF3C) then
v179();
v182();
break;
end
if (FlatIdent_1FF3C == 0) then
v600 = os.clock();
if (((3837 >= 1570) and ((v600 - v56.last) < 0.12)) or (3410 > 4116)) then
return;
end
FlatIdent_1FF3C = 1;
end
if (1 == FlatIdent_1FF3C) then
v56.last = v600;
v181();
FlatIdent_1FF3C = 2;
end
end
end;
v56.release = function()
local FlatIdent_4E1DE = 0;
while true do
if (0 == FlatIdent_4E1DE) then
for v874, v875 in pairs(v166) do
v169(v162, v874, v875);
end
if ((v168 and v167) or (903 >= 3059)) then
for v1071, v1072 in pairs(v168) do
v169(v167, v1071, v1072);
end
elseif (v56.atmo_owned or (2950 == 3812)) then
local FlatIdent_8088E = 0;
local v1150;
while true do
if (FlatIdent_8088E == 0) then
v1150 = v162:FindFirstChild("TeaWorldAtmosphere");
if v1150 then
v1150:Destroy();
end
FlatIdent_8088E = 1;
end
if (1 == FlatIdent_8088E) then
v56.atmo_owned = false;
break;
end
end
end
FlatIdent_4E1DE = 1;
end
if (FlatIdent_4E1DE == 1) then
v176();
v56.kind = "None";
break;
end
end
end;
getgenv().TeaWorld = v56;
end
getgenv().TeaRuntimeConnection = v38.RenderStepped:Connect(function(v186)
local FlatIdent_3C1AA = 0;
while true do
if (3 == FlatIdent_3C1AA) then
v50.step();
v53.step();
break;
end
if (FlatIdent_3C1AA == 0) then
v48.step(v186);
v48.sweep_hitboxes();
FlatIdent_3C1AA = 1;
end
if (FlatIdent_3C1AA == 2) then
v56.step();
v49.step();
FlatIdent_3C1AA = 3;
end
if (FlatIdent_3C1AA == 1) then
v54.step(v186);
v55.step(v186);
FlatIdent_3C1AA = 2;
end
end
end);
getgenv().TeaUnload = function()
local FlatIdent_6C091 = 0;
while true do
if (FlatIdent_6C091 == 2) then
if (getgenv().TeaSpeed or (2027 > 2852)) then
pcall(getgenv().TeaSpeed.release);
end
getgenv().is_firing = false;
FlatIdent_6C091 = 3;
end
if (FlatIdent_6C091 == 0) then
pcall(function()
if getgenv().TeaRuntimeConnection then
getgenv().TeaRuntimeConnection:Disconnect();
getgenv().TeaRuntimeConnection = nil;
end
end);
pcall(getgenv().TeaHitboxRestore);
FlatIdent_6C091 = 1;
end
if (FlatIdent_6C091 == 3) then
if ((4930 > 2307) and v50.humanoid and v50.humanoid.Parent and v50.original) then
v50.humanoid.WalkSpeed = v50.original;
end
v50.humanoid = nil;
FlatIdent_6C091 = 4;
end
if (FlatIdent_6C091 == 4) then
v50.original = nil;
break;
end
if (FlatIdent_6C091 == 1) then
if (((4723 >= 2318) and getgenv().TeaOrbit) or (3976 < 2857)) then
pcall(getgenv().TeaOrbit.release);
end
if getgenv().TeaWorld then
pcall(getgenv().TeaWorld.release);
end
FlatIdent_6C091 = 2;
end
end
end;
do
local v190 = game:GetService("Players");
local v191 = game:GetService("RunService");
local v192 = v190.LocalPlayer;
local v193 = 128 ^ 2;
local v194 = 0.015;
local v195 = 0.5;
local v196 = 0.25;
local v197 = math.rad;
local v198 = math.random;
local v199 = math.clamp;
local v200 = CFrame.Angles;
local v201 = Vector3.new;
local v202 = sethiddenproperty;
local v203 = type(v202) == "function";
local v204 = game:GetService("Stats"):FindFirstChild("PerformanceStats");
v204 = v204 and v204:FindFirstChild("Ping");
local function v205(v603, v604)
local v605, v606 = pcall(v43, v603, v604);
if (v605 and (v606 ~= nil)) then
return v606;
end
return v604;
end
local function v206()
if not v204 then
return 100;
end
local v607, v608 = pcall(function()
return v204:GetValue();
end);
if ((v607 and (type(v608) == "number")) or (1136 > 4317)) then
return v608;
end
return 100;
end
task.spawn(function()
while true do
local FlatIdent_1BD19 = 0;
local v878;
local v879;
local v880;
local v881;
while true do
if (FlatIdent_1BD19 == 2) then
if ((4748 == 4748) and v878 and v203 and v880 and v881 and (v881.Health > 0)) then
local v1073 = v880.Velocity;
local v1074 = v198(-180, 180);
local v1075 = v201(v198(-v193, v193), -v198(0, v193), v198(-v193, v193));
local v1076 = pcall(function()
local FlatIdent_696E1 = 0;
while true do
if (FlatIdent_696E1 == 0) then
v880.CFrame = v880.CFrame * v200(0, v197(v1074), 0);
v880.Velocity = v1075;
break;
end
end
end);
if (v1076 or (4046 < 1291)) then
local FlatIdent_1F33B = 0;
local v1176;
local v1177;
while true do
if (FlatIdent_1F33B == 0) then
v191.RenderStepped:Wait();
pcall(function()
local FlatIdent_3ABA7 = 0;
while true do
if (FlatIdent_3ABA7 == 0) then
v880.CFrame = v880.CFrame * v200(0, v197(-v1074), 0);
v880.Velocity = v1073;
break;
end
end
end);
FlatIdent_1F33B = 1;
end
if (FlatIdent_1F33B == 1) then
v1176 = v191.Heartbeat:Connect(function()
pcall(v202, v880, "NetworkIsSleeping", true);
end);
v1177 = v191.RenderStepped:Connect(function()
pcall(v202, v880, "NetworkIsSleeping", true);
end);
FlatIdent_1F33B = 2;
end
if (FlatIdent_1F33B == 3) then
pcall(function()
v1177:Disconnect();
end);
pcall(v202, v880, "NetworkIsSleeping", false);
break;
end
if (FlatIdent_1F33B == 2) then
task.wait(v199(v206(), 0, v195 * 1000) / 1000);
pcall(function()
v1176:Disconnect();
end);
FlatIdent_1F33B = 3;
end
end
end
task.wait(v194);
else
task.wait(v196);
end
break;
end
if (FlatIdent_1BD19 == 0) then
v878 = v205("misc_antilock", false);
v879 = v192.Character;
FlatIdent_1BD19 = 1;
end
if (FlatIdent_1BD19 == 1) then
v880 = v879 and v879:FindFirstChild("HumanoidRootPart");
v881 = v879 and v879:FindFirstChildOfClass("Humanoid");
FlatIdent_1BD19 = 2;
end
end
end
end);
v191.Heartbeat:Connect(function()
local FlatIdent_5A386 = 0;
while true do
if (FlatIdent_5A386 == 0) then
if (((3736 <= 4740) and not v205("misc_resolver", false)) or (4241 == 3545)) then
return;
end
for v882, v883 in ipairs(v190:GetPlayers()) do
if ((v883 ~= v192) or (3390 <= 3060) or (4048 > 4232)) then
local v1077 = v883.Character;
local v1078 = v1077 and v1077:FindFirstChild("HumanoidRootPart");
local v1079 = v1077 and v1077:FindFirstChildOfClass("Humanoid");
if (v1078 and v1079 and (v1079.Health > 0)) then
pcall(function()
local v1196 = v1078.Velocity;
v1078.Velocity = v201(v1196.X, 0, v1196.Z);
end);
end
end
end
break;
end
end
end);
end
do
local v207 = game:GetService("Players");
local v208 = game:GetService("RunService");
local v209 = v207.LocalPlayer;
local v210 = {Inferno={["[SilencerAR]"]=9401972413,["[SMG]"]=9387593777,["[TacticalShotgun]"]=9402244359,["[AK47]"]=9402094255,["[AUG]"]=9401802930,["[AR]"]=9401972413,["[Glock]"]=9401670081,["[Shotgun]"]=9387831940,["[Silencer]"]=9401670081,["[P90]"]=9399878713,["[Revolver]"]=9370404463,["[RPG]"]=9399831924,["[LMG]"]=9400160302,["[Flamethrower]"]=9400503673,["[DrumGun]"]=9381496666,["[Double-Barrel SG]"]=9401416743},Galaxy={["[SilencerAR]"]=9402007158,["[SMG]"]=9387614760,["[TacticalShotgun]"]=9402279010,["[AK47]"]=9402132929,["[AUG]"]=9401832956,["[AR]"]=9402007158,["[Glock]"]=9401709916,["[Shotgun]"]=9387933478,["[Silencer]"]=9401709916,["[P90]"]=9399887933,["[Revolver]"]=9370936730,["[RPG]"]=9399842353,["[LMG]"]=9400170566,["[Flamethrower]"]=9400558000,["[DrumGun]"]=9381577172,["[Double-Barrel SG]"]=9401441647},Matrix={["[SilencerAR]"]=9402023983,["[SMG]"]=9387681455,["[TacticalShotgun]"]=9402295362,["[AK47]"]=9402147406,["[AUG]"]=9401855319,["[AR]"]=9402023983,["[Glock]"]=9401727978,["[Shotgun]"]=9387945198,["[Silencer]"]=9401727978,["[P90]"]=9399894480,["[Revolver]"]=9380928144,["[RPG]"]=9399850204,["[LMG]"]=9400178599,["[Flamethrower]"]=9400582867,["[DrumGun]"]=9381601709,["[Double-Barrel SG]"]=9401457713},RedDeath={["[SilencerAR]"]=8213168054,["[SMG]"]=8199875638,["[TacticalShotgun]"]=9203641766,["[AK47]"]=8213572965,["[AUG]"]=8212802637,["[AR]"]=8213168054,["[Glock]"]=8212637463,["[Shotgun]"]=8200647420,["[Silencer]"]=8212637463,["[P90]"]=8205381104,["[Revolver]"]=8173928665,["[RPG]"]=8201055935,["[LMG]"]=8205713344,["[Flamethrower]"]=8206707126,["[DrumGun]"]=8186385983,["[Double-Barrel SG]"]=8212384179},GoldGlory={["[SilencerAR]"]=8213175568,["[SMG]"]=8199883519,["[TacticalShotgun]"]=9203647967,["[AK47]"]=8213606202,["[AUG]"]=8212809463,["[AR]"]=8213175568,["[Glock]"]=8212667115,["[Shotgun]"]=8200657428,["[Silencer]"]=8212667115,["[P90]"]=8205397990,["[Revolver]"]=8173955378,["[RPG]"]=8201059812,["[LMG]"]=8205719479,["[Flamethrower]"]=8208010648,["[DrumGun]"]=8186168230,["[Double-Barrel SG]"]=8212394280}};
local function v211(v609, v610)
local v611, v612 = pcall(v43, v609, v610);
if (v611 and (v612 ~= nil)) then
return v612;
end
return v610;
end
local v212 = {};
local v213 = false;
local function v214()
local FlatIdent_3BAEF = 0;
while true do
if (FlatIdent_3BAEF == 1) then
v213 = false;
break;
end
if (FlatIdent_3BAEF == 0) then
for v884, v885 in pairs(v212) do
if (v884 and v884.Parent) then
pcall(function()
v884.TextureID = v885;
end);
end
end
v212 = {};
FlatIdent_3BAEF = 1;
end
end
end
local function v215(v613, v614)
local FlatIdent_79884 = 0;
local v615;
while true do
if (FlatIdent_79884 == 0) then
v615 = v210[v614];
if (not v615 or (999 > 2693)) then
return;
end
FlatIdent_79884 = 1;
end
if (FlatIdent_79884 == 1) then
for v886, v887 in pairs(v615) do
local FlatIdent_8AC48 = 0;
local v888;
local v889;
while true do
if (0 == FlatIdent_8AC48) then
v888 = v613:FindFirstChild(v886);
v889 = v888 and v888:FindFirstChild("Default");
FlatIdent_8AC48 = 1;
end
if (FlatIdent_8AC48 == 1) then
if (v889 or (1750 >= 3473)) then
local FlatIdent_2B407 = 0;
local v1080;
local v1081;
local v1082;
while true do
if (FlatIdent_2B407 == 0) then
if ((3166 == 3166) and (v212[v889] == nil)) then
local v1178, v1179 = pcall(function()
return v889.TextureID;
end);
v212[v889] = (v1178 and v1179) or "";
end
v1080 = "rbxassetid://" .. tostring(v887);
FlatIdent_2B407 = 1;
end
if (FlatIdent_2B407 == 1) then
v1081, v1082 = pcall(function()
return v889.TextureID;
end);
if ((1763 < 3724) and v1081 and (v1082 ~= v1080)) then
pcall(function()
v889.TextureID = v1080;
end);
end
break;
end
end
end
break;
end
end
end
break;
end
end
end
v208.RenderStepped:Connect(function()
local FlatIdent_1C534 = 0;
local v616;
while true do
if (FlatIdent_1C534 == 1) then
v213 = true;
v215(v616, v44(v211("skin_choice", {"Inferno"}), "Inferno"));
break;
end
if (FlatIdent_1C534 == 0) then
v616 = v209.Character;
if ((463 < 601) and (not v211("skin_enabled", false) or not v616)) then
local FlatIdent_81F9 = 0;
while true do
if (FlatIdent_81F9 == 0) then
if ((57 <= 2723) and (v213 or (2183 < 687))) then
v214();
end
return;
end
end
end
FlatIdent_1C534 = 1;
end
end
end);
end
do
local v216 = getgenv().DriftMoveElements or {};
local function v217(v617, v618)
local FlatIdent_8751C = 0;
local v619;
local v620;
while true do
if (FlatIdent_8751C == 1) then
return v618;
end
if (FlatIdent_8751C == 0) then
v619, v620 = pcall(v43, v617, v618);
if (v619 and (v620 ~= nil)) then
return v620;
end
FlatIdent_8751C = 1;
end
end
end
local function v218(v621, v622)
local v623 = v216[v621];
if (((4549 == 4549) and v623 and (type(v623.set_toggle) == "function")) or (2070 == 443)) then
local FlatIdent_8A1DB = 0;
local v1000;
while true do
if (0 == FlatIdent_8A1DB) then
v1000 = pcall(function()
v623:set_toggle(v622);
end);
if (v1000 or (2705 == 1393)) then
return;
end
break;
end
end
end
v21[v621] = v622;
end
local function v219(v625)
v218(v625, not v217(v625, false));
end
local v220 = {humanoid=nil,power=nil,use_power=nil};
local function v221()
local v626 = v220.humanoid;
local v627 = v220.power;
local v628 = v220.use_power;
v220.humanoid, v220.power, v220.use_power = nil, nil, nil;
if (v626 and v626.Parent) then
pcall(function()
local FlatIdent_542D1 = 0;
while true do
if (0 == FlatIdent_542D1) then
v626.JumpPower = v627 or 50;
v626.UseJumpPower = v628 ~= false;
break;
end
end
end);
end
end
local function v222()
local v632 = v42.Character;
local v633 = v632 and v632:FindFirstChildOfClass("Humanoid");
local v634 = v633 and v217("sjump_enabled", false);
if (((4672 == 4672) and not v634) or (4601 < 61)) then
local FlatIdent_1DF4C = 0;
while true do
if (FlatIdent_1DF4C == 0) then
if v220.humanoid then
v221();
end
return;
end
end
end
if ((v220.humanoid ~= v633) or (1390 >= 4744)) then
v221();
v220.humanoid = v633;
v220.power = v633.JumpPower;
v220.use_power = v633.UseJumpPower;
end
local v635 = v217("sjump_power", 180);
pcall(function()
local FlatIdent_6A0CF = 0;
while true do
if (FlatIdent_6A0CF == 0) then
v633.UseJumpPower = true;
v633.JumpPower = v635;
break;
end
end
end);
end
local v223 = {body=nil,gyro=nil,root=nil,humanoid=nil};
local v224 = Vector3.new(0, 1, 0);
local function v225()
local FlatIdent_6F79E = 0;
local v636;
local v637;
local v638;
while true do
if (FlatIdent_6F79E == 2) then
if ((v638 and v638.Parent) or (156 > 3913)) then
pcall(function()
v638.PlatformStand = false;
end);
end
break;
end
if (FlatIdent_6F79E == 1) then
if (v636 or (3668 < 395)) then
pcall(function()
v636:Destroy();
end);
end
if (v637 or (2003 > 3834)) then
pcall(function()
v637:Destroy();
end);
end
FlatIdent_6F79E = 2;
end
if (FlatIdent_6F79E == 0) then
v636, v637, v638 = v223.body, v223.gyro, v223.humanoid;
v223.body, v223.gyro, v223.root, v223.humanoid = nil, nil, nil, nil;
FlatIdent_6F79E = 1;
end
end
end
local function v226(v643, v644)
local FlatIdent_37DCA = 0;
local v645;
local v651;
while true do
if (1 == FlatIdent_37DCA) then
v645.Velocity = Vector3.new(0, 0, 0);
v645.Parent = v643;
v651 = Instance.new("BodyGyro");
v651.Name = "DriftFlyGyro";
FlatIdent_37DCA = 2;
end
if (2 == FlatIdent_37DCA) then
v651.MaxTorque = Vector3.new(1000000, 1000000, 1000000);
v651.P = 3000;
v651.D = 100;
v651.CFrame = v643.CFrame;
FlatIdent_37DCA = 3;
end
if (FlatIdent_37DCA == 0) then
v645 = Instance.new("BodyVelocity");
v645.Name = "DriftFlyBody";
v645.MaxForce = Vector3.new(1000000, 1000000, 1000000);
v645.P = 1250;
FlatIdent_37DCA = 1;
end
if (FlatIdent_37DCA == 3) then
v651.Parent = v643;
v223.body, v223.gyro, v223.root, v223.humanoid = v645, v651, v643, v644;
pcall(function()
v644.PlatformStand = true;
end);
break;
end
end
end
local function v227()
local v663 = v42.Character;
local v664 = v663 and v663:FindFirstChild("HumanoidRootPart");
local v665 = v663 and v663:FindFirstChildOfClass("Humanoid");
local v666 = v665 and (v665.Health > 0);
local v667 = v666 and v664 and v217("fly_enabled", false);
if ((195 == 195) and (not v667 or (4166 == 455))) then
local FlatIdent_2DACE = 0;
while true do
if (FlatIdent_2DACE == 0) then
if (v223.body or v223.gyro or v223.humanoid or (4449 == 2663)) then
v225();
end
return;
end
end
end
if ((3105 >= 1796) and ((v223.root ~= v664) or (v223.humanoid ~= v665) or not v223.body or not v223.body.Parent or not v223.gyro or not v223.gyro.Parent or (4277 < 2989))) then
local FlatIdent_936D7 = 0;
while true do
if (FlatIdent_936D7 == 0) then
v225();
v226(v664, v665);
break;
end
end
end
local v668 = v41.CurrentCamera;
local v669 = Vector3.new(0, 0, 0);
if v668 then
local FlatIdent_2660B = 0;
local v1006;
local v1007;
local v1008;
local v1009;
while true do
if (FlatIdent_2660B == 3) then
if ((2212 < 3183) and v39:IsKeyDown(Enum.KeyCode.W)) then
v669 = v669 + v1008;
end
if ((3844 >= 2043) and (4646 > 2992) and v39:IsKeyDown(Enum.KeyCode.S)) then
v669 = v669 - v1008;
end
FlatIdent_2660B = 4;
end
if (FlatIdent_2660B == 0) then
v1006 = v668.CFrame.LookVector;
v1007 = v668.CFrame.RightVector;
FlatIdent_2660B = 1;
end
if (FlatIdent_2660B == 2) then
v1009 = Vector3.new(v1007.X, 0, v1007.Z);
if ((4379 >= 2131) and ((v1009.Magnitude > 0.0010000000474974513) or (870 >= 4149))) then
v1009 = v1009.Unit;
end
FlatIdent_2660B = 3;
end
if (4 == FlatIdent_2660B) then
if v39:IsKeyDown(Enum.KeyCode.D) then
v669 = v669 + v1009;
end
if v39:IsKeyDown(Enum.KeyCode.A) then
v669 = v669 - v1009;
end
break;
end
if (FlatIdent_2660B == 1) then
v1008 = Vector3.new(v1006.X, 0, v1006.Z);
if (v1008.Magnitude <= 0.0010000000474974513) then
else
v1008 = v1008.Unit;
end
FlatIdent_2660B = 2;
end
end
end
if (v39:IsKeyDown(Enum.KeyCode.Space) or (3232 <= 2731)) then
v669 = v669 + v224;
end
if v39:IsKeyDown(Enum.KeyCode.LeftControl) then
v669 = v669 - v224;
end
if ((4905 == 4905) and (v669.Magnitude > 1)) then
v669 = v669.Unit;
end
local v670 = v217("fly_speed", 80);
pcall(function()
local FlatIdent_435AD = 0;
while true do
if (FlatIdent_435AD == 0) then
v223.body.Velocity = v669 * v670;
if (((1434 < 3106) and v668) or (4136 >= 4411)) then
v223.gyro.CFrame = CFrame.new(v664.Position) * (v668.CFrame - v668.CFrame.Position);
else
v223.gyro.CFrame = CFrame.new(v664.Position);
end
break;
end
end
end);
end
v39.InputBegan:Connect(function(v671, v672)
local FlatIdent_11D04 = 0;
while true do
if (FlatIdent_11D04 == 0) then
if (v672 or (v671.UserInputType ~= Enum.UserInputType.Keyboard) or (2958 == 4017)) then
return;
end
if ((1228 >= 813) and (786 < 3023) and (v671.KeyCode == v46(v217("sjump_key", Enum.KeyCode.J)))) then
v219("sjump_enabled");
elseif ((v671.KeyCode == v46(v217("fly_key", Enum.KeyCode.F))) or (2442 < 74)) then
v219("fly_enabled");
end
break;
end
end
end);
local v228 = v38.RenderStepped:Connect(function()
local FlatIdent_84D9 = 0;
while true do
if (FlatIdent_84D9 == 0) then
pcall(v222);
pcall(v227);
break;
end
end
end);
local function v229()
local FlatIdent_1A6FD = 0;
while true do
if (FlatIdent_1A6FD == 0) then
if (v228 or (3455 > 4050)) then
local FlatIdent_755B0 = 0;
while true do
if (FlatIdent_755B0 == 0) then
pcall(function()
v228:Disconnect();
end);
v228 = nil;
break;
end
end
end
if ((243 == 243) and (v223.body or v223.gyro or v223.humanoid)) then
v225();
end
FlatIdent_1A6FD = 1;
end
if (FlatIdent_1A6FD == 1) then
if v220.humanoid then
v221();
end
break;
end
end
end
getgenv().DriftMove = {toggle=v219,set=v218,stop=v229};
task.defer(function()
local FlatIdent_65088 = 0;
local v673;
while true do
if (FlatIdent_65088 == 0) then
v673 = getgenv().TeaUnload;
getgenv().TeaUnload = function()
if ((4535 == 4535) and v673) then
pcall(v673);
end
pcall(v229);
end;
break;
end
end
end);
end
do
local v231 = "drift/configs";
local function v232()
return getgenv().TeaJujuMenu;
end
local function v233()
pcall(function()
local FlatIdent_37395 = 0;
while true do
if (FlatIdent_37395 == 0) then
if not isfolder("drift") then
makefolder("drift");
end
if (not isfolder(v231) or (3009 <= 2105) or (271 > 1572)) then
makefolder(v231);
end
break;
end
end
end);
end
local function v234(v675)
local FlatIdent_89DF6 = 0;
while true do
if (FlatIdent_89DF6 == 1) then
return v675;
end
if (FlatIdent_89DF6 == 0) then
if ((1830 < 3669) and ((type(v675) ~= "string") or (v675 == ""))) then
return nil;
end
if (v675:find("/", 1, true) or v675:find(".", 1, true) or (1430 >= 3612)) then
return nil;
end
FlatIdent_89DF6 = 1;
end
end
end
local function v235(v676)
local FlatIdent_761C4 = 0;
local v677;
while true do
if (0 == FlatIdent_761C4) then
v677 = v234(v676);
if ((2739 < 3293) and not v677) then
return nil;
end
FlatIdent_761C4 = 1;
end
if (FlatIdent_761C4 == 1) then
return v231 .. "/" .. v677 .. ".cfg";
end
end
end
local v236 = {};
v236.list = function()
local FlatIdent_65A72 = 0;
local v678;
local v679;
local v680;
local v681;
while true do
if (FlatIdent_65A72 == 0) then
v233();
v678 = {};
FlatIdent_65A72 = 1;
end
if (FlatIdent_65A72 == 2) then
v681 = #v231 + 2;
for v894, v895 in ipairs(v680) do
local FlatIdent_5AC6 = 0;
local v896;
while true do
if (FlatIdent_5AC6 == 0) then
v896 = v895:match("%.([^%.]+)$");
if (v896 and (v896:lower() == "cfg")) then
local FlatIdent_58332 = 0;
local v1088;
while true do
if (FlatIdent_58332 == 0) then
v1088 = v895:sub(v681, -5);
if ((v1088 ~= "") or (3942 < 1134)) then
v678[#v678 + 1] = v1088;
end
break;
end
end
end
break;
end
end
end
FlatIdent_65A72 = 3;
end
if (FlatIdent_65A72 == 3) then
table.sort(v678);
return v678;
end
if (FlatIdent_65A72 == 1) then
v679, v680 = pcall(listfiles, v231);
if (not v679 or (type(v680) ~= "table")) then
return v678;
end
FlatIdent_65A72 = 2;
end
end
end;
v236.export = function(v682)
local FlatIdent_9777C = 0;
local v683;
local v684;
local v685;
while true do
if (FlatIdent_9777C == 0) then
v683 = v235(v682);
if ((2683 >= 2460) and (not v683 or (type(isfile) ~= "function") or not isfile(v683))) then
return nil;
end
FlatIdent_9777C = 1;
end
if (FlatIdent_9777C == 1) then
v684, v685 = pcall(readfile, v683);
if (not v684 or (type(v685) ~= "string") or (2693 == 4973)) then
return nil;
end
FlatIdent_9777C = 2;
end
if (FlatIdent_9777C == 2) then
if (type(setclipboard) ~= "function") then
else
pcall(setclipboard, v685);
end
return v685;
end
end
end;
v236.readable = function(v686)
local FlatIdent_943B = 0;
local v687;
local v688;
local v689;
local v690;
local v691;
local v692;
while true do
if (FlatIdent_943B == 3) then
if ((v691 and (type(v692) == "string")) or (1417 > 3629)) then
return v692;
end
return nil;
end
if (FlatIdent_943B == 0) then
v687 = v236.export(v686);
v688 = v232();
FlatIdent_943B = 1;
end
if (FlatIdent_943B == 1) then
if (not v687 or not v688 or (type(v688.get_config_data) ~= "function") or (1804 >= 3275)) then
return nil;
end
v689, v690 = pcall(v688.get_config_data, v687);
FlatIdent_943B = 2;
end
if (FlatIdent_943B == 2) then
if ((2146 == 2146) and (not v689 or (type(v690) ~= "table"))) then
return nil;
end
v691, v692 = pcall(function()
return game:GetService("HttpService"):JSONEncode(v690);
end);
FlatIdent_943B = 3;
end
end
end;
v236.save = function(v693)
local FlatIdent_6295B = 0;
local v694;
local v695;
while true do
if (FlatIdent_6295B == 0) then
v694 = v232();
if (not v694 or (type(v694.save_config) ~= "function") or not v234(v693)) then
return false;
end
FlatIdent_6295B = 1;
end
if (1 == FlatIdent_6295B) then
v233();
v695 = pcall(v694.save_config, v693);
FlatIdent_6295B = 2;
end
if (FlatIdent_6295B == 2) then
return v695;
end
end
end;
v236.load = function(v696)
local FlatIdent_7EA3B = 0;
local v697;
local v698;
while true do
if (FlatIdent_7EA3B == 0) then
v697 = v232();
if ((4795 > 402) and (not v697 or (type(v697.load_config) ~= "function") or not v234(v696))) then
return false;
end
FlatIdent_7EA3B = 1;
end
if (FlatIdent_7EA3B == 1) then
v698 = pcall(v697.load_config, v696);
return v698;
end
end
end;
v236.import = function(v699, v700)
local FlatIdent_1F799 = 0;
local v701;
local v702;
while true do
if (FlatIdent_1F799 == 1) then
if ((type(writefile) ~= "function") or (4904 <= 1916)) then
return false;
end
v233();
FlatIdent_1F799 = 2;
end
if (FlatIdent_1F799 == 2) then
v702 = pcall(writefile, v701, v700);
if ((90 <= 1065) and not v702) then
return false;
end
FlatIdent_1F799 = 3;
end
if (3 == FlatIdent_1F799) then
v236.load(v699);
return true;
end
if (0 == FlatIdent_1F799) then
v701 = v235(v699);
if (not v701 or (type(v700) ~= "string") or (#v700 < 16) or (2244 == 3224)) then
return false;
end
FlatIdent_1F799 = 1;
end
end
end;
getgenv().DriftConfig = v236;
end
local function v59()
local v244 = game:GetService("RunService");
local v245 = game:GetService("UserInputService");
local v246 = game:GetService("Players");
local v247 = workspace;
local v248 = v246.LocalPlayer;
if ((4802 == 4802) and (4813 > 3565) and not Drawing) then
local FlatIdent_24300 = 0;
while true do
if (0 == FlatIdent_24300) then
warn("[drift esp] no Drawing API - overlay esp stays off");
return;
end
end
end
local v249 = type(v43) ~= "function";
local v250 = true;
local function v251(v703, v704)
if ((3912 == 3912) and not v249) then
local FlatIdent_8FACF = 0;
local v1011;
local v1012;
local v1013;
while true do
if (FlatIdent_8FACF == 2) then
return v704;
end
if (1 == FlatIdent_8FACF) then
v1013 = getgenv().TeaJujuFlags;
if (((type(v1013) == "table") and (v1013[v703] ~= nil)) or (2280 <= 511)) then
return v1013[v703];
end
FlatIdent_8FACF = 2;
end
if (0 == FlatIdent_8FACF) then
v1011, v1012 = pcall(v43, v703, v704);
if ((2821 <= 4824) and v1011 and (v1012 ~= nil)) then
return v1012;
end
FlatIdent_8FACF = 1;
end
end
end
local v705 = getgenv().drift_esp;
if (((1738 <= 2195) and (type(v705) == "table") and (v705[v703] ~= nil)) or (1676 <= 463)) then
return v705[v703];
end
return v704;
end
local v252 = Color3.fromRGB(255, 255, 255);
local v253 = Color3.fromRGB(0, 0, 0);
local v254 = nil;
do
local FlatIdent_88CAD = 0;
local v706;
local v707;
while true do
if (FlatIdent_88CAD == 0) then
v706, v707 = pcall(function()
return game:GetService("CoreGui");
end);
if ((3869 == 3869) and v706 and v707) then
v254 = v707;
end
FlatIdent_88CAD = 1;
end
if (FlatIdent_88CAD == 1) then
if ((41 <= 3018) and not v254) then
local v1014, v1015 = pcall(function()
return v248:FindFirstChildOfClass("PlayerGui");
end);
if v1014 then
v254 = v1015;
end
end
break;
end
end
end
if ((2145 <= 4104) and not v254) then
local FlatIdent_72AA3 = 0;
while true do
if (FlatIdent_72AA3 == 0) then
warn("[drift esp] no gui parent available - overlay esp stays off");
return;
end
end
end
local v255 = {{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"}};
local v256 = {{"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"Torso","Left Leg"},{"Torso","Right Leg"}};
local v257 = "__drift_esp_draw";
local v258 = "__drift_esp_gui";
local v259 = getgenv()[v257];
if ((1158 <= 2613) and (2689 < 4845) and (type(v259) == "table")) then
for v1016, v1017 in ipairs(v259) do
pcall(function()
v1017:Remove();
end);
end
end
local v260 = getgenv()[v258];
if ((type(v260) == "table") or (2322 > 2622)) then
for v1018, v1019 in ipairs(v260) do
pcall(function()
v1019:Destroy();
end);
end
end
local v261 = "__drift_esp_loop";
local v262 = getgenv()[v261];
if (type(v262) ~= "function") then
else
pcall(v262);
getgenv()[v261] = nil;
end
local v263, v264 = pcall(function()
return v254:GetChildren();
end);
if ((v263 and (type(v264) == "table")) or (4534 == 2082)) then
for v1020, v1021 in ipairs(v264) do
local v1022 = v1021.Name;
if ((typeof(v1021) == "Instance") and v1021:IsA("ScreenGui") and (string.sub(v1022, 1, 10) == "drift_esp_")) then
pcall(function()
v1021:Destroy();
end);
end
end
end
local v265 = {};
local v266 = {};
getgenv()[v257] = v265;
getgenv()[v258] = v266;
local v269 = false;
local function v270(v708)
local v709, v710 = pcall(function()
return Drawing.new(v708);
end);
if (not v709 or (v710 == nil) or (2364 <= 1999)) then
local FlatIdent_72401 = 0;
while true do
if (FlatIdent_72401 == 0) then
if (not v269 or (1571 > 1867) or (4922 < 194)) then
v269 = true;
warn("[drift esp] Drawing.new(" .. tostring(v708) .. ") unavailable - esp cannot draw");
end
return nil;
end
end
end
v710.Visible = false;
v265[#v265 + 1] = v710;
return v710;
end
local function v271(v713)
local FlatIdent_7C382 = 0;
local v714;
local v715;
while true do
if (FlatIdent_7C382 == 0) then
v714, v715 = pcall(function()
local FlatIdent_53D9 = 0;
local v898;
while true do
if (FlatIdent_53D9 == 0) then
v898 = Instance.new("TextLabel");
v898.BackgroundTransparency = 1;
v898.BorderSizePixel = 0;
FlatIdent_53D9 = 1;
end
if (FlatIdent_53D9 == 4) then
v898.Visible = false;
return v898;
end
if (FlatIdent_53D9 == 2) then
v898.TextScaled = false;
v898.RichText = false;
v898.TextSize = v713;
FlatIdent_53D9 = 3;
end
if (FlatIdent_53D9 == 1) then
v898.TextColor3 = v252;
v898.TextStrokeColor3 = v253;
v898.TextStrokeTransparency = 0;
FlatIdent_53D9 = 2;
end
if (FlatIdent_53D9 == 3) then
v898.Font = Enum.Font.Code;
v898.TextXAlignment = Enum.TextXAlignment.Center;
v898.Size = UDim2.new(0, 220, 0, v713 + 4);
FlatIdent_53D9 = 4;
end
end
end);
if (not v714 or (v715 == nil) or (2091 < 31)) then
return nil;
end
FlatIdent_7C382 = 1;
end
if (1 == FlatIdent_7C382) then
return v715;
end
end
end
local v272 = {};
local function v273(v716)
local v717 = v272[v716];
if v717 then
return v717;
end
v717 = {box=v270("Square"),outline=v270("Square"),bones={},highlight=nil,lastHealth=nil,lastArmor=nil,drawn=false};
if v717.box then
pcall(function()
local FlatIdent_2A2C4 = 0;
while true do
if (FlatIdent_2A2C4 == 1) then
v717.box.Color = v252;
break;
end
if (FlatIdent_2A2C4 == 0) then
v717.box.Filled = false;
v717.box.Thickness = 2;
FlatIdent_2A2C4 = 1;
end
end
end);
end
if (v717.outline or (2654 >= 2996) or (2430 >= 4872)) then
pcall(function()
local FlatIdent_3A655 = 0;
while true do
if (FlatIdent_3A655 == 1) then
v717.outline.Color = v253;
break;
end
if (FlatIdent_3A655 == 0) then
v717.outline.Filled = false;
v717.outline.Thickness = 1;
FlatIdent_3A655 = 1;
end
end
end);
end
v717.healthOutline = v270("Square");
v717.healthFill = v270("Square");
v717.armorOutline = v270("Square");
v717.armorFill = v270("Square");
for v913, v914 in ipairs({"healthOutline","armorOutline"}) do
local FlatIdent_5BBF = 0;
local v915;
while true do
if (0 == FlatIdent_5BBF) then
v915 = v717[v914];
if ((3978 > 2104) and v915) then
pcall(function()
v915.Filled = true;
v915.Thickness = 1;
v915.Color = v253;
v915.Transparency = 0.45;
end);
end
break;
end
end
end
if ((2995 > 1541) and v717.healthFill) then
pcall(function()
local FlatIdent_5D472 = 0;
while true do
if (1 == FlatIdent_5D472) then
v717.healthFill.Transparency = 0;
break;
end
if (FlatIdent_5D472 == 0) then
v717.healthFill.Filled = true;
v717.healthFill.Color = Color3.fromRGB(0, 255, 0);
FlatIdent_5D472 = 1;
end
end
end);
end
if (v717.armorFill or (4770 < 1735)) then
pcall(function()
local FlatIdent_356A = 0;
while true do
if (FlatIdent_356A == 1) then
v717.armorFill.Transparency = 0;
break;
end
if (FlatIdent_356A == 0) then
v717.armorFill.Filled = true;
v717.armorFill.Color = Color3.fromRGB(120, 180, 255);
FlatIdent_356A = 1;
end
end
end);
end
local v722, v723 = pcall(function()
local FlatIdent_1A266 = 0;
local v916;
while true do
if (FlatIdent_1A266 == 2) then
v916.ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
v916.DisplayOrder = 9999;
FlatIdent_1A266 = 3;
end
if (3 == FlatIdent_1A266) then
v916.Parent = v254;
return v916;
end
if (FlatIdent_1A266 == 0) then
v916 = Instance.new("ScreenGui");
v916.Name = "drift_esp_" .. v716.Name;
FlatIdent_1A266 = 1;
end
if (FlatIdent_1A266 == 1) then
v916.IgnoreGuiInset = true;
v916.ResetOnSpawn = false;
FlatIdent_1A266 = 2;
end
end
end);
if (((3249 > 953) and v722 and v723) or (4439 <= 2350)) then
local FlatIdent_3F5C2 = 0;
while true do
if (FlatIdent_3F5C2 == 2) then
v717.tool = v271(14);
for v1101, v1102 in ipairs({"name","studs","tool"}) do
local v1103 = v717[v1102];
if (v1103 or (4479 < 4466)) then
v1103.Parent = v723;
end
end
break;
end
if (FlatIdent_3F5C2 == 1) then
v717.name = v271(14);
v717.studs = v271(14);
FlatIdent_3F5C2 = 2;
end
if (FlatIdent_3F5C2 == 0) then
v266[#v266 + 1] = v723;
v717.gui = v723;
FlatIdent_3F5C2 = 1;
end
end
end
v272[v716] = v717;
return v717;
end
local function v274(v725)
if ((2547 > 1225) and not v725.drawn) then
return;
end
v725.drawn = false;
if ((4671 > 2674) and v725.box) then
v725.box.Visible = false;
end
if (v725.outline or (3273 > 4573)) then
v725.outline.Visible = false;
end
for v924, v925 in ipairs({"name","studs","tool","healthOutline","healthFill","armorOutline","armorFill"}) do
local v926 = v725[v925];
if v926 then
v926.Visible = false;
end
end
for v927, v928 in ipairs(v725.bones) do
if (v928 or (3151 < 1284) or (3696 < 3327)) then
v928.Visible = false;
end
end
end
local function v275(v727)
local FlatIdent_5CD30 = 0;
while true do
if (0 == FlatIdent_5CD30) then
v274(v727);
if (v727.box or (1850 == 1529) or (4542 == 2970)) then
pcall(function()
v727.box:Remove();
end);
end
FlatIdent_5CD30 = 1;
end
if (FlatIdent_5CD30 == 2) then
for v932, v933 in ipairs(v727.bones) do
if (((858 <= 2962) and v933) or (1618 < 930)) then
pcall(function()
v933:Remove();
end);
end
end
if (v727.highlight or (3946 < 1288)) then
local FlatIdent_6F428 = 0;
while true do
if (FlatIdent_6F428 == 0) then
pcall(function()
v727.highlight:Destroy();
end);
v727.highlight = nil;
break;
end
end
end
FlatIdent_5CD30 = 3;
end
if (1 == FlatIdent_5CD30) then
if ((252 <= 1977) and (821 < 2123) and v727.outline) then
pcall(function()
v727.outline:Remove();
end);
end
for v929, v930 in ipairs({"healthOutline","healthFill","armorOutline","armorFill"}) do
local FlatIdent_96B75 = 0;
local v931;
while true do
if (FlatIdent_96B75 == 0) then
v931 = v727[v930];
if (((902 < 2325) and v931) or (1436 == 3775)) then
local FlatIdent_38DAC = 0;
while true do
if (0 == FlatIdent_38DAC) then
pcall(function()
v931:Remove();
end);
v727[v930] = nil;
break;
end
end
end
break;
end
end
end
FlatIdent_5CD30 = 2;
end
if (3 == FlatIdent_5CD30) then
if (v727.gui or (3242 == 567)) then
local FlatIdent_52E0C = 0;
while true do
if (FlatIdent_52E0C == 0) then
pcall(function()
v727.gui:Destroy();
end);
v727.gui = nil;
break;
end
end
end
break;
end
end
end
local function v276(v728, v729)
local FlatIdent_69E54 = 0;
local v730;
while true do
if (FlatIdent_69E54 == 2) then
return v730;
end
if (FlatIdent_69E54 == 0) then
v730 = v728.bones[v729];
if ((4723 > 4153) and v730) then
return v730;
end
FlatIdent_69E54 = 1;
end
if (1 == FlatIdent_69E54) then
v730 = v270("Line");
if (v730 or (847 >= 1263)) then
local FlatIdent_5EA98 = 0;
while true do
if (FlatIdent_5EA98 == 0) then
pcall(function()
v730.Thickness = 1;
v730.Color = v252;
v730.Transparency = 0.85;
end);
v728.bones[v729] = v730;
break;
end
end
end
FlatIdent_69E54 = 2;
end
end
end
local function v277(v731)
local FlatIdent_6FC5B = 0;
local v732;
local v733;
while true do
if (FlatIdent_6FC5B == 0) then
v732, v733 = nil;
if (v731 > 0.5) then
v733 = 1;
v732 = (1 - v731) * 2;
else
v732 = 1;
v733 = v731 * 2;
end
FlatIdent_6FC5B = 1;
end
if (FlatIdent_6FC5B == 1) then
return Color3.new(v732, v733, 0);
end
end
end
local v278 = 3;
local v279 = 3;
local function v280(v734, v735, v736, v737, v738, v739, v740, v741)
local FlatIdent_6E337 = 0;
local v742;
local v743;
local v744;
local v745;
local v746;
while true do
if (FlatIdent_6E337 == 1) then
v744 = v739 + 2;
v745 = v739;
v746 = math.floor((v740 * v745) + 0.5);
FlatIdent_6E337 = 2;
end
if (FlatIdent_6E337 == 4) then
v736.Size = Vector2.new(v278, v746);
if (v741 or (2087 > 2372) or (1736 == 571)) then
v736.Color = v741;
end
v736.Visible = true;
break;
end
if (FlatIdent_6E337 == 2) then
if (v746 > v745) then
v746 = v745;
elseif ((v746 < 0) or (3654 >= 4654)) then
v746 = 0;
end
v735.Position = Vector2.new(v742, v743);
v735.Size = Vector2.new(v278 + 2, v744);
FlatIdent_6E337 = 3;
end
if (FlatIdent_6E337 == 0) then
if (not v735 or not v736 or (2253 == 1851)) then
return;
end
v742 = (((v737 - v279) - v278) - 1) - (v734 * (v278 + v279));
v743 = v738 - 1;
FlatIdent_6E337 = 1;
end
if (FlatIdent_6E337 == 3) then
v735.Visible = true;
if ((951 <= 1496) and (v746 < 1)) then
local FlatIdent_3397E = 0;
while true do
if (FlatIdent_3397E == 0) then
v736.Visible = false;
return;
end
end
end
v736.Position = Vector2.new(v742 + 1, v743 + 1 + (v745 - v746));
FlatIdent_6E337 = 4;
end
end
end
local function v281(v753, v754, v755)
local FlatIdent_18172 = 0;
while true do
if (FlatIdent_18172 == 0) then
if not v755 then
local FlatIdent_1A2AA = 0;
while true do
if (FlatIdent_1A2AA == 0) then
if (v753.highlight or (896 > 4769)) then
pcall(function()
v753.highlight:Destroy();
end);
v753.highlight = nil;
end
return;
end
end
end
if ((v753.highlight and (v753.highlight.Parent ~= v754)) or (4445 < 4149) or (1045 <= 1020)) then
pcall(function()
v753.highlight.Parent = v754;
end);
end
FlatIdent_18172 = 1;
end
if (FlatIdent_18172 == 1) then
if (not v753.highlight or (1818 == 85) or (1160 <= 328)) then
local FlatIdent_65F8 = 0;
local v1035;
local v1036;
while true do
if (FlatIdent_65F8 == 0) then
v1035, v1036 = pcall(function()
local FlatIdent_5D1D5 = 0;
local v1111;
while true do
if (FlatIdent_5D1D5 == 0) then
v1111 = Instance.new("Highlight");
v1111.Name = "drift_esp";
FlatIdent_5D1D5 = 1;
end
if (FlatIdent_5D1D5 == 2) then
v1111.OutlineColor = v252;
v1111.OutlineTransparency = 0;
FlatIdent_5D1D5 = 3;
end
if (3 == FlatIdent_5D1D5) then
v1111.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop;
v1111.Parent = v754;
FlatIdent_5D1D5 = 4;
end
if (FlatIdent_5D1D5 == 1) then
v1111.FillColor = v252;
v1111.FillTransparency = 0.72;
FlatIdent_5D1D5 = 2;
end
if (FlatIdent_5D1D5 == 4) then
return v1111;
end
end
end);
if ((3808 > 2924) and v1035) then
v753.highlight = v1036;
end
break;
end
end
end
break;
end
end
end
local function v282(v756, v757)
local v758 = v756:FindFirstChild("BodyEffects");
local v759 = v758 and v758:FindFirstChild("Armor");
if ((3891 < 4919) and (630 < 2127) and v759 and (typeof(v759) == "Instance") and v759:IsA("ValueBase")) then
local FlatIdent_8DE03 = 0;
local v1037;
local v1038;
local v1039;
while true do
if (FlatIdent_8DE03 == 2) then
if (v1039 or (2512 < 432)) then
return math.max(0, math.min(1, v1039 / math.max(v1038, 1)));
end
break;
end
if (FlatIdent_8DE03 == 1) then
if ((v1037 and (typeof(v1037) == "Instance") and v1037:IsA("ValueBase")) or (1938 == 2514) or (2234 <= 1502)) then
v1038 = tonumber(v1037.Value) or v1038;
end
v1039 = tonumber(v759.Value);
FlatIdent_8DE03 = 2;
end
if (0 == FlatIdent_8DE03) then
v1037 = v758:FindFirstChild("MaxArmor");
v1038 = 130;
FlatIdent_8DE03 = 1;
end
end
end
local v760 = v756:GetAttribute("Armor") or v757:GetAttribute("Armor");
if ((4255 >= 55) and (type(v760) == "number")) then
local FlatIdent_8E526 = 0;
local v1040;
while true do
if (FlatIdent_8E526 == 0) then
v1040 = v756:GetAttribute("MaxArmor") or v757:GetAttribute("MaxArmor") or 100;
return math.max(0, math.min(1, v760 / math.max(v1040, 1)));
end
end
end
return 0;
end
v246.PlayerRemoving:Connect(function(v761)
local FlatIdent_82627 = 0;
local v762;
while true do
if (FlatIdent_82627 == 0) then
v762 = v272[v761];
if v762 then
v275(v762);
v272[v761] = nil;
end
break;
end
end
end);
if (((2999 > 1156) and v249) or (1848 == 865)) then
local FlatIdent_23986 = 0;
while true do
if (FlatIdent_23986 == 0) then
v245.InputBegan:Connect(function(v1042, v1043)
local FlatIdent_23522 = 0;
while true do
if (FlatIdent_23522 == 0) then
if (v1043 or (4682 <= 4541)) then
return;
end
if ((2350 > 1155) and (v1042.KeyCode == Enum.KeyCode.RightShift)) then
v250 = not v250;
end
break;
end
end
end);
print("[drift esp] standalone - right shift toggles, overrides in getgenv().drift_esp");
break;
end
end
end
local v283 = false;
local function v284()
local FlatIdent_64015 = 0;
local v763;
local v764;
local v765;
local v766;
local v767;
local v768;
local v769;
local v770;
local v771;
local v772;
local v773;
local v774;
local v775;
local v776;
local v777;
local v778;
while true do
if (FlatIdent_64015 == 1) then
v283 = true;
v765 = v251("esp_max_distance", 2000);
v766 = v251("esp_team", true);
FlatIdent_64015 = 2;
end
if (FlatIdent_64015 == 5) then
v776 = v251("esp_highlight", false);
v777 = v763.CFrame.Position;
v778 = v763.ViewportSize;
FlatIdent_64015 = 6;
end
if (FlatIdent_64015 == 4) then
v773 = v251("esp_health", true);
v774 = v251("esp_armor", false);
v775 = v251("esp_skeleton", false);
FlatIdent_64015 = 5;
end
if (FlatIdent_64015 == 6) then
for v934, v935 in ipairs(v246:GetPlayers()) do
local FlatIdent_6B54C = 0;
local v936;
local v937;
local v938;
local v939;
local v940;
local v941;
local v942;
while true do
if (FlatIdent_6B54C == 4) then
if ((4046 >= 3033) and not v940) then
if (v942 or (3026 >= 4046)) then
local FlatIdent_26F63 = 0;
while true do
if (FlatIdent_26F63 == 0) then
v274(v942);
v281(v942, v936, false);
break;
end
end
end
else
local v1121, v1122 = v763:WorldToViewportPoint(v938.Position);
local v1123 = v763:WorldToViewportPoint(v938.Position - Vector3.new(0, 1, 0)).Y;
local v1124 = v763:WorldToViewportPoint(v938.Position + Vector3.new(0, 3, 0)).Y;
local v1125 = (v1123 - v1124) / 2;
local v1126 = v1122 and (v1125 > 1) and (v1121.X > -64) and (v1121.Y > -64) and (v1121.X < (v778.X + 64)) and (v1121.Y < (v778.Y + 64));
if not v1126 then
if ((2008 > 638) and (v942 or (2719 <= 1447))) then
v274(v942);
v281(v942, v936, false);
end
else
v942 = v273(v935);
v942.drawn = true;
local v1186 = math.floor(v1125 * 3.2);
local v1187 = math.floor(v1125 * 1.5);
if ((1775 <= 3233) and ((v1187 > (v1186 * v768)) or (4134 < 3926))) then
v1187 = math.floor(v1186 * v768);
end
if ((v1187 < 2) or (4543 == 1997)) then
v1187 = 2;
end
if (v1186 < 4) then
v1186 = 4;
end
local v1188 = math.floor(v1121.X - (v1187 * 0.5));
local v1189 = math.floor(v1121.Y - (v1186 * 0.47));
if ((v769 and v942.box) or (3102 < 728)) then
v942.box.Position = Vector2.new(v1188, v1189);
v942.box.Size = Vector2.new(v1187, v1186);
v942.box.Visible = true;
elseif ((345 == 345) and v942.box) then
v942.box.Visible = false;
end
if ((v769 and v942.outline) or (164 >= 2785) or (2827 < 378)) then
local FlatIdent_58C4D = 0;
while true do
if (FlatIdent_58C4D == 0) then
v942.outline.Position = Vector2.new(v1188 - 1, v1189 - 1);
v942.outline.Size = Vector2.new(v1187 + 2, v1186 + 2);
FlatIdent_58C4D = 1;
end
if (FlatIdent_58C4D == 1) then
v942.outline.Visible = true;
break;
end
end
elseif (v942.outline or (525 == 2109) or (3476 < 2597)) then
v942.outline.Visible = false;
end
local v1190 = v1188 + (v1187 * 0.5);
local v1191 = v1189;
if (v770 and v942.name) then
local FlatIdent_91215 = 0;
while true do
if (FlatIdent_91215 == 1) then
v942.name.Text = v935.Name;
v942.name.Position = UDim2.new(0, v1190 - 110, 0, (v1191 - v767) - 6);
FlatIdent_91215 = 2;
end
if (FlatIdent_91215 == 2) then
v942.name.Visible = true;
break;
end
if (FlatIdent_91215 == 0) then
v942.name.TextSize = v767;
v942.name.Size = UDim2.new(0, 220, 0, v767 + 4);
FlatIdent_91215 = 1;
end
end
elseif ((3079 < 4794) and (33 == 33) and v942.name) then
v942.name.Visible = false;
end
if ((4854 > 4464) and (3054 <= 4015) and v771 and v942.studs) then
local FlatIdent_94DD1 = 0;
while true do
if (FlatIdent_94DD1 == 2) then
v942.studs.Visible = true;
break;
end
if (FlatIdent_94DD1 == 1) then
v942.studs.Text = string.format("[%.0fm]", v941 * 0.28);
v942.studs.Position = UDim2.new(0, v1190 - 110, 0, v1191 + v1186 + 3);
FlatIdent_94DD1 = 2;
end
if (FlatIdent_94DD1 == 0) then
v942.studs.TextSize = v767;
v942.studs.Size = UDim2.new(0, 220, 0, v767 + 4);
FlatIdent_94DD1 = 1;
end
end
elseif (((1871 < 3382) and v942.studs) or (4912 == 3758)) then
v942.studs.Visible = false;
end
if ((126 <= 3482) and (1293 <= 2166) and v772 and v942.tool) then
local FlatIdent_7CC7D = 0;
local v1225;
while true do
if (FlatIdent_7CC7D == 0) then
v1225 = v936:FindFirstChildOfClass("Tool");
v942.tool.TextSize = v767;
FlatIdent_7CC7D = 1;
end
if (FlatIdent_7CC7D == 1) then
v942.tool.Size = UDim2.new(0, 220, 0, v767 + 4);
v942.tool.Text = (v1225 and v1225.Name) or "none";
FlatIdent_7CC7D = 2;
end
if (2 == FlatIdent_7CC7D) then
v942.tool.Position = UDim2.new(0, v1190 - 110, 0, v1191 + v1186 + v767 + 5);
v942.tool.Visible = true;
break;
end
end
elseif v942.tool then
v942.tool.Visible = false;
end
if (v773 and v942.healthOutline and v942.healthFill) then
local FlatIdent_53FC6 = 0;
local v1231;
local v1232;
local v1233;
while true do
if (FlatIdent_53FC6 == 1) then
v1232 = v942.lastHealth;
v1233 = v1231;
FlatIdent_53FC6 = 2;
end
if (0 == FlatIdent_53FC6) then
v1231 = v937.Health / math.max(v937.MaxHealth, 1);
v1231 = math.max(0, math.min(1, v1231));
FlatIdent_53FC6 = 1;
end
if (2 == FlatIdent_53FC6) then
if (v1232 or (2579 < 123)) then
v1233 = v1232 + ((v1231 - v1232) * 0.05);
end
v942.lastHealth = v1233;
FlatIdent_53FC6 = 3;
end
if (3 == FlatIdent_53FC6) then
v280(0, v942.healthOutline, v942.healthFill, v1188, v1189, v1186, v1233, v277(v1233));
break;
end
end
else
local FlatIdent_18A8E = 0;
while true do
if (FlatIdent_18A8E == 0) then
if v942.healthOutline then
v942.healthOutline.Visible = false;
end
if (v942.healthFill or (846 >= 2368) or (2374 == 4374)) then
v942.healthFill.Visible = false;
end
break;
end
end
end
if (v774 and v942.armorOutline and v942.armorFill) then
local FlatIdent_394C = 0;
local v1235;
local v1236;
local v1237;
while true do
if (0 == FlatIdent_394C) then
v1235 = v282(v936, v937);
v1236 = v942.lastArmor;
FlatIdent_394C = 1;
end
if (FlatIdent_394C == 2) then
v942.lastArmor = v1237;
v280(1, v942.armorOutline, v942.armorFill, v1188, v1189, v1186, v1237, nil);
break;
end
if (FlatIdent_394C == 1) then
v1237 = v1235;
if v1236 then
v1237 = v1236 + ((v1235 - v1236) * 0.05);
end
FlatIdent_394C = 2;
end
end
else
local FlatIdent_2CB91 = 0;
while true do
if (FlatIdent_2CB91 == 0) then
if (v942.armorOutline or (4012 <= 3358)) then
v942.armorOutline.Visible = false;
end
if ((1494 <= 3005) and v942.armorFill) then
v942.armorFill.Visible = false;
end
break;
end
end
end
if v775 then
local v1239 = (v936:FindFirstChild("UpperTorso") and v255) or v256;
for v1240 = 1, #v1239 do
local FlatIdent_69785 = 0;
local v1241;
local v1242;
local v1243;
while true do
if (FlatIdent_69785 == 1) then
v1243 = v936:FindFirstChild(v1239[v1240][2]);
if ((1575 == 1575) and ((v1241 and v1242 and v1243 and v1242:IsA("BasePart") and v1243:IsA("BasePart")) or (3111 == 2134))) then
local FlatIdent_5C892 = 0;
local v1259;
local v1260;
while true do
if (1 == FlatIdent_5C892) then
if ((v1259.Z > 0) and (v1260.Z > 0)) then
v1241.From = Vector2.new(v1259.X, v1259.Y);
v1241.To = Vector2.new(v1260.X, v1260.Y);
v1241.Visible = true;
else
v1241.Visible = false;
end
break;
end
if (FlatIdent_5C892 == 0) then
v1259 = v763:WorldToViewportPoint(v1242.Position);
v1260 = v763:WorldToViewportPoint(v1243.Position);
FlatIdent_5C892 = 1;
end
end
elseif (v1241 or (2234 == 1455)) then
v1241.Visible = false;
end
break;
end
if (0 == FlatIdent_69785) then
v1241 = v276(v942, v1240);
v1242 = v936:FindFirstChild(v1239[v1240][1]);
FlatIdent_69785 = 1;
end
end
end
for v1244 = #v1239 + 1, #v942.bones do
local FlatIdent_50219 = 0;
local v1245;
while true do
if (0 == FlatIdent_50219) then
v1245 = v942.bones[v1244];
if ((2355 == 2355) and v1245) then
v1245.Visible = false;
end
break;
end
end
end
else
for v1246, v1247 in ipairs(v942.bones) do
if (v1247 or (1067 > 1779)) then
v1247.Visible = false;
end
end
end
v281(v942, v936, v776);
end
end
break;
end
if (FlatIdent_6B54C == 2) then
v940 = (v935 ~= v248) and (v936 ~= nil) and (v937 ~= nil) and (v937.Health > 0) and (v938 ~= nil) and not v939;
v941 = 0;
FlatIdent_6B54C = 3;
end
if (3 == FlatIdent_6B54C) then
if v940 then
local FlatIdent_14E41 = 0;
while true do
if (FlatIdent_14E41 == 0) then
v941 = (v938.Position - v777).Magnitude;
if (v941 <= v765) then
else
v940 = false;
end
break;
end
end
end
v942 = v272[v935];
FlatIdent_6B54C = 4;
end
if (FlatIdent_6B54C == 0) then
v936 = v935.Character;
v937 = v936 and v936:FindFirstChildWhichIsA("Humanoid");
FlatIdent_6B54C = 1;
end
if (FlatIdent_6B54C == 1) then
v938 = v936 and v936:FindFirstChild("HumanoidRootPart");
v939 = v766 and (v248.Team ~= nil) and (v935.Team == v248.Team);
FlatIdent_6B54C = 2;
end
end
end
break;
end
if (FlatIdent_64015 == 0) then
v763 = v247.CurrentCamera;
v764 = v250 and v251("esp_enabled", v249) and (v763 ~= nil);
if ((4029 <= 4853) and not v764) then
local FlatIdent_8C93D = 0;
while true do
if (0 == FlatIdent_8C93D) then
if (v283 or (516 > 3434)) then
for v1183, v1184 in pairs(v272) do
v274(v1184);
end
v283 = false;
end
return;
end
end
end
FlatIdent_64015 = 1;
end
if (FlatIdent_64015 == 3) then
v770 = v251("esp_name", true);
v771 = v251("esp_distance", true);
v772 = v251("esp_tool", false);
FlatIdent_64015 = 4;
end
if (FlatIdent_64015 == 2) then
v767 = v251("esp_text_size", 14);
v768 = v251("esp_width", 0.28);
v769 = v251("esp_box", true);
FlatIdent_64015 = 3;
end
end
end
local function v285()
local FlatIdent_900D9 = 0;
local v779;
local v780;
while true do
if (FlatIdent_900D9 == 0) then
v779, v780 = pcall(v284);
if (not v779 or (588 <= 432)) then
warn("[drift esp] frame error: " .. tostring(v780));
end
break;
end
end
end
local v286 = (v244.PostSimulation or v244.RenderStepped):Connect(v285);
getgenv()[v261] = function()
pcall(function()
v286:Disconnect();
end);
for v943, v944 in pairs(v272) do
v275(v944);
end
v272 = {};
end;
end
local v60, v61 = pcall(v59);
if not v60 then
warn("[drift esp] failed: " .. tostring(v61));
end
getgenv().TeaJujuMenu = v20;
getgenv().TeaJujuFlags = v21;
return v20;
