# Dockerfile
# Etapa 1: Descargar dependencias
FROM alpine:latest AS downloader
RUN apk add --no-cache curl

# Descargar Cloud SQL Socket Factory
RUN curl -L https://repo1.maven.org/maven2/com/google/cloud/sql/mysql-socket-factory/1.25.1/mysql-socket-factory-1.25.1-jar-with-dependencies.jar \
    -o /tmp/mysql-socket-factory.jar

# Descargar Cloud SQL Proxy
RUN curl -L https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 \
    -o /tmp/cloud_sql_proxy && chmod +x /tmp/cloud_sql_proxy

# Etapa 2: Imagen final basada en Traccar
FROM traccar/traccar:latest

USER root
RUN apt-get update && \
    apt-get install -y curl procps && \
    rm -rf /var/lib/apt/lists/*

# Copiar el conector de Cloud SQL
COPY --from=downloader /tmp/mysql-socket-factory.jar /opt/traccar/lib/mysql-socket-factory.jar

# Copiar Cloud SQL Proxy
COPY --from=downloader /tmp/cloud_sql_proxy /usr/local/bin/cloud_sql_proxy

# Copiar la configuración personalizada
COPY traccar.xml /opt/traccar/conf/traccar.xml

# Crear script de inicio
RUN cat > /opt/traccar/start.sh << 'EOF'
#!/bin/bash

cleanup() {
    echo "Deteniendo servicios..."
    kill $TRACCAR_PID 2>/dev/null || true
    kill $PROXY_PID 2>/dev/null || true
    wait
    exit 0
}
trap cleanup SIGTERM SIGINT

if [ ! -f "$GOOGLE_APPLICATION_CREDENTIALS" ]; then
    echo "Advertencia: No se encontró archivo de credenciales. Iniciando Traccar sin proxy..."
    java -Xms1g -Xmx2g -Djava.net.preferIPv4Stack=true \
         -jar /opt/traccar/tracker-server.jar /opt/traccar/conf/traccar.xml &
    TRACCAR_PID=$!
else
    echo "Iniciando Cloud SQL Proxy..."
    cloud_sql_proxy \
      -instances=ave-asistencia-vehicular:us-central1:traccar-db-mysql=tcp:3306 &
    PROXY_PID=$!
    sleep 5
    echo "Iniciando Traccar..."
    java -Xms1g -Xmx2g -Djava.net.preferIPv4Stack=true \
         -jar /opt/traccar/tracker-server.jar /opt/traccar/conf/traccar.xml &
    TRACCAR_PID=$!
fi

wait $TRACCAR_PID
EOF

RUN chmod +x /opt/traccar/start.sh

USER traccar

EXPOSE 8080
EXPOSE 5001-5050/tcp
EXPOSE 5001-5050/udp

CMD ["/opt/traccar/start.sh"]
