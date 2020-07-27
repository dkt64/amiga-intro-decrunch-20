cd ../bin
amigeconv.exe -f bitplane -d 6 ../gfx/logo.png ../gfx/logo.raw
amigeconv.exe -f palette -c 32 -p loadrgb4 ../gfx/logo.png ../gfx/logo.pal
cd ../gfx