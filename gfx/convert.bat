cd ../bin
amigeconv.exe -f bitplane -d 4 ../gfx/logo.png ../gfx/logo.raw
amigeconv.exe -f palette -c 16 -p loadrgb4 ../gfx/logo.png ../gfx/logo.pal
cd ../gfx