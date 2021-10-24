### Introducción

Google Kubernetes Engine (GKE) ofrece herramientas de autoescalado 
horizontal y vertical tanto para PODs como para la infraestructura
en general. Estas soluciones de autoescalado son de suma importancia
cuando queremos hacer un uso de GKE eficiente y optimizado en cuanto a 
costes se refiere. En este ejemplo pretendemos precisamente que seas
capaz de poner en marcha, y observar, un autoescalado horizontal (HPA,
del inglés *Horizontal Pod Autoscaling*)
y vertical de pods (VPA, del inglés *Vertical Pod Autoscaling*), 
además de un escalado a nivel del cluster (*Cluster Autoscaler*,
escalado horizontal de la infraestructura) y de *nodo*
(*Node Auto Provisioning*, escalado vertical de la infraestructura).
Vamos a utilizar estas *herramientas* con el objetivo de ahorrar 
costes de infraestructura, mediante la reducción del tamaño del 
cluster (o de los nodos) en momentos de baja demanda. Aunque
también serán utilizadas para aumentar la infraestructura en intervalos
de muy alta demanda, lo cual forzaremos en nuestro ejemplo para ver
como estas herramientas hacen posible tener una infraestructura
completamente flexible y dinámica.

Para ello, vamos a proceder siguiendo los pasos que se enumeran:

* Crearemos un cluster de K8s que estará sirviendo un webserver de apache

* Aplicaremos una política de autoescalado horizontal y vertical para:

    - Reducir el numero de réplicas de un *Deployment* con HPA
    
    - Reducir la CPU asignada a un *Deployment* con VPA

* Aplicaremos una política de autoescalado horizontal a nivel de cluster con *Cluster Autoscaler*

* Usaremos NAP para que se cree un pool de nodos optimizado a la carga de nuestro cluster

* Test del comportamiento de las diferentes configuraciones de autoescalado 
  ante un aumento repentino de demanda

Todos estos pasos se desglosan a continuación (y se pueden encontrar en
el script de despliegue: [deployment.sh](deployment.sh))

### 1. Creación del cluster GKE
Lo primero que vamos a hacer es asegurarnos de tener configurada una
zona de procesamiento predeterminada. Para establecer nuestra zona de procesamiento
predeterminada en `us-central1-a` ejecutaremos el siguiente comando:

```shell
$ gcloud config set compute/zone $zone
```

⚠️ Como hemos hecho en otras ocasiones, las variables de configuración las hemos
guardado en un manifiesto de configuración, [config.ini](config.ini). Para poder
tenerlas disponibles en nuestro script, usamos:
```shell
> source "${PWD}/config.ini"
```
al inicio del mismo.


Una vez configurada la zona por defecto, vamos a proceder a crear un cluster GKE.
Éste constará de, al menos, una instancia principal y varias VMs que ejecutarán los procesos de
Kubernetes, llamadas en este contexto nodos. Así, los nodos son VMs de Compute Engine que ejecutan los procesos de Kubernetes necesarios.

A continuación vamos a crear nuestro cluster, el cual tendrá el nombre que queramos especificar
en la variable `$cluster_name`:

```shell
$ gcloud container clusters create "$cluster_name" \
  --num-nodes=3 \
  --enable-vertical-pod-autoscaling \
  --release-channel=rapid
```
La creación del clúster podrá llevar varios minutos.

Para demostrar el autoescalado horizontal de pods vamos a desplegar
una imagen de docker basada en `php-apache`. Ésta servirá un 
`index.php` que lleva a cabo tareas computacionalmente costosas.
Para esto, vamos a hacer uso de un manifiesto de despliegue, 
[php-apache.yaml](php-apache.yaml), que contiene la siguiente 
configuración:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: php-apache
spec:
  selector:
    matchLabels:
      run: php-apache
  replicas: 3
  template:
    metadata:
      labels:
        run: php-apache
    spec:
      containers:
      - name: php-apache
        image: k8s.gcr.io/hpa-example
        ports:
        - containerPort: 80
        resources:
          limits:
            cpu: 500m
          requests:
            cpu: 200m
---
apiVersion: v1
kind: Service
metadata:
  name: php-apache
  labels:
    run: php-apache
spec:
  ports:
  - port: 80
  selector:
    run: php-apache
```
Una vez haya terminado la creación del cluster, aplicaremos
este manifiesto mediante:

```shell
$ kubectl apply -f "$php_manifest"
```

### 2. Escalado de pods con HPA

HPA (autoescalado horizontal de pods en inglés) se encarga de 
modificar la estructura de nuestro cluster mediante el incremento
o decremento automático del número de pods en respuesta a la 
carga CPU de trabajo que haya, o al consumo de memoria, o en 
respuesta a ciertas métricas personalizadas que son monitorizadas
por K8s y que podemos usar como indicadores de un cambio de regimen.

Para comenzar esta tarea comenzamos inspeccionando los 
despliegues que se encuentran en funcionamiento en nuestro cluster:

```shell
$ kubectl get deployment
```

Esto nos debería mostrar en terminal que tenemos un despliegue 
llamado `php-apache` y que hay `3/3` pods funcionando de manera
correcta.

⚠️ Si por lo que fuera no vemos los 3 pods que esperamos en funcionamiento,
espera un par de minutos, y vuelve a intentarlo una vez pasado este tiempo.
Si ves `1/1`, puede ser que hayas dejado suficiente tiempo pasar como
para que el despliegue haya escalado a la baja.


Una vez hemos comprobado que el despliegue está correctamente
funcionando, vamos a aplicar el HPA:

```shell
$ kubectl autoscale deployment $php_deployment \
  --cpu-percent="$cpu_threshold" \
  --min="$min_replicas" \
  --max="$max_replicas"
```
(recuerda, las variables están definidas en el archivo [config.ini](config.ini)).

Este comando configura un HPA que mantendrá gestionadas entre `$min_replicas`
y `max_replicas` replicas de los pods controlados por el despliegue `php_deployment`.
La opción `--cpu-percent` establece el objetivo de uso de CPU promedio 
en todos los pods. Es decir, el HPA adaptará el número de réplicas
(mediante despliegue) para mantener un uso promedio de CPU de un `$cpu_threshold` 
(en procentaje, e.g. `--cpu-percent=50` significa `50%`).

Una vez el HPA está configurado, podemos comprobar el estado del mismo
mediante:

```shell
$ kubectl get hpa
```

Deberíamos ver `0%/50%` bajo la columna `Targets`. Esto significa
que ahora mismo el promedio de CPU usada por pod es de un 0$%, 
lo cual es de esperar dado que la app `php-apache` no está recibiendo
ningún tráfico a estas alturas. A su vez, a medida que el HPA
entra en acción veremos que la columna `Replicas` cambia de valores.
Inicialmente estará a 3, pero a medida que pasa el tiempo (entre
5 y 10 minutos), el HPA reducirá el número de réplicas dado que el
uso de CPU está por debajo del umbral establecido.


### 3. Escalado vertical de pods con VPA


