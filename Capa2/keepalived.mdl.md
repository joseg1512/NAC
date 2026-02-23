# Como se construye keepalived.mdl (Capa 2)

## Propósito

Este documento describe los pasos iniciales para instalar y habilitar Keepalived, según las decisiones declaradas en keepalived.mdl.yml.

## 1. Instalación

Ejecute los siguientes comandos para instalar Keepalived y habilitar el servicio:

```bash
dnf install -y keepalived
systemctl enable --now keepalived
```

Verifique el estado del servicio:

```bash
systemctl status keepalived
```

## 2. Validación de configuración

Después de crear o modificar `/etc/keepalived/keepalived.conf`, valide la sintaxis:

```bash
keepalived -t