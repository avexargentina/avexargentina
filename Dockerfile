# Usa una imagen base con las herramientas necesarias
FROM debian:bullseye-slim

# Instalar las dependencias necesarias
RUN apt-get update && apt-get install -y \
    default-jre \
    wget \
    gnupg \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Crear usuario y grupo traccar
RUN groupadd -r traccar && useradd -r -g traccar traccar

# Descargar e instalar Traccar
RUN wget -q https://www.traccar.org/download/traccar-linux-64-latest.deb \
    && mkdir -p /opt/traccar \
    && dpkg-deb -x traccar-linux-64-latest.deb /opt/traccar \
    && rm traccar-linux-64-latest.deb \
    && chown -R traccar:traccar /opt/traccar

# Copia tu archivo traccar.xml personalizado al directorio de configuración
COPY traccar.xml /opt/traccar/conf/traccar.xml

# Script de inicio personalizado
COPY start.sh /opt/traccar/bin/start.sh
RUN chmod +x /opt/traccar/bin/start.sh

# Configurar permisos
RUN chown -R traccar:traccar /opt/traccar

# Cambiar al usuario traccar
USER traccar

# Usar el script de inicio personalizado
ENTRYPOINT ["/opt/traccar/bin/start.sh"]
