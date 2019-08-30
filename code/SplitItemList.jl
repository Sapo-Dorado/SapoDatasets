abstract type SplitItemList end

#functionality for SplitItemLists
function Base.getindex(splitItemList::SplitItemList, i::Int)
    set = i in splitItemList.train ? "Train" : "Valid"
    (splitItemList.get(splitItemList, splitItemList.items[i]), set)
end
Base.firstindex(splitItemList::SplitItemList) = 1
Base.lastindex(splitItemList::SplitItemList) = length(splitItemList)
Base.length(splitItemList::SplitItemList) = length(splitItemList.items)
Base.iterate(iter::SplitItemList) = length(iter) > 0 ? (iter[1], 2) : nothing
Base.iterate(iter::SplitItemList, state) = state > length(iter) ? nothing : (iter[state], state+1)

#Like an ImageList but split into a training and validation set
mutable struct SplitImageList <: SplitItemList
    items
    get
    size::Int
    train::Array{Int,1}
    valid::Array{Int,1}
end

#construct a SplitImageList by splitting the data randomly into a training and validation set of a specified size
function SplitImageList_byrandpct(il::ImageList, valpct::Float64=0.2)::SplitImageList
    if (valpct < 0 || valpct > 1)
        throw(ArgumentError("valpct must be between 0 and 1"))
    end
    numitems = Int(round(length(il) * valpct))
    perm = randperm(length(il))
    SplitImageList(il.items, il.get, il.size, sort(perm[numitems+1:end]), sort(perm[1:numitems]))
end
