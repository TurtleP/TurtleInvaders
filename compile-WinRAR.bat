@echo off

del game.zip /q

echo Zipping files..
if exist ""C:\Program Files\WinRAR\" (
"C:\Program Files\WinRAR\WinRAR.exe" a -r game.zip * *
)

echo Renaming zip to love..
ren game.zip game.love