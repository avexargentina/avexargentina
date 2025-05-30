# Usa la imagen oficial de Traccar como base
FROM traccar/traccar:latest

# Elimina la configuración por defecto y copia tu archivo traccar.xml personalizado
# La configuración de Traccar se encuentra en /opt/traccar/conf/
COPY --chown=traccar:traccar traccar.xml /opt/traccar/conf/traccar.xml

# Traccar se ejecuta por defecto en el puerto 8082, que ya está expuesto por la imagen base.
# Si cambiaste 'web.port' en traccar.xml, asegúrate de exponer el puerto correcto.
# EXPOSE <tu_puerto_web>

# El entrypoint y CMD ya están definidos en la imagen base para iniciar Traccar.
