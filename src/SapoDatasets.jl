module SapoDatasets

using FileIO, Images, Random, Flux
using CUDAapi
if has_cuda()
    using CudaArrays
end

include("ItemList.jl")
export ImageList, ImageList_fromfolder

include("SplitItemList.jl")
export SplitImageList, SplitImageList_byrandpct, SplitImageList_byfunc

include("LabeledItemList.jl")
export LabeledImageList, LabeledImageList_fromfolder, LabeledImageList_fromfunc

include("Dataset.jl")
export ImageDataset, getimage_dset, get_cuimage_dset

include("Trainer.jl")
export Trainer, fit, fit_one_cycle, predict 

include("Utils.jl")
export transform

end #module
