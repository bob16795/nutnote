nim c -d:mingw -d:release --opt:speed -d:fontaa --app:gui -o:win/main.exe main
cp content.bin win
cp stdlib -r win
cp avg.nim -r win
cp font.ttf -r win
pushd win
zip win.zip * -r
popd
