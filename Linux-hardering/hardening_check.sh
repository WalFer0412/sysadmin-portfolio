#!/bin/bash
# hardening_check.sh
# Verifica configuraciones básicas de seguridad en Linux
# Autor: Walter Ferrari

echo "==============================="
echo "   HARDENING CHECK - LINUX"
echo "==============================="
echo ""

# 1. Verificar si root puede hacer SSH
ROOT_SSH=$(grep "^PermitRootLogin" /etc/ssh/sshd_config 2>/dev/null | awk '{print $2}')
if [ "$ROOT_SSH" == "no" ]; then
    echo "[OK]  SSH root login deshabilitado"
else
    echo "[ALERTA] SSH root login habilitado o no configurado"
fi

# 2. Verificar firewall activo
if systemctl is-active --quiet ufw; then
    echo "[OK]  Firewall UFW activo"
elif systemctl is-active --quiet firewalld; then
    echo "[OK]  Firewall firewalld activo"
else
    echo "[ALERTA] No se detectó firewall activo"
fi

# 3. Verificar actualizaciones pendientes (Debian/Ubuntu)
if command -v apt &>/dev/null; then
    UPDATES=$(apt list --upgradable 2>/dev/null | grep -c upgradable)
    if [ "$UPDATES" -gt 0 ]; then
        echo "[ALERTA] Hay $UPDATES actualizaciones pendientes"
    else
        echo "[OK]  Sistema actualizado"
    fi
fi

# 4. Verificar usuarios con UID 0 (privilegios root)
ROOT_USERS=$(awk -F: '$3==0 {print $1}' /etc/passwd)
echo ""
echo "--- Usuarios con privilegios root ---"
echo "$ROOT_USERS"

# 5. Verificar si fail2ban está activo
if systemctl is-active --quiet fail2ban; then
    echo ""
    echo "[OK]  Fail2ban activo"
else
    echo ""
    echo "[ALERTA] Fail2ban no está activo"
fi

echo ""
echo "==============================="
echo "Revisión completada: $(date)"
echo "==============================="
