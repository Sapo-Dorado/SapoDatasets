abstract type Dataset end

#functionality for Datasets
function Base.getindex(dataset::Dataset, idx::Int)
    first = (idx - 1) * dataset.bs + 1
    last = length(dataset) > idx ? first + dataset.bs - 1 : lastindex(dataset.x)
    [(dataset.getx(dataset, dataset.x[dataset.randorder[i]]), dataset.gety(dataset.y[dataset.randorder[i]])) for i in first:last]
end

Base.firstindex(dataset::Dataset) = 1
Base.lastindex(dataset::Dataset) = length(dataset) 
Base.length(dataset::Dataset) = cld(length(dataset.x), dataset.bs)
function Base.iterate(iter::Dataset)
    iter.randorder = randperm(length(iter.x))
    length(iter) > 0 ? (iter[1], 2) : nothing
end
Base.iterate(iter::Dataset, state) = state > length(iter) ? nothing : (iter[state], state+1)

#an iterable that can be passed into the Flux train! function
mutable struct ImageDataset <: Dataset
    x
    y
    getx
    gety
    size::Int
    set::String
    bs::Int
    randorder
end

#gets an ImageDataset from a LabeledItemList, the default set is the training set, pass in "valid" for set to get the validation dataset
function getimage_dset(list::LabeledItemList, bs::Int, set::String="train")::ImageDataset
    idxs = getfield(list, Symbol(set))
    ImageDataset(list.x[idxs], list.y[idxs], list.getx, list.gety, list.size, set, bs, randperm(length(idxs)))
end

function get_cuimage_dset(list::LabeledItemList, bs::Int, set::String="train")::ImageDataset
    idxs = getfield(list, Symbol(set))
    getx(il, x) = CuArray(list.getx(il,x))
    ImageDataset(list.x[idxs], list.y[idxs], getx, list.gety, list.size, set, bs, randperm(length(idxs)))
end
