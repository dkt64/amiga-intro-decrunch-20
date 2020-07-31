amigeconv.exe -f bitplane -d 5 SAMAR_logo_32col.png SAMAR_logo_32col.raw
amigeconv.exe -f palette -c 32 -p loadrgb4 SAMAR_logo_32col.png SAMAR_logo_32col.pal

amigeconv.exe -f bitplane -d 4 SAMAR_logo_16col.png SAMAR_logo_16col.raw
amigeconv.exe -f palette -c 16 -p loadrgb4 SAMAR_logo_16col.png SAMAR_logo_16col.pal

amigeconv.exe -f bitplane -d 4 fonts16_16col.png fonts16_16col.raw
amigeconv.exe -f palette -c 16 -p loadrgb4 fonts16_16col.png fonts16_16col.pal

amigeconv.exe -f bitplane -d 3 fonts16_8col.png fonts16_8col.raw
amigeconv.exe -f palette -c 8 -p loadrgb4 fonts16_8col.png fonts16_8col.pal

amigeconv.exe -f bitplane -d 3 fonts16_8col-ekran.png fonts16_8col-ekran.raw
amigeconv.exe -f palette -c 8 -p loadrgb4 fonts16_8col-ekran.png fonts16_8col-ekran.pal

amigeconv.exe -f bitplane -d 3 fonty.png fonty.raw
amigeconv.exe -f palette -c 8 -p loadrgb4 fonty.png fonty.pal

amigeconv.exe -f bitplane -d 3 fonty_dark.png fonty_dark.raw
amigeconv.exe -f palette -c 8 -p loadrgb4 fonty_dark.png fonty_dark.pal
