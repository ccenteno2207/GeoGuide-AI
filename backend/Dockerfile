FROM eclipse-temurin:21-jdk-jammy AS build

WORKDIR /workspace

COPY .mvn .mvn
COPY mvnw pom.xml ./
RUN chmod +x mvnw \
    && ./mvnw --batch-mode --no-transfer-progress dependency:go-offline

COPY src src
RUN ./mvnw --batch-mode --no-transfer-progress package \
    && cp "$(find target -maxdepth 1 -type f -name '*.jar' ! -name '*.jar.original' -print -quit)" /workspace/app.jar

FROM eclipse-temurin:21-jre-jammy AS runtime

RUN groupadd --system --gid 10001 geoguide \
    && useradd --system --uid 10001 --gid geoguide \
        --home-dir /app --shell /usr/sbin/nologin geoguide

WORKDIR /app

COPY --from=build --chown=10001:10001 /workspace/app.jar /app/app.jar

USER 10001:10001

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
