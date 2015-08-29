@echo off

del game.love /q

echo Zipping files..
if exist "C:\Program Files\7-Zip\" (
"C:\Program Files\7-Zip\7z" a -tzip game.zip * * -mx5
)

echo Renaming zip to love..
ren game.zip game.love
