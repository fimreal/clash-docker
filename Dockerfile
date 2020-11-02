FROM golang:1.14 as builder
WORKDIR /src
# COPY --from=tonistiigi/xx:golang / /
RUN apk add --no-cache make git &&\
    git clone https://github.com/Dreamacro/clash.git &&\
    cd ./clash &&\
    go mod download &&\
    make docker &&\
    mv ./bin/clash-docker /clash

FROM node:14 as dashboard
WORKDIR /opt
RUN git clone https://github.com/Dreamacro/clash-dashboard.git &&\
    cd clash-dashboard &&\
    npm install &&\
    npm run build

FROM alpine
RUN apk --no-cache add git tzdata ca-certificates && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime &&\
    apk del tzdata git &&\
    wget -O /Country.mmdb https://github.com/Dreamacro/maxmind-geoip/releases/latest/download/Country.mmdb &&\
    mkdir -p /conf

COPY --from=dashboard /opt/clash-dashboard/dist /clash-dashboard
COPY --from=builder /clash /

VOLUME ["/conf"]
ENTRYPOINT ["/clash -d /conf"]
