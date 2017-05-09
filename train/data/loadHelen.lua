----------------------------------------------------------------------
-- Helen Face data loader,
----------------------------------------------------------------------

require 'torch'   -- torch
require 'image'   -- to visualize the dataset

torch.setdefaulttensortype('torch.FloatTensor')
----------------------------------------------------------------------
-- helen dataset:

local trsize, tesize

trsize = 2000 -- helen train images
tesize = 100  -- helen validation images
local classes = {'Background', 'FaceSkin', 'LeftEyebrow', 'RightEyebrow', 'LeftEye', 'RightEye',
                 'Nose', 'UpperLip', 'InnerMouth', 'LowerLip', 'Hair'}
local conClasses = {'FaceSkin', 'LeftEyebrow', 'RightEyebrow', 'LeftEye', 'RightEye',
                 'Nose', 'UpperLip', 'InnerMouth', 'LowerLip', 'Hair'} -- 10 classes

local nClasses = #classes

--------------------------------------------------------------------------------


-- From here #class will give number of classes even after shortening the list
-- nClasses should be used to get number of classes in original list

-- saving training histogram of classes
local histClasses = torch.Tensor(#classes):zero()

print('==> number of classes: ' .. #classes)
print('classes are:')
print(classes)

--------------------------------------------------------------------------------
print '==> loading helen dataset'
local trainData, testData
local loadedFromCache = false
paths.mkdir(paths.concat(opt.cachepath, 'helen'))
local helenCachePath = paths.concat(opt.cachepath, 'helen', 'data.t7')

if opt.cachepath ~= "none" and paths.filep(helenCachePath) then
   local dataCache = torch.load(helenCachePath)
   trainData = dataCache.trainData
   testData = dataCache.testData
   histClasses = dataCache.histClasses
   loadedFromCache = true
   dataCache = nil
   collectgarbage()
else
   local function has_image_extensions(filename)
      local ext = string.lower(path.extension(filename))

      -- compare with list of image extensions
      local img_extensions = {'.jpeg', '.jpg', '.png', '.ppm', '.pgm'}
      for i = 1, #img_extensions do
         if ext == img_extensions[i] then
            return true
         end
      end
      return false
   end

   -- initialize data structures:
   trainData = {
      data = torch.FloatTensor(trsize, opt.channels, opt.imHeight, opt.imWidth),
      labels = torch.FloatTensor(trsize, opt.labelHeight, opt.labelWidth),
      preverror = 1e10, -- a really huge number
      size = function() return trsize end
   }

   testData = {
      data = torch.FloatTensor(tesize, opt.channels, opt.imHeight, opt.imWidth),
      labels = torch.FloatTensor(tesize, opt.labelHeight, opt.labelWidth),
      preverror = 1e10, -- a really huge number
      size = function() return tesize end
   }

   print('==> loading training files');

   exemplarsFile = torch.DiskFile(opt.datapath .. '/exemplars.txt', 'r')

   --load training images and labels:
   for c = 1, trsize do
      -- get ID
      exemplarsFile:readInt();
      -- filter ' , ' 3 characters
      exemplarsFile:readChar(3)
      
      local imgname = exemplarsFile:readString('*l')
      -- process each image
      local dpath = opt.datapath .. '/images/' .. imgname .. '.jpg'

      --load training images:
      local dataTemp = image.load(dpath)
      trainData.data[c] = image.scale(dataTemp, opt.imWidth, opt.imHeight)

      --local finalLbl = torch.ByteTensor(1, dataTemp:size(2), dataTemp:size(3)):zero()

      local box = torch.ByteTensor(#classes, dataTemp:size(2), dataTemp:size(3))

      -- Load training labels:
      -- Load and process labels with same filename as input image.
      for i = 1, #classes do
         local imgid = string.format('%02d', i - 1)
	 local imgPath = opt.datapath .. '/labels/' .. imgname .. '/' .. imgname .. '_lbl' .. imgid .. '.png'

         -- label image data are resized to be [1,nClasses] in [0 255] scale:
         local labelIn = image.load(imgPath, 1, 'byte')
         --local labelFile = image.scale(labelIn, opt.labelWidth, opt.labelHeight, 'simple'):float()
	 --assert(dataTemp:size(2) == labelIn:size(2) and dataTemp:size(3) == labelIn:size(3))
	 box[i] = labelIn
      end

      local maxv, finalLbl = torch.max(box, 1)

      local labelFile = image.scale(finalLbl:byte(), opt.labelWidth, opt.labelHeight, 'simple'):float()

      -- Syntax: histc(data, bins, min, max)
      histClasses = histClasses + torch.histc(labelFile, #classes, 1, #classes)

      -- convert to int and write to data structure:
      trainData.labels[c] = labelFile

      if c % 20 == 0 then
         xlua.progress(c, trsize)
      end
      collectgarbage()
   end

   exemplarsFile:close()


   

   print('==> loading testing files');
   
   testFile = torch.DiskFile(opt.datapath .. '/testing.txt', 'r')

   --load test images and labels:
   for c = 1, tesize do
      -- get ID
      testFile:readInt();
      -- filter ' , ' 3 characters
      testFile:readChar(3)
      
      local imgname = testFile:readString('*l')
      -- process each image
      local dpath = opt.datapath .. '/images/' .. imgname .. '.jpg'

      --load testing images:
      local dataTemp = image.load(dpath)
      testData.data[c] = image.scale(dataTemp, opt.imWidth, opt.imHeight)

      local box = torch.ByteTensor(#classes, dataTemp:size(2), dataTemp:size(3))

      -- Load training labels:
      -- Load and process labels with same filename as input image.
      for i = 1, #classes do
         local imgid = string.format('%02d', i - 1)
         local imgPath = opt.datapath .. '/labels/' .. imgname .. '/' .. imgname .. '_lbl' .. imgid .. '.png'

         -- label image data are resized to be [1,nClasses] in [0 255] scale:
         local labelIn = image.load(imgPath, 1, 'byte')
         --local labelFile = image.scale(labelIn, opt.labelWidth, opt.labelHeight, 'simple'):float()
         --assert(dataTemp:size(2) == labelIn:size(2) and dataTemp:size(3) == labelIn:size(3))
         box[i] = labelIn
      end

      local maxv, finalLbl = torch.max(box, 1)

      local labelFile = image.scale(finalLbl:byte(), opt.labelWidth, opt.labelHeight, 'simple'):float()

      -- convert to int and write to data structure:
      testData.labels[c] = labelFile

      if c % 20 == 0 then
         xlua.progress(c, tesize)
      end
      collectgarbage()
   end

   testFile:close()

end

if opt.cachepath ~= "none" and not loadedFromCache then
   print('==> saving data to cache: ' .. helenCachePath)
   local dataCache = {
      trainData = trainData,
      testData = testData,
      histClasses = histClasses
   }
   torch.save(helenCachePath, dataCache)
   dataCache = nil
   collectgarbage()
end

----------------------------------------------------------------------
print '==> verify statistics'

-- It's always good practice to verify that data is properly
-- normalized.

for i = 1, opt.channels do
   local trainMean = trainData.data[{ {},i }]:mean()
   local trainStd = trainData.data[{ {},i }]:std()

   local testMean = testData.data[{ {},i }]:mean()
   local testStd = testData.data[{ {},i }]:std()

   print('training data, channel-'.. i ..', mean: ' .. trainMean)
   print('training data, channel-'.. i ..', standard deviation: ' .. trainStd)

   print('test data, channel-'.. i ..', mean: ' .. testMean)
   print('test data, channel-'.. i ..', standard deviation: ' .. testStd)
end

----------------------------------------------------------------------

local classes_td = {[1] = 'classes,targets\n'}
for _,cat in pairs(classes) do
   table.insert(classes_td, cat .. ',1\n')
end

local file = io.open(paths.concat(opt.save, 'categories.txt'), 'w')
file:write(table.concat(classes_td))
file:close()

-- Exports
opt.dataClasses = classes
opt.dataconClasses  = conClasses
opt.datahistClasses = histClasses

return {
   trainData = trainData,
   testData = testData,
   mean = trainMean,
   std = trainStd
}
