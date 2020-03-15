#!/usr/bin/env bash

case "$(uname)" in
Linux*)     
    echo "Linux"
    find . -name "*.lua" -or -name "*.wav" -or -name "*.png" ! -name "correct-filelist.lua" | apack monochrome-tetris.zip
    scp monochrome-tetris.zip dekar@visualdoj.ru:/home/dekar/www/packages
    ssh dekar@visualdoj.ru /home/dekar/bin/update_index.lua
    rm monochrome-tetris.zip
    ;;
MINGW*)     
    echo "MinGW"
    find . -name "*.lua" -or -name "*.wav" -or -name "*.png" ! -name "correct-filelist.lua" > files.txt
    ./correct-filelist.lua files.txt
    #cat files.txt
    /c/Program\ Files/7-Zip/7z.exe a monochrome-tetris.zip @files_.txt
    rm files.txt
    rm files_.txt
    scp monochrome-tetris.zip dekar@visualdoj.ru:/home/dekar/www/packages
    ssh dekar@visualdoj.ru /home/dekar/bin/update_index.lua
    rm monochrome-tetris.zip
    ;;
*)          
    echo "Unknown system"
esac
