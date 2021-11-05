### Introducción

El objetivo de este lab es la demostración de cómo
podemos desplegar de manera sencilla una Web App
en Google App Engine. Para este propósito hemos
vamos a utilizar una imagen de Docker que ya hemos 
usado anteriormente, Super Mario 🍄!


### Despliegue con GCloud SDK

Dado que tenemos la imagen de Docker que queremos
desplegar en nuestro registro de imágenes de google 
[gcr.io](gcr.io) asociado a nuestro proyecto, en este
lab solo vamos a presentar la línea de comandos que tendríamos
que usar para desplegar un "cluster" gestionado por
Google con susodicha imagen ([documentación oficial](https://cloud.google.com/sdk/gcloud/reference/app/deploy)):

```shell
gcloud app deploy --image-url=gcr.io/[PROJECT_ID]/supermario
```
⚠️ Nota: [PROJECT_ID] lo tendrás que reemplazar por el identificador de tu proyecto

Este comando se tiene que ejecutar en la carpeta donde tengamos
el manifiesto de configuración [app.yaml](app.yaml),
que en este caso contiene la información referente a toda
la configuración del cluster:

```yaml
service: supermario-auto

env: flex


automatic_scaling:
  min_num_instances: 1
  max_num_instances: 5
  max_concurrent_requests: 10
  cool_down_period_sec: 300
  cpu_utilization:
    target_utilization: 0.10

resources:
  cpu: 2
  memory_gb: 2
  disk_size_gb: 10


network:
  forwarded_ports:
    - 8080:8080
```

Tras la ejecución del anterior comando de despliegue,
deberás haber recibido una URL, que es la URL asociada a 
nuestra App. Solo tienes que hacer click en la URL para
acceder y verás la pantalla de inicio de Super Mario!

### Liberación de los recursos

Para borrar el servicio, solo tenemos que ejecutar:

```shell
gcloud container clusters delete $cluster_name --quiet
```

El proceso de borrado del clúster puede llevar unos minutos.
Este borrado también se podría haber hecho mediante [clean.sh](clean.sh):

```shell
chmod a+x clean.sh && ./clean.sh
```


