# TileWorldC64

attempt at tileworld in 6510 assembly (using kick assembler)

assemble with kickass grid.asm
run with vice: x64 grid.prg

Docker:

docker build -t tileworldc64 . 

macOS:

docker run -ti -e DISPLAY=host.docker.internal:0 --rm --init tileworldc64

linux:

docker run -ti -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix:rw --volume="$HOME/.Xauthority:/root/.Xauthority:rw" --network=host --privileged --rm --init tileworldc64