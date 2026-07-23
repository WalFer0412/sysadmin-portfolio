# Linux Hardening — Análisis y Recomendaciones

## Descripción
Script de auditoría de seguridad básica para servidores Linux.
Verifica configuraciones críticas y reporta alertas accionables.

---

## Hallazgos del análisis

### [ALERTA] SSH root login habilitado
**Riesgo:** Un atacante puede intentar acceso directo con el usuario root,
que existe en todos los sistemas Linux.

**Solución recomendada:**
```bash
# Editar configuración SSH
sudo nano /etc/ssh/sshd_config

# Modificar la siguiente línea:
PermitRootLogin no

# Reiniciar el servicio
sudo systemctl restart sshd
```
**Prerequisito:** Tener un usuario alternativo con sudo antes de aplicar.

---

### [ALERTA] Firewall no activo
**Riesgo:** Sin firewall, todas las conexiones entrantes están permitidas
por defecto, exponiendo servicios innecesarios.

**Solución recomendada:**
```bash
# Instalar y configurar UFW
sudo apt install ufw -y
sudo ufw allow ssh        # Permitir SSH antes de activar
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
sudo ufw status verbose
```
**Nota:** En este entorno, el firewall está deshabilitado por directiva del área de seguridad. Se documenta la práctica recomendada
como referencia.

---

### [OK] Sistema actualizado
Sin actualizaciones pendientes al momento del análisis.

### [OK] Fail2ban activo
Fail2ban está corriendo y protegiendo contra intentos de fuerza bruta.

### [OK] Sin usuarios no autorizados con UID 0
Solo el usuario root tiene privilegios de superusuario.

---

## Entorno analizado
- **OS:** Debian Linux
- **Hostname:** MyEquipo-PC
- **Fecha análisis:** 22/07/2026
- **Ejecutado por:** Walter Ferrari
