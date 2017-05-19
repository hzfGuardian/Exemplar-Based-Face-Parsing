--------------------------------------------------------------------------------
-- Returns the color map for a given set of classes.
--
-- If you want to add more classes then modifiy section "Colors => Classes"
--
-- Written by: Abhishek Chaurasia, Sangpil Kim
-- Date      : March, 2016
--------------------------------------------------------------------------------

local colorMap = {}

-- Map color names to a shorter name
local red = 'red'
local gre = 'green'
local blu = 'blue'

local mag = 'magenta'
local yel = 'yellow'
local cya = 'cyan'

local gra = 'gray'
local whi = 'white'
local bla = 'black'

local lbl = 'lemonBlue'
local bro = 'brown'
local neg = 'neonGreen'
local pin = 'pink'
local pur = 'purple'
local kha = 'khaki'
local gol = 'gold'

-- Create color palette for all the defined colors
local colorPalette = {[red] = {1.0, 0.0, 0.0},
                      [gre] = {0.0, 1.0, 0.0},
                      [blu] = {0.0, 0.0, 1.0},
                      [mag] = {1.0, 0.0, 1.0},
                      [yel] = {1.0, 1.0, 0.0},
                      [cya] = {0.0, 1.0, 1.0},
                      [gra] = {0.3, 0.3, 0.3},
                      [whi] = {1.0, 1.0, 1.0},
                      [bla] = {0.0, 0.0, 0.0},
                      [lbl] = {30/255, 144/255,  255/255},
                      [bro] = {139/255, 69/255,   19/255},
                      [neg] = {202/255, 255/255, 112/255},
                      [pin] = {255/255, 20/255,  147/255},
                      [pur] = {128/255, 0/255,   128/255},
                      [kha] = {240/255, 230/255, 140/255},
                      [gol] = {255/255, 215/255,   0/255}}

-- Default color is chosen as black
local defaultColor = colorPalette[bla]

local function prepDrivingColors(classes)
   local colors = {}

   local mapping = {
      Background    = {1.0, 1.0, 1.0},

      FaceSkin      = {255/255, 253/255,  75/255},

      LeftEyebrow   = {243/255, 129/255,  130/255},
      RightEyebrow  = {206/255, 34/255,  35/255},

      LeftEye       = {31/255, 116/255,  174/255},
      RightEye      = {94/255, 199/255,  253/255},

      Nose          = {253/255, 136/255,  63/255},

      UpperLip      = {135/255, 234/255,  121/255},

      InnerMouth    = {253/255, 57/255,  252/255},

      LowerLip      = {15/255, 126/255,  18/255},

      Hair          = {55/255, 51/255,  52/255},
   }

   for i,class in ipairs(classes) do
      colors[i] = mapping[class] or defaultColor
   end

   colorMap.getColors = function()
      return colors
   end
end


function colorMap:init(opt, classes)
   prepDrivingColors(classes)
end

return colorMap
