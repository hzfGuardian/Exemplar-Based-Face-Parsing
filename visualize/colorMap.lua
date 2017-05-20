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
      Background    = colorPalette[whi],

      FaceSkin      = colorPalette[yel],

      LeftEyebrow   = colorPalette[red],
      RightEyebrow  = colorPalette[red],

      LeftEye       = colorPalette[blu],
      RightEye      = colorPalette[blu],

      Nose          = colorPalette[pin],

      UpperLip      = colorPalette[gre],

      InnerMouth    = colorPalette[pur],

      LowerLip      = colorPalette[gre],

      Hair          = colorPalette[bro],
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
