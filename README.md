# TileWorldC64

attempt at tileworld in 6510 assembly (using kick assembler)

assemble with

```
kickass main.asm
```

Docker:

```
docker build -t tileworldc64 .
```

or just

```
make build
```

## Running on macOS

#### Directly

install vice emulator and run directly:

```
x64 main.prg
```

#### Docker

this requires XQuartz installed and running

```
docker run -ti -e DISPLAY=host.docker.internal:0 --rm --init tileworldc64
```

## Running on Linux

```
docker run -ti -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix:rw --volume="$HOME/.Xauthority:/root/.Xauthority:rw" --network=host --privileged --rm --init tileworldc64
```

or

```
x64 main.prg
```
