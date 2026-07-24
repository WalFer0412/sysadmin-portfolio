#!/bin/bash
# docker_monitor.sh
# Monitorea el estado de contenedores Docker y muestra información relevante
# Autor: Walter Ferrari

# Archivo de log
LOG_DIR="/var/log/sysadmin"
LOG_FILE="$LOG_DIR/docker_monitor.log"
mkdir -p "$LOG_DIR"

# Función para escribir en pantalla y log simultáneamente
log() {
    echo "$1" | tee -a "$LOG_FILE"
}

log "========================================"
log "   MONITOREO DE CONTENEDORES DOCKER"
log "   $(date)"
log "========================================"
log ""

# Verificar que Docker esté corriendo antes de continuar
if ! systemctl is-active --quiet docker; then
    log "[ERROR] El servicio Docker no está activo. Abortando."
    exit 1
fi

# Contadores
CORRIENDO=0
DETENIDO=0
TOTAL=0

log "--- Estado de contenedores ---"
log ""

# Recorrer todos los contenedores
while IFS= read -r linea; do
    NOMBRE=$(echo "$linea" | awk '{print $NF}')
    ESTADO=$(echo "$linea" | awk '{print $2}')
    IMAGEN=$(echo "$linea" | awk '{print $1}')
    PUERTOS=$(echo "$linea" | grep -o '0\.0\.0\.0:[0-9]*->[0-9]*/tcp' | head -1)

    ((TOTAL++))

    if echo "$ESTADO" | grep -q "^Up"; then
        log "[OK]    $NOMBRE  |  Imagen: $IMAGEN  |  Puerto: $PUERTOS"
        ((CORRIENDO++))
    else
        log "[ALERTA] $NOMBRE está detenido  |  Imagen: $IMAGEN"
        ((DETENIDO++))
    fi

done < <(docker ps -a --format "{{.Image}}\t{{.Status}}\t{{.Ports}}\t{{.Names}}")

log ""
log "----------------------------------------"
log "Total: $TOTAL  |  Corriendo: $CORRIENDO  |  Detenidos: $DETENIDO"
log "----------------------------------------"

# Uso de recursos de contenedores activos
log ""
log "--- Uso de recursos (contenedores activos) ---"
log ""
docker stats --no-stream --format "Contenedor: {{.Name}}  |  CPU: {{.CPUPerc}}  |  Memoria: {{.MemUsage}}" | tee -a "$LOG_FILE"

log ""
log "========================================"

if [ "$DETENIDO" -gt 0 ]; then
    log "ATENCIÓN: Hay $DETENIDO contenedor/es detenido/s"
    exit 1
else
    log "Todos los contenedores funcionando correctamente"
    exit 0
fi
