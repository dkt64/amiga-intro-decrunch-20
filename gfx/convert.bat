amigeconv.exe -f bitplane -d 5 logo.png logo.raw
amigeconv.exe -f palette -c 32 -p loadrgb4 logo.png logo.pal
amigeconv.exe -f bitplane -d 4 fonts.png fonts.raw
amigeconv.exe -f palette -c 16 -p loadrgb4 fonts.png fonts.pal