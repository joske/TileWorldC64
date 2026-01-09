FROM alpine AS builder

RUN apk update

RUN apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing vice wget openjdk11

RUN wget --user-agent="Mozilla/5.0 (Windows NT x.y; rv:10.0) Gecko/20100101 Firefox/10.0" http://theweb.dk/KickAssembler/KickAssembler.zip -P /tmp/

WORKDIR /app

RUN unzip /tmp/KickAssembler.zip KickAss.jar KickAss.cfg

COPY *.asm .

RUN java -jar KickAss.jar main.asm -debug

CMD [ "x64", "-default", "-console", "main.prg"]

FROM scratch AS export
COPY --from=builder /app/main.prg /
