DIR=$(HOME)/roms
EMU=uxncli
ASM=${EMU} ${DIR}/drifblim.rom

.PHONY: run blog clean

# Blog output is rebuilt every time so removed entries cannot survive in the feed.
run: bin/oscean.rom blog
	@ mkdir -p tmp site
	@ rm -f tmp/* site/*
	@ echo "HTML(site)"
	@ ${EMU} bin/oscean.rom

blog: bin/log.rom
	@ mkdir -p src/htm links
	@ echo "HTML(blog) RSS(log)"
	@ ${EMU} bin/log.rom

bin/oscean.rom: src/oscean.tal
	@ mkdir -p bin
	@ ${ASM} src/oscean.tal bin/oscean.rom

bin/log.rom: src/log.tal
	@ mkdir -p bin
	@ ${ASM} src/log.tal bin/log.rom

clean:
	@ rm -f bin/*.rom bin/*.sym tmp/* site/* links/log.xml src/htm/blog.htm src/htm/sitemap.htm
