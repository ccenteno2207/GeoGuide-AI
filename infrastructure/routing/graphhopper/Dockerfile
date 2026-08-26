FROM eclipse-temurin:21-jre-jammy

ARG GRAPHHOPPER_VERSION=11.0
ARG GRAPHHOPPER_SHA256=b59c024afe172ec6ec85b6327006c3138ec58c7d0bcd26253d0e42853f613def

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd --gid 10001 graphhopper \
    && useradd --uid 10001 --gid graphhopper --no-create-home --shell /usr/sbin/nologin graphhopper \
    && install -d -o graphhopper -g graphhopper /opt/graphhopper /data/graph-cache \
    && curl --fail --silent --show-error --location \
       "https://repo.maven.apache.org/maven2/com/graphhopper/graphhopper-web/${GRAPHHOPPER_VERSION}/graphhopper-web-${GRAPHHOPPER_VERSION}.jar" \
       --output /opt/graphhopper/graphhopper-web.jar \
    && echo "${GRAPHHOPPER_SHA256}  /opt/graphhopper/graphhopper-web.jar" | sha256sum --check --strict

COPY --chown=graphhopper:graphhopper config.yml /opt/graphhopper/config.yml

USER graphhopper
WORKDIR /opt/graphhopper

EXPOSE 8989 8990

ENTRYPOINT ["java"]
CMD ["-Xms512m", "-Xmx4g", "-jar", "/opt/graphhopper/graphhopper-web.jar", "server", "/opt/graphhopper/config.yml"]
