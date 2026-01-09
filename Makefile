build: main.asm constants.asm utils.asm screen.asm objects.asm agent.asm Makefile
	DOCKER_BUILDKIT=1 docker build -o . -t tileworldc64 .

run: build
	xhost +
	docker run -ti --rm --init \
  --network=host \
  -e DISPLAY=${DISPLAY} \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v ${HOME}/.Xauthority:/root/.Xauthority:ro \
  tileworldc64:latest

all: run
