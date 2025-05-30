# Usa la imagen oficial de Traccar como base
FROM traccar/traccar:latest

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
