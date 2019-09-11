abstract type LabeledItemList end

#functionality for LabeledItemLists
function Base.getindex(labeledItemList::LabeledItemList, i::Int)
    set = i in labeledItemList.train ? "Train" : "Valid"
    (labeledItemList.getx(labeledItemList, labeledItemList.x[i]), labeledItemList.gety(i), set)
end

Base.firstindex(labeledItemList::LabeledItemList) = 1
Base.lastindex(labeledItemList::LabeledItemList) = length(labeledItemList)
Base.length(labeledItemList::LabeledItemList) = length(labeledItemList.x)
Base.iterate(iter::LabeledItemList) = length(iter) > 0 ? (iter[1], 2) : nothing
Base.iterate(iter::LabeledItemList, state) = state > length(iter) ? nothing : (iter[state], state+1)

#like a SplitImageList but it contains labels
mutable struct LabeledImageList <: LabeledItemList
    x
    y
    getx
    gety
    size::Int
    train::Array{Int,1}
    valid::Array{Int,1}
end

#constructs a LabeledImageList using the foldername as a label
function LabeledImageList_fromfolder(sil::SplitImageList, directoriesup::Int=1, gety=identity)::LabeledImageList
    labels = []
    for i in sil.items
        push!(labels, split(i,"/")[end-directoriesup])
    end
    LabeledImageList(sil.items, labels, sil.get, gety, sil.size, sil.train, sil.valid)
end

#labels each x by a function that takes each element of x as an argument and returns a label for that x
function LabeledImageList_fromfunc(sil::SplitImageList, f, gety=identity)
    labels = []
    for i in sil.items
        push!(labels, f(i))
    end
    LabeledImageList(sil.items, labels, sil.get, gety, sil.size, sil.train, sil.valid)
end
