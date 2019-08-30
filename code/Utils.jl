#changes the size of the images accesed by the list
transform(list::Union{ItemList,SplitItemList,LabeledItemList}, newSize::Int) = list.size = newSize 


