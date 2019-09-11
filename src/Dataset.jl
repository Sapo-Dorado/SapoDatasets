abstract type Dataset end

#functionality for Datasets
function Base.getindex(dataset::Dataset, i::Int)
    (dataset.getx(dataset, dataset.x[i]), dataset.gety(dataset.y[i]))
end

Base.firstindex(dataset::Dataset) = 1
Base.lastindex(dataset::Dataset) = length(dataset)
Base.length(dataset::Dataset) = length(dataset.x)
Base.iterate(iter::Dataset) = length(iter) > 0 ? (iter[1], 2) : nothing
Base.iterate(iter::Dataset, state) = state > length(iter) ? nothing : (iter[state], state+1)

#an iterable that can be passed into the Flux train! function
struct ImageDataset <: Dataset
    x
    y
    getx
    gety
    size::Int
    set::String
end

#gets an ImageDataset from a LabeledItemList, the default set is the training set, pass in "valid" for set to get the validation dataset
function getimage_dset(list::LabeledItemList, set::String="train")::ImageDataset
    idxs = getfield(list, Symbol(set))
    ImageDataset(list.x[idxs], list.y[idxs], list.getx, list.gety, list.size, set)
end
