### Introducción

El objetivo de este lab es la demostración de como
podemos desplegar de manera sencilla una app en
Google Cloud Run, orquestando todo el despliegue con 
Google Cloud Build. Para este propósito hemos
creado una API sencilla en Python con [FastAPI](https://fastapi.tiangolo.com/).


### Despliegue con cloudbuild.yaml

En este ejemplo no nos vamos a centrar en la explicación 
del código de la API en sí mismo, sino en la orquestación
de su despliegue mediante Google Cloud Build.
Para ello vamos a usar el manifiesto [cloudbuild.yaml](prototype/cloudbuild-prod.yaml).

```yaml
steps:

  - name: 'gcr.io/cloud-builders/docker'
    args: ['build',
           '--tag', 'gcr.io/${_PROJECT_ID}/${_PKG}/${_STAGE}/app',
           '--build-arg', 'STAGE=${_STAGE}',
           '--file', 'Dockerfile', '.']
    id: 'build: core'


  - name: 'gcr.io/cloud-builders/docker'
    args: ['push', 'gcr.io/${_PROJECT_ID}/${_PKG}/${_STAGE}/app']
    id: 'push: app'

  - name: 'gcr.io/cloud-builders/gcloud'
    args: [
        'run',
        'deploy',
        '--image=gcr.io/${_PROJECT_ID}/${_PKG}/${_STAGE}/app',
        '--region', '${_REGION}',
        '--platform', 'managed',
        '--allow-unauthenticated',
        '--min-instances', '0',
        '--max-instances', '5',
        '${_PKG}-api'
    ]
    id: 'deploy: app'
    waitFor: ['push: app']

timeout: 3600s

substitutions:
  _PROJECT_ID: YOUR_PROJECT_ID
  _REGION: 'europe-west1'
  _PKG: prototype
```

Con este sencillo manifiesto vamos a hacer que la applicación
que se encuentra en la carpeta [prototype](prototype) sea
desplegada en la nube de Google. Sin embargo, para ello necesitamos
crear un repositorio en [Google Source Repositories](https://cloud.google.com/source-repositories).

Sigue los siguientes pasos:

1. Crea un repositorio en GSR llamado `prototype`
2. Ve a tu escritorio y copia el código de la carpeta [prototype](prototype) en esa carpeta
3. Ejecuta el script [create_triggers.sh](prototype/create_triggers.sh):
   ```shell
   $ ./create_triggers.sh prod
   ```
4. Haz push de los cambios de la carpeta

Estos 4 pasos habrán ejecutado el manifiesto anterior en 
tu proyecto de GCP, y podrás ver su evolución [aquí](https://console.cloud.google.com/cloud-build/builds).
Si todo ha ido adecuadamente, tendrás tu API `prototype-api` en 
tu consola de cloud run: [aquí](https://console.cloud.google.com/run).