module SapoDatasets

using FileIO, Images, Random

include("ItemList.jl")
export ImageList, ImageList_fromfolder

include("SplitItemList.jl")
export SplitImageList, SplitImageList_byrandpct, SplitImageList_byfunc

include("LabeledItemList.jl")
export LabeledImageList, LabeledImageList_fromfolder, LabeledImageList_fromfunc

include("Dataset.jl")
export ImageDataset, getimage_dset

include("Utils.jl")
export transform

end #module
