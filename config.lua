Config          = {} -- DO NOT MODIFY THIS LINE OF CODE
DREAM_TRANSLATE = {} -- DO NOT MODIFY THIS LINE OF CODE

--- Language configuration setting.
-- This sets the active language for translations in the system.
---@usage Config.LANGUAGE = 'en'  -- This sets the language to English.
---@field Config.LANGUAGE string (only 'en', 'es', 'fr', or 'et' are valid). 
-- If you want to add more languages, follow the format in the code or open a ticket 
-- in the Discord for assistance.
Config.LANGUAGE = 'en' -- 'en' | 'es | 'fr' | 'et'

Config.NOTIFY    = 'qb' -- 'qb' | 'ox' | 'esx' | 'esx-new' | 'okok' | 'mythic' | 'chat'
Config.TARGET    = 'ox' -- 'ox' | 'qb-target'
Config.FRAMEWORK = 'qb' -- 'qb' | 'esx' | 'esx-old'
-- COMMENT OUT GET_CORE if using 'esx' or 'esx-old'
-- optional to fill in, if you use qb-core this is your getCoreObject function you use.
Config.GET_CORE  = exports['qb-core']:GetCoreObject()

Config.DEBUG = false -- debug target boxes

-- Whether or not to only allow a certain job to do postal deliveries
Config.IS_WHITELISTED_TO_JOB = false
-- IF we are whitelisting to a job, whats the job code name?
Config.WHITELISTED_JOB_TITLE = 'postal'

-- Start job ped location
Config.POSTAL_BOSS_COORDS   = vec3(132.9577, 96.1347, 82.5076)
Config.POSTAL_BOSS_HEADING = 149.7562

-- Start job ped hash and animation
Config.POSTAL_BOSS_HASH      = "s_m_y_construct_01"
Config.POSTAL_BOSS_ANIMATION = 'WORLD_HUMAN_SMOKING'

-- Hash for the peds that you drop off packages to
Config.DROP_OFF_PED_HASH = 's_m_y_construct_01'

-- GoPostal Van hash & spawn location
Config.POSTAL_VEHICLE_HASH         = 'boxville2'
Config.POSTAL_VEHICLE_SPAWN_COORDS = vec4(130.4967, 88.7683, 82.1197, 248.5475)

-- Pay multiplier for the job. Increase this for players to be compensated higher for their work
Config.PAY_MULTIPLIER = 1.5

-- Whether or not to show the white arrow marker above the drop off ped & blue postal boxes.
Config.SHOW_WHITE_ARROW_MARKER = true

-- List of coordinates that hold the pick-up locations for the packages.
-- TO FIND MORE LOCATIONS:
-- 1. Execute /pbox to find a singular location.
    -- OR
-- 1. Execute /pbox_record to record while driving around an area.
-- 2. Execute /pbox_record again, press F8, click "open log."
-- 3. Scroll to the bottom of the log and copy the coordinates to paste here.
Config.POSTAL_GET_PACKAGE = {
    -- LOS SANTOS NORTH
    vec3(-323.078491, 134.504517, 67.35902),
    vec3(-53.839478, -98.676315, 56.827251),
    vec3(-187.542511, -705.314514, 33.244240),
    vec3(295.385590, -807.888123, 28.498571),
    vec3(326.326294, 167.189301, 102.619774),
    vec3(307.589844, 170.769867, 102.986595),
    vec3(153.433044, 227.441101, 105.780258),
    vec3(-600.122681, 248.795181, 81.107666),
    vec3(-766.215881, 296.359283, 84.636642),
    vec3(-636.977966, -44.572495, 40.186691),
    vec3(-482.202667, -95.242828, 37.794426),
    vec3(-428.830994, 15.493083, 45.231766),
    vec3(-283.298157, -53.000946, 48.402122),
    vec3(-18.833746, -113.394592, 55.930458),
    vec3(117.796082, -164.124115, 53.729416),
    vec3(296.954132, -230.189331, 52.974747),
    vec3(-524.203735, 120.499626, 62.139957),
    vec3(-536.556152, 22.218126, 43.196259),
    vec3(-480.823608, -10.993633, 44.317047),
    vec3(-67.025841, -605.798523, 35.280388),
    vec3(426.046722, 100.209526, 99.240730),
    -- MIRROR PARK
    -- vec3(1027.731689, -442.544647, 64.079712),
    -- vec3(969.939209, -484.359680, 60.898602),
    -- vec3(907.932922, -582.194519, 56.356152),
    -- vec3(953.144470, -617.881775, 56.462154),
    -- vec3(1054.123535, -513.852722, 60.979992),
    -- vec3(1196.780029, -481.621765, 64.917358),
    -- vec3(1183.783447, -429.318054, 66.155273),
    -- vec3(1263.393066, -513.101501, 68.099869),
    -- vec3(1357.536133, -589.729919, 73.354652),
    -- vec3(1284.786133, -685.361023, 64.365189),
    -- vec3(1186.130615, -530.301208, 63.789410),
    -- vec3(984.690247, -650.227722, 56.524471),
}

