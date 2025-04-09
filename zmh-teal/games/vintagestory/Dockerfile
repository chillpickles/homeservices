FROM alpine:3.19

ENV VERSION="1.20.7" \
    VSPATH="/home/vintagestory/server" \
    USERNAME="vintagestory" \
    DATAPATH="/var/vintagestory/data"

RUN apk update && \
    apk upgrade && \
    apk add --no-cache icu-libs krb5-libs libgcc libintl libssl3 libstdc++ zlib && \
    apk add --no-cache bash wget tar procps-ng screen dotnet7-runtime sqlite-libs gcompat

RUN adduser -D  "${USERNAME}"

WORKDIR ${DATAPATH}

RUN mkdir -p "${DATAPATH}" && \
    chown -R "${USERNAME}:${USERNAME}" "${DATAPATH}"
    
WORKDIR ${VSPATH}

COPY entrypoint.sh entrypoint.sh

RUN wget -nv "https://cdn.vintagestory.at/gamefiles/stable/vs_server_linux-x64_${VERSION}.tar.gz" -O vs_server_linux-x64.tar.gz && \
    tar -xzf vs_server_linux-x64.tar.gz && \
    rm vs_server_linux-x64.tar.gz && \
    chmod +x ./server.sh && \
    chmod +x ./entrypoint.sh && \
    chown -R "${USERNAME}:${USERNAME}" "${VSPATH}" && \
    cp /usr/lib/libsqlite3.so.0 ./Lib/libe_sqlite3.so

EXPOSE 42420/tcp

USER ${USERNAME}

ENTRYPOINT ["./entrypoint.sh"]