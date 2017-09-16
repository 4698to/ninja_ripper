(
local mapfiles=#()


fn addmap mapfile =(
    local mapfileN=mapfile as name
    --print (mapfieleN)
    local index=finditem mapfiles mapfileN
    --print(index)
    if index == 0 do append mapfiles mapfileN
)


enumeratefiles addmap
sort mapfiles

for mapfile in mapfiles do
    (

    f_name=filenameFromPath mapfile
    new_fpath=maxfilepath + f_name
    copyFile mapfile new_fpath


    )
)

