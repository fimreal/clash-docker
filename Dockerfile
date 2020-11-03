FROM golang:1.14 as builder
WORKDIR /src
RUN git clone https://github.com/Dreamacro/clash.git &&\
    cd ./clash &&\
    go mod download &&\
    make docker
  # mv ./bin/clash-docker /clash

FROM node:14 as dashboard
WORKDIR /opt
RUN git clone https://github.com/Dreamacro/clash-dashboard.git &&\
    cd clash-dashboard &&\
    npm install &&\
    npm run build

FROM alpine
RUN apk --no-cache add tzdata ca-certificates && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime &&\
    apk del tzdata &&\
    wget -O /Country.mmdb https://github.com/Dreamacro/maxmind-geoip/releases/latest/download/Country.mmdb &&\
    mkdir -p /conf

COPY --from=dashboard /opt/clash-dashboard/dist /clash-dashboard
COPY --from=builder /src/bin/clash-docker /clash

VOLUME ["/conf"]
ENTRYPOINT ["/clash -d /conf"]
