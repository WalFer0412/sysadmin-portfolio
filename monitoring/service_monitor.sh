#!/bin/bash
# service_monitor.sh
# Monitorea el estado de servicios críticos del servidor
# Guarda resultado en archivo de log
# Autor: Walter Ferrari

# Lista de servicios críticos a monitorear
SERVICIOS=(
    "ssh"
    "docker"
    "nginx"
    "fail2ban"
    "zabbix-agent"
    "cron"
)

# Archivo de log
LOG_DIR="/var/log/sysadmin"
LOG_FILE="$LOG_DIR/service_monitor.log"

# Crear directorio de log si no existe
mkdir -p "$LOG_DIR"

# Contadores
OK=0
ALERTA=0

# Función para escribir en pantalla y en log al mismo tiempo
log() {
    echo "$1" | tee -a "$LOG_FILE"
}

log "========================================"
log "   MONITOREO DE SERVICIOS CRÍTICOS"
log "   $(date)"
log "========================================"
log ""

for SERVICIO in "${SERVICIOS[@]}"; do
    if systemctl is-active --quiet "$SERVICIO"; then
        log "[OK]    $SERVICIO está corriendo"
        ((OK++))
    else
        log "[ALERTA] $SERVICIO NO está corriendo"
        ((ALERTA++))
    fi
done

log ""
log "----------------------------------------"
log "Resumen: $OK servicios OK  |  $ALERTA alertas"
log "----------------------------------------"

if [ "$ALERTA" -gt 0 ]; then
    log ""
    log "ATENCIÓN: Hay servicios caídos que requieren revisión"
    exit 1
else
    log ""
    log "Todos los servicios críticos funcionando correctamente"
    exit 0
fi
