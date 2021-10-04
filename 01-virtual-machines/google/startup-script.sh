#! /bin/bash
apt update
apt -y install nginx
cat <<EOF > /var/www/html/index.nginx-debian.html
<!DOCTYPE html>
<html>
<head>
<title>ASR - MIT</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Bienvenidos a Google Cloud!</h1>
<p>Esta web se ha generado con el startup script de la VM.</>
<p>Si puedes ver esta web significa que nginx ha sido instalado correctamente.</p>

<p><em>A disfrutar de la nube con GCP!.</em></p>
</body>
</html>
EOF