### Introducción

En esta práctica vamos a preparar una 
Cloud Function que será responsable de "ingerir"
ficheros de transacciones que se volcarán en un 
Bucket de Google Cloud Storage (como zona de 
comunicación entre nuestro proyecto y el mundo
exterior). Para ello necesitamos:

- Un bucket de comunicación
- Un ejemplo fichero que se volcará en el Bucket de comunicación
- Un dataset y una tabla en BigQuery donde volcar la información del archivo 

La preparación de estos ingredientes ocurre en el 
fichero [deployment.sh](deployment.sh).
El último paso de este script de despliegue es 
precisamente el despliegue de la Cloud Function
en nuestro proyecto.
