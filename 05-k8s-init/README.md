### Introducción
El objetivo del siguiente ejemplo es el de introducir Google Kubernetes Engine (GKE),
un servicio de Kubernetes gestionado y seguro para el despliegue, gestión y
(auto)escalado de aplicaciones contenerizadas usando la infraesturctura de 
GCP. Para ello, en este ejemplo vamos a crear un cluster GKE, que consiste
en un conjunto de VMs (instancias de Google Compute Engine), y desplegaremos
en éste una aplicación sencilla `hello-world`.


### 1. Creación del cluster GKE
Lo primero que vamos a hacer es asegurarnos de tener configurada una 
zona de procesamiento predeterminada. Para establecer nuestra zona de procesamiento
predeterminada en `europe-west1-b` ejecutaremos el siguiente comando:

```shell
gcloud config set compute/zone europe-west1-b
```

Una vez configurada la zona por defecto, vamos a proceder a crear un cluster GKE.
Éste constará de, al menos, una instancia principal y varias VMs que ejecutarán los procesos de
Kubernetes, llamadas en este contexto nodos. 
Así, los nodos son VMs de Compute Engine que ejecutan los procesos de Kubernetes necesarios.

A continuación vamos a crear nuestro cluster, el cual tendrá el nombre que queramos especificar
en la variable `$CLUSTER_NAME`

```shell
gcloud container clusters create $CLUSTER_NAME
```
La creación del clúster podrá llevar varios minutos.


Una vez la creación ha finalizado satisfactoriamente, vamos a proceder a interaccionar con el cluster.
Para ello necesitamos los credenciales correspondientes, los cuales los podemos obtener
fácilmente mediante la ejecución del siguiente comando:

```shell
gcloud container clusters get-credentials $CLUSTER_NAME
```

Una vez nos hemos autenticado, podemos comenzar a gestionar el cluster GKE. 
Una de las labores más comunes en la gestión de un cluster es el despliegue de una aplicación
en el mismo. En este ejemplo vamos a proceder a desplegar una aplicación tipo `hello-world`,
con el ánimo de simplemente mostrar los inicios (que pueden llegar a ser bastante duros)
con GKE.

### 2. Despliegue y exposición de la aplicación

⚠️ Para la gestión del cluster necesitaremos tener instalado `kubectl` (the Kubernetes command-line tool).
You can find the installer [here](https://kubernetes.io/docs/tasks/tools/).

GKE utiliza los objetos de Kubernetes (una abstracción para representar el estado de 
de un cluster) para crear y administrar los recursos de sus clústeres. 
Algunos de los objetos que oferta k8s son:

* `Deployment`: para implementar aplicaciones sin estado como servidores web
  
* `Service`: definen las reglas y el balanceo de cargas para acceder a su aplicación desde Internet

Para crear un nuevo objeto `Deployment`, que llamaremos `hello-server`, a partir de la 
imagen del contenedor `hello-app` (que se encuentra en `gcr.io/google-samples/hello-app`),
vamos a usar el siguiente comando kubectl:

```shell
kubectl create deployment hello-server --image=gcr.io/google-samples/hello-app:1.0
```

Una vez hemos creado el objeto `deployment` que nos ha permitido desplegar la imagen, 
necesitaremos crear un objeto `service`, un recurso de Kubernetes que permite exponer 
la aplicación al tráfico externo. 
En nuestro caso, queremos exponer la aplicación al tráfico externo vía puerto `8080`.
Para ello:

```shell
kubectl expose deployment hello-server --type=LoadBalancer --port 8080
```

En este comando, la opción `type="LoadBalancer"` crea un balanceador de cargas de Compute
Engine para el contenedor.

Una vez que se ha creado, podemos inspeccionar el objeto `Service` hello-server mediante:

```shell
kubectl get service
```

⚠️ La generación de la IP pública puede tardar aproximadamente un minuto.

Finalmente, ahora podemos proceder a ver la aplicación en nuestro navegador web
usando la `[EXTERNAL-IP]` de `hello-server` en `http://[EXTERNAL-IP]:8080`

La creación del cluster, despliegue y exposición de la app se pueden hacer
simplemente ejecutando [deployment.sh](deployment.sh):

```shell
chmod a+x deployment.sh && ./deployment.sh
```

### 3. Borrar el cluster

Para borrar el clúster, solo tenemos que ejecutar:

```shell
gcloud container clusters delete $CLUSTER_NAME --quiet
```

El proceso de borrado del clúster puede llevar unos minutos.
Este borrado también se podría haber hecho mediante [clean.sh](clean.sh):

```shell
chmod a+x clean.sh && ./clean.sh
```
