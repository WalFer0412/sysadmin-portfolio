#!/bin/bash
# backup.sh
# Realiza backup de directorios críticos hacia servidor remoto usando rsync
# Autor: Walter Ferrari

# ============================================================
# CONFIGURACIÓN
# ============================================================
SERVIDOR_DESTINO="10.1.100.208"
USUARIO_DESTINO="root"
DIRECTORIO_DESTINO="/backup/$(hostname)"
FECHA=$(date +%Y-%m-%d)

# Directorios a respaldar
DIRECTORIOS=(
    "/etc"
    "/home/wferrari/sysadmin-portfolio"
    "/var/log/sysadmin"
)

# Log
LOG_DIR="/var/log/sysadmin"
LOG_FILE="$LOG_DIR/backup.log"
mkdir -p "$LOG_DIR"

log() {
    echo "$1" | tee -a "$LOG_FILE"
}

# ============================================================
# INICIO
# ============================================================
log "========================================"
log "   BACKUP REMOTO CON RSYNC"
log "   Fecha: $FECHA"
log "   Hora:  $(date +%H:%M:%S)"
log "   Destino: $USUARIO_DESTINO@$SERVIDOR_DESTINO:$DIRECTORIO_DESTINO"
log "========================================"
log ""

# ============================================================
# VERIFICACIONES PREVIAS
# ============================================================
log "--- Verificaciones previas ---"

# Verificar conectividad con servidor destino
if ! ping -c 1 -W 2 "$SERVIDOR_DESTINO" &>/dev/null; then
    log "[ERROR] No se puede alcanzar el servidor destino ($SERVIDOR_DESTINO)"
    log "[ERROR] Backup abortado"
    exit 1
fi
log "[OK]    Servidor destino accesible ($SERVIDOR_DESTINO)"

# Verificar que rsync está instalado
if ! command -v rsync &>/dev/null; then
    log "[ERROR] rsync no está instalado"
    log "[INFO]  Instalar con: apt install rsync -y"
    exit 1
fi
log "[OK]    rsync disponible"

# Crear directorio destino en servidor remoto
ssh "$USUARIO_DESTINO@$SERVIDOR_DESTINO" "mkdir -p $DIRECTORIO_DESTINO" 2>/dev/null
log "[OK]    Directorio destino verificado: $DIRECTORIO_DESTINO"

log ""

# ============================================================
# EJECUCIÓN DEL BACKUP
# ============================================================
log "--- Iniciando backup ---"
log ""

ERRORES=0

for DIR in "${DIRECTORIOS[@]}"; do
    if [ -d "$DIR" ]; then
        log "[INFO]  Respaldando: $DIR"

        rsync -avz --delete \
            -e "ssh -o StrictHostKeyChecking=no" \
            "$DIR" \
            "$USUARIO_DESTINO@$SERVIDOR_DESTINO:$DIRECTORIO_DESTINO/" \
            >> "$LOG_FILE" 2>&1

        if [ $? -eq 0 ]; then
            log "[OK]    $DIR respaldado correctamente"
        else
            log "[ALERTA] Error al respaldar $DIR"
            ((ERRORES++))
        fi
    else
        log "[ALERTA] Directorio no encontrado, omitiendo: $DIR"
        ((ERRORES++))
    fi
    log ""
done

# ============================================================
# RESUMEN
# ============================================================
log "========================================"
log "   RESUMEN DEL BACKUP"
log "   Directorios procesados: ${#DIRECTORIOS[@]}"
log "   Errores: $ERRORES"
log "   Finalizado: $(date +%H:%M:%S)"
log "========================================"

if [ "$ERRORES" -gt 0 ]; then
    log ""
    log "ATENCIÓN: El backup finalizó con $ERRORES error/es"
    exit 1
else
    log ""
    log "Backup completado exitosamente"
    exit 0
fi
