# Etapa 1: Descargar dependencias
FROM alpine:latest as downloader
RUN apk add --no-cache curl

# Descargar Cloud SQL Socket Factory
RUN curl -L https://repo1.maven.org/maven2/com/google/cloud/sql/mysql-socket-factory/1.25.1/mysql-socket-factory-1.25.1-jar-with-dependencies.jar -o /tmp/mysql-socket-factory.jar

# Descargar Cloud SQL Proxy
RUN curl -L https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -o /tmp/cloud_sql_proxy && \
    chmod +x /tmp/cloud_sql_proxy

# Etapa 2: Imagen final
FROM traccar/traccar:latest

# Instalar herramientas necesarias
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

# Función para limpiar procesos al recibir SIGTERM
cleanup() {
    echo "Deteniendo servicios..."
    kill $TRACCAR_PID 2>/dev/null || true
    kill $PROXY_PID 2>/dev/null || true
    wait
    exit 0
}

# Configurar manejo de señales
trap cleanup SIGTERM SIGINT

# Verificar si existe archivo de credenciales de servicio
if [ ! -f "$GOOGLE_APPLICATION_CREDENTIALS" ]; then
    echo "Advertencia: No se encontró archivo de credenciales. Usando conexión directa."
    # Iniciar solo Traccar
    java -Xms1g -Xmx2g \
         -Djava.net.preferIPv4Stack=true \
         -jar /opt/traccar/tracker-server.jar \
         /opt/traccar/conf/traccar.xml &
    TRACCAR_PID=$!
else
    echo "Iniciando Cloud SQL Proxy..."
    # Iniciar Cloud SQL Proxy en background
    cloud_sql_proxy -instances=PROJECT_ID:us-central1:traccar-db-mysql=tcp:3306 &
    PROXY_PID=$!
    
    # Esperar un momento para que el proxy se inicie
    sleep 5
    
    echo "Iniciando Traccar..."
    # Iniciar Traccar
    java -Xms1g -Xmx2g \
         -Djava.net.preferIPv4Stack=true \
         -jar /opt/traccar/tracker-server.jar \
         /opt/traccar/conf/traccar.xml &
    TRACCAR_PID=$!
fi

# Esperar a que terminen los procesos
wait $TRACCAR_PID
EOF

# Hacer ejecutable el script
RUN chmod +x /opt/traccar/start.sh

# Cambiar al usuario traccar
USER traccar

# Exponer el puerto
EXPOSE 8080

# Exponer puertos GPS
EXPOSE 5001-5050/tcp
EXPOSE 5001-5050/udp

# Punto de entrada
CMD ["/opt/traccar/start.sh"]
