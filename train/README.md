# Training ENet


## Files/folders and their usage:

* [run.lua](run.lua)    : main file
* [opts.lua](opts.lua)  : contains all the input options used by the tranining script
* [data](data)          : data loaders for loading datasets
* models                : all the model architectures are defined here
* [train.lua](train.lua) : loading of models and error calculation
* [test.lua](test.lua)  : calculate testing error and save confusion matrices

## Example command for training encoder:

```
th run.lua --dataset cs --datapath data/helen --model models/encoder.lua --save save/trained/model/ --imHeight 256 --imWidth 512 --labelHeight 32 --labelWidth 64 -nGPU 1
```

## Example command for training decoder:

```
th run.lua --dataset cs --datapath /Cityscape/dataset/path/ --model models/decoder.lua --imHeight 256 --imWidth 512 --labelHeight 256 --labelWidth 512
```

Use `cachepath` option to save your loaded dataset in `.t7` format so that you won't have to load it again from scratch.
