# Usa la imagen oficial de Traccar como base
FROM traccar/traccar:latest

# Copia tu archivo traccar.xml personalizado al directorio de configuración.
# Inicialmente será propiedad de root.
COPY traccar.xml /opt/traccar/conf/traccar.xml

# Cambia el propietario del archivo de configuración al usuario 'traccar',
# que está definido en la imagen base.
RUN chown traccar:traccar /opt/traccar/conf/traccar.xml

# Traccar se ejecuta por defecto en el puerto 8082, que ya está expuesto por la imagen base.
# Si cambiaste 'web.port' en traccar.xml, asegúrate de exponer el puerto correcto.
# EXPOSE <tu_puerto_web>

# El entrypoint y CMD ya están definidos en la imagen base para iniciar Traccar.
