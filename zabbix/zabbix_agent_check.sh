#!/bin/bash
# zabbix_agent_check.sh
# Verifica el estado y configuración del agente Zabbix
# Detecta si está correctamente apuntado a un servidor real
# Autor: Walter Ferrari

LOG_DIR="/var/log/sysadmin"
LOG_FILE="$LOG_DIR/zabbix_check.log"
mkdir -p "$LOG_DIR"

log() {
    echo "$1" | tee -a "$LOG_FILE"
}

log "========================================"
log "   VERIFICACIÓN ZABBIX AGENT"
log "   $(date)"
log "========================================"
log ""

# 1. Verificar si el servicio está activo
log "--- Estado del servicio ---"
if systemctl is-active --quiet zabbix-agent; then
    log "[OK]    zabbix-agent está corriendo"
    VERSION=$(zabbix_agentd --version 2>/dev/null | head -1)
    log "[INFO]  Versión: $VERSION"
else
    log "[ALERTA] zabbix-agent no está corriendo"
fi

log ""

# 2. Verificar configuración
log "--- Configuración del agente ---"
CONF="/etc/zabbix/zabbix_agentd.conf"

if [ -f "$CONF" ]; then
    log "[OK]    Archivo de configuración encontrado: $CONF"

    # Leer valores clave
    SERVER=$(grep "^Server=" "$CONF" | cut -d= -f2)
    SERVER_ACTIVE=$(grep "^ServerActive=" "$CONF" | cut -d= -f2)
    HOSTNAME=$(grep "^Hostname=" "$CONF" | cut -d= -f2)

    log ""
    log "[INFO]  Server:       ${SERVER:-no configurado}"
    log "[INFO]  ServerActive: ${SERVER_ACTIVE:-no configurado}"
    log "[INFO]  Hostname:     ${HOSTNAME:-usa nombre del sistema ($(hostname))}"

    log ""

    # 3. Detectar si apunta a localhost (no configurado correctamente)
    log "--- Diagnóstico de conectividad ---"
    if echo "$SERVER" | grep -qE "^127\.0\.0\.1$|^localhost$"; then
        log "[ALERTA] Server apunta a localhost (127.0.0.1)"
        log "[INFO]   El agente está corriendo pero NO reporta a un servidor Zabbix real"
        log "[INFO]   Para conectar a un servidor real, modificar en $CONF:"
        log "         Server=IP_DEL_SERVIDOR_ZABBIX"
        log "         ServerActive=IP_DEL_SERVIDOR_ZABBIX"
    else
        log "[OK]    Server configurado: $SERVER"

        # Intentar conectividad al servidor
        if ping -c 1 -W 2 "$SERVER" &>/dev/null; then
            log "[OK]    Servidor Zabbix accesible ($SERVER)"
        else
            log "[ALERTA] No se puede alcanzar el servidor Zabbix ($SERVER)"
        fi
    fi
else
    log "[ALERTA] No se encontró el archivo de configuración: $CONF"
fi

log ""

# 4. Verificar log del agente
log "--- Últimas líneas del log del agente ---"
AGENT_LOG="/var/log/zabbix-agent/zabbix_agentd.log"
if [ -f "$AGENT_LOG" ]; then
    tail -5 "$AGENT_LOG" | while IFS= read -r linea; do
        log "        $linea"
    done
else
    log "[INFO]  No se encontró log del agente en $AGENT_LOG"
fi

log ""
log "========================================"
log "Verificación completada"
log "========================================"
