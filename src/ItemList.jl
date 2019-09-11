abstract type ItemList end

#functionality for Itemlists
Base.getindex(itemList::ItemList, i::Int) = itemList.get(itemList, itemList.items[i])
Base.firstindex(itemList::ItemList) = 1
Base.lastindex(itemList::ItemList) = length(itemList)
Base.length(itemList::ItemList) = length(itemList.items)
Base.iterate(iter::ItemList) = length(iter) > 0 ? (iter[1], 2) : nothing
Base.iterate(iter::ItemList, state) = state > length(iter) ? nothing : (iter[state], state+1)

defaultsuffixes = ["jpg", "jpeg","png", "tif"]

#gets the suffix of a given path
function getsuffix(path::String)::String
    split(path, '.')[end]
end

#checks to see if file has one of the accepted suffixes
function isimage(path::String, suffixes::Array{String,1})::Bool
    suffix = getsuffix(path)
    suffix in suffixes
end

#gets all files from a path. 
function getfiles(path::String, recurse::Bool, suffixes::Array{String,1})::Array{String,1}
    #ignores hidden files and directories
    function getfilesiter(path::String, items, recurse::Bool, suffixes::Array{String,1})::Array{String,1}
    for item in readdir(path)
        ipath = joinpath(path, item)
        if (isimage(ipath, suffixes) && item[1] != '.')
            push!(items, ipath)
        elseif (isdir(ipath) && recurse && item[1] != '.')
            getfilesiter(ipath, items, recurse, suffixes)
        end
    end
    items
    end
    if path[end] == '/'
        path = path[1:end-1]
    end
    getfilesiter(path, [], recurse, suffixes)
end

#an ItemList where the items are images
mutable struct ImageList <: ItemList
    items
    get
    size::Int
end

#the default function to retrieve an image in the desired format from a filename
function imagelistget(imageList, item)
    size = imageList.size
    img = channelview(RGB.(imresize(load(item), (size,size))))
    reshape(img, (size,size, 3))
end

#construct an ImageList from an array of filenames and a size
ImageList(items, size::Int) = ImageList(items, imagelistget, size)

#construct an ImageList from images in a folder
function ImageList_fromfolder(folderpath::String, size::Int=500, recurse::Bool=true, suffixes::Array{String,1}=defaultsuffixes)::ImageList
    #make sure there are no non-image files in the directory. It automatically ignores hidden directories.
    ImageList(getfiles(folderpath, recurse, suffixes), size)
end
