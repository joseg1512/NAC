# Cómo se construye mariadb.img (Capa 2)

## Propósito

Este documento describe los pasos para construir la imagen base de MariaDB que hereda de rocky10x.img, implementando las decisiones declaradas en mariadb.img.yml.

## 1. Instalación

Ejecute los siguientes comandos para configurar el repositorio, instalar los paquetes y asegurar la instalación:

```bash
curl -LsSO https://dlm.mariadb.com/enterprise-release helpers/mariadb_repo_setup
chmod +x mariadb_repo_setup
./mariadb_repo_setup
dnf install mariadb mariadb-server
dnf install mariadb mariadb-client
mariadb-secure-installation
```

## 2. SElinux

Ejecute los siguientes comandos para verificar SElinux, instalar paquetes requeridos y cargar el módulo de política:

```bash
getenforce
dnf install -y policycoreutils policycoreutils-python-utils
/usr/sbin/semodule -i /usr/share/mariadb/policy/selinux/mariadb.pp
```

Salida esperada de `getenforce`: `Enforcing`

La configuración de contextos de archivos no requiere cambios a menos de que se usen directorios custom.

Configure el contexto de puerto para MariaDB en SELinux:

```bash
semanage port -a -t mysqld_port_t -p tcp 3306
```

Verifique el contexto configurado:

```bash
semanage port -l | grep mysqld_port_t
```

Salida esperada debe incluir el puerto 3306.
## 3. Generar certificado con OpenSSL

Genere la clave privada y el certificado del CA (Certificate Authority):

```bash
openssl genrsa 2048 > ca-key.pem
openssl req -new -x509 -nodes -days 365000 \
	-key ca-key.pem -out ca.pem
```

Genere la clave privada y el certificado del servidor, firmado por el CA:

```bash
openssl req -newkey rsa:2048 -days 365000 \
	-nodes -keyout server-key.pem -out server-req.pem
openssl rsa -in server-key.pem -out server-key.pem
openssl x509 -req -in server-req.pem -days 365000 \
	-CA ca.pem -CAkey ca-key.pem -set_serial 01 \
	-out server-cert.pem
```

Verifique que el certificado sea válido:

```bash
openssl verify -CAfile ca.pem server-cert.pem
```

Salida esperada: `server-cert.pem: OK`

## 4. Configuración de TLS en MariaDB Server

Ejecute los siguientes comandos para crear el directorio de certificados, mover los archivos, crear la configuración TLS y reiniciar el servicio:

```bash
mkdir -p /etc/my.cnf.d/certificates
mv ca.pem /etc/my.cnf.d/certificates/
mv server-cert.pem /etc/my.cnf.d/certificates/
mv server-key.pem /etc/my.cnf.d/certificates/
mv client-cert.pem /etc/my.cnf.d/certificates/
mv client-key.pem /etc/my.cnf.d/certificates/
vi /etc/my.cnf.d/z-custom-my.cnf
systemctl restart mariadb
```

Para verificar TLS, conéctese al servidor y ejecute la consulta:

```bash
mariadb
```

```sql
SHOW GLOBAL VARIABLES LIKE 'have_ssl';
```

Salida esperada:

```text
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| have_ssl      | YES   |
+---------------+-------+
```

## 5. Firewall

Ejecute los siguientes comandos para abrir el puerto de MariaDB en el firewall:

```bash
firewall-cmd --permanent --add-port=3306/tcp
firewall-cmd --reload
```

Verifique las reglas configuradas:

```bash
firewall-cmd --list-ports
```

Salida esperada: `3306/tcp`
