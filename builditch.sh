nim c -d:mingw -d:release -d:ginAppName:"Nutnote" -d:ginIcon:$PWD/Aseprite/icon.ico --opt:speed -d:fontaa --app:gui -o:win/main.exe main
cp content.bin win
cp nnrc.nim scripts stdlib -r win
cp font.ttf -r win
pushd win
zip win.zip * -r
popd

nim c -d:release --opt:speed -d:fontaa -d:ginAppName:"Nutnote" --app:gui -o:lin/main main
cp content.bin lin
cp nnrc.nim scripts stdlib -r lin
cp font.ttf -r lin
pushd lin
zip linux.zip * -r
popd

butler push win/win.zip prestosilver/nutnote:windows
butler push lin/linux.zip prestosilver/nutnote:linux

./pushexample.sh