-- List of coordinates that hold the drop-off locations for the packages.
-- *NOTE: These are vec4, please be sure to input the heading.
Config.POSTAL_DROP_OFF_PACKAGE = {
    vec4(207.2148, -85.1660, 69.1744, 344.0340),
    vec4(319.9483, -121.5708, 68.3529, 320.1133),
    vec4(330.2487, -202.4634, 54.0863, 162.6433),
    vec4(-315.4421, -3.8527, 48.2074, 165.7263),
    vec4(-482.8853, -17.0622, 45.1096, 351.9960),
    vec4(121.7368, 40.6532, 73.5203, 229.5111),
    vec4(401.0720, 98.8446, 101.4821, 13.2281),
    vec4(172.5186, 183.4933, 105.7279, 327.3230),
    vec4(-85.1545, 38.4993, 71.8986, 327.5721),
    vec4(-599.0895, -251.0332, 36.2791, 282.6309),
    vec4(-722.4756, -98.1867, 38.2038, 21.0452),
    vec4(825.2067, -96.1942, 80.5994, 336.3137),
    vec4(-96.1451, 44.0776, 71.7142, 329.3442),
    vec4(-88.8524, 214.9003, 96.4104, 181.5158),
    vec4(-239.0045, 205.8020, 83.8769, 268.3860),
}

-- Male outfit configuration tied to the GoPostal job
Config.MALE_OUTFIT     = {
    mask               = 0,  -- [1]
    maskTexture        = 0,  -- [1]
    hand               = 11, -- [3]
    handTexture        = 0,  -- [3]
    pants              = 10, -- [4]
    pantsTexture       = 2,  -- [4]
    backpack           = 0,  -- [5]
    backpackTexture    = 0,  -- [5]
    shoes              = 54, -- [6]
    shoesTexture       = 0,  -- [6]
    accessories        = 0,  -- [7]
    accessoriesTexture = 0,  -- [7]
    shirt              = 57, -- [8]
    shirtTexture       = 0,  -- [8]
    bodyArmor          = 0,  -- [9]
    bodyArmorTexture   = 0,  -- [9]
    decal              = 0,  -- [10]
    decalTexture       = 0,  -- [10]
    jacket             = 13, -- [11]
    jacketTexture      = 0,  -- [11]
    glasses            = 15, -- N/A
    glassesTexture     = 6,  -- N/A
}

-- Female outfit configuration tied to the GoPostal job
Config.FEMALE_OUTFIT   = {
    mask               = 0,   -- [1]
    maskTexture        = 0,   -- [1]
    hand               = 14,  -- [3]
    handTexture        = 0,   -- [3]
    pants              = 47,  -- [4]
    pantsTexture       = 0,   -- [4]
    backpack           = 0,   -- [5]
    backpackTexture    = 0,   -- [5]
    shoes              = 27,  -- [6]
    shoesTexture       = 0,   -- [6]
    accessories        = 0,   -- [7]
    accessoriesTexture = 0,   -- [7]
    shirt              = 1,   -- [8]
    shirtTexture       = 0,   -- [8]
    bodyArmor          = 0,   -- [9]
    bodyArmorTexture   = 0,   -- [9]
    decal              = 0,   -- [10]
    decalTexture       = 0,   -- [10]
    jacket             = 250, -- [11]
    jacketTexture      = 0,   -- [11]
    glasses            = 0,   -- N/A
    glassesTexture     = 4,   -- N/A
}

-- Map blip for where the player starts the GoPostal job
Config.GO_POSTAL_HQ_BLIP = {
    sprite  = 738,
    display = 4,
    scale   = 0.8,
    colour  = 6,
    label   = 'GoPostal HQ',
}

-- Map blip for package pick-up locations (blue postal box spots)
Config.PICK_UP_BLIP = {
    sprite  = 351,
    display = 4,
    scale   = 1.5,
    colour  = 38,
    label   = 'Package Pick up',
}

-- Map blip for package drop-off locations
Config.DROP_OFF_BLIP = {
    sprite  = 280,
    display = 4,
    scale   = 1.5,
    colour  = 38,
    label   = 'Package Drop off',
}
