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

HPA (o autoescalado horizontal de pods) se encarga de 
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

VPA (o autoescalado vertical de pods) nos libera de la responsabilidad
de tener que conocer perfectamente los valores de CPU que 
tenemos que seleccionar para cada contenedor. De hecho, el auto-escalador
VPA nos recomienda valores de CPU y RAM, y límites, acorde
al histórico de uso. Además, evidentemente, puede hacer que
susodichos valores sean los que se utilicen en los nodos del
despliegue.

🚨 *Atención*: No deberíamos usar nunca un VPA y un HPA simultáneamente
sobre la misma métrica (CPU o memoria). La razón es sencilla, si
así fuera, ambos auto-escaladores intentarían responder al cambio
de demanda en la misma métrica y llevaría a un conflicto de 
responsabilidades. No obstante, sí que se pueden usar (y se
recomienda de hecho) en distintas, por ejemplo VPA en CPU o memoria
y el HPA en métricas personalizadas para evitar el solapamiento.


Si recuerdas, cuando hemos creado el cluster, hemos seleccionado
la opción de autoescalado vertical. Es por ello que VPA ya está
activo en nuestro cluster. Para comprobarlo, solo tenemos que
ejecutar el siguiente comando:

```shell
$ gcloud container clusters describe scaling-demo | grep ^verticalPodAutoscaling -A 1
```

Este comando nos debería devolver en terminal: `enabled: true`,
confirmando que está activo. Si por lo que fuera se nos olvidó 
activarlo con la creación del cluster, podemos hacerlo ahora de 
forma manual:

```shell
$ gcloud container clusters update $cluster_name \
    --enable-vertical-pod-autoscaling
```

Para comprobar las virtudes de VPA, vamos a desplegar un nuevo
servicio, `hello-server`:

```shell
$ kubectl create deployment hello-server \
    --image=gcr.io/google-samples/hello-app:1.0
```

Esto llevará unos minutos. Cuando acabe el despliegue, 
podremos asegurarnos de que todo ha ido bien mediante el
siguiente comando:

```shell
$ kubectl get deployment hello-server
```

A continuación, vamos a definir la mínima cantidad de CPU
necesaria por el despliegue `hello-server`. En el lenguaje
de K8s esto se conoce como *resource requests* (RR). Por ejemplo,
vamos a comenzar seleccionando un RR de 450 mili-CPU, i.e. 0.45 CPUs.
Esto se lleva a cabo mediante:

```shell
$ kubectl set resources deployment hello-server \
  --requests=cpu=450m
```

Ahora podemos inspeccionar el pod que sirve `hello-server`
y ver que la configuración de `Requests` es precisamente
la que acabamos de configurar:

```shell
$ kubectl describe pod hello-server | sed -n "/Containers:$/,/Conditions:/p"
```

En lo que sigue, vamos a usar el manifiesto de configuración del
VPA, [hello-vpa.yaml](hello-vpa.yaml):

```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: hello-server-vpa
spec:
  targetRef:
    apiVersion: "apps/v1"
    kind:       Deployment
    name:       hello-server
  updatePolicy:
    updateMode: "Off"
```

Este manifiesto generará un auto-esclador VPA para el 
despliegue `hello-server` con una política de actualización 
`Off`. Un VPA solo puede tener una de las siguientes tres
políticas de actualización:

- *Off*: Con esta configuración VPA solo generará recomendaciones
  basadas en datos históricos. Dichas recomendaciones no serán
  aplicadas, las tendremos que aplicar nosotros manualmente
- *Initial*: VPA generará recomendaciones y creará nuevos pods
  basadas en las mismas una sola vez, no cambiará el tamaño de los
  pods a posteriori
- *Auto*: VPA borrará y creará regularmente pods para que se cumplan
  las recomendaciones actualizadas regularmente
  
Conocido esto, apliquemos el manifiesto mencionado:

```shell
$ kubectl apply -f hello-vpa.yaml
```

Tras esperar un minuto, aproximadamente, podemos hacer una comprobación
del VPA mediante:

```shell
$ kubectl describe vpa hello-server-vpa
```

Dado que nuestro manifiesto especificaba una política de 
actualización modo `Off`, lo que podremos ver serán las recomendaciones
generadas por la VPA. Para ello, podemos fijarnos en la sección
`Container Recommendations` que debería aparecernos al final de
la respuesta del anterior comando. Ahí veremos diferentes
tipos de recomendación, cada uno de ellos con valores de CPU
y memoria. Si todo ha ido bien, veremos que el VPA nos está 
recomendando que bajemos la CPU RR a `25m`, en lugar del valor
previo, además de darnos un valor de cuanta memoria debería
requerirse. A partir de aquí, podríamos aplicar estas recomendaciones
manualmente. 

⚠️ Las recomendaciones dadas por el VPA vienen dadas en base
a los datos recolectados, por lo que para éstas sean lo más
útiles posibles, deberíamos esperar a recolectar aproximadamente 
unas 24h si estamos en el modo `Off`.

En lugar de aplicar las recomendaciones manualmente, vamos a 
proceder a cambiar la política de actualización del VPA.
Para ello ya tenemos preparado el manifiesto modificado
en [hello-vpa-auto.yaml](hello-vpa-auto.yaml):

```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: hello-server-vpa
spec:
  targetRef:
    apiVersion: "apps/v1"
    kind:       Deployment
    name:       hello-server
  updatePolicy:
    updateMode: "Auto"
```

Lo único que tenemos que hacer es actualizar el VPA
con el manifiesto mencionado mediante el siguiente comando:

```shell
$ kubectl apply -f hello-vpa-auto.yaml
```

Para que el VPA pueda adaptar el tamaño del pod, 
primero necesitará borra el pod y posteriormente recrearlo
con la nueva configuración de tamaño. 
Por configuración de defecto, VPA no va a borrar el 
último pod activo, que es el que estamos estudiando. Así
que necesitaremos al menos 2 réplicas para ver como el VPA
hace los cambios adecuados. Para ello, vamos a escalar
nosotros manualmente ahora el despliegue `hello-server` 
a dos réplicas:

```shell
$ kubectl scale deployment hello-server --replicas=2
```

A continuación, podemos monitorizar el comportamiento de los
pods mediante:

```shell
$ kubectl get pods -w
```

Esperamos hasta que veamos los pods `hello-server-xxx` en
el estado `terminating`. Esta es la señal de que nuestra VPA
ya está borrando y reconfigurando el tamaño de los pods.
Una vez que lo veamos podremos simplemente salir de la espera
pulsando `Ctrl + c` en nuestro terminal.

### 4. Comprobación de los autoescaladores HPA y VPA

#### HPA
A estas alturas, el HPA ya habrá escalado nuestro despliegue 
`php-apache` para optimizar recursos. Para comprobarlo
simplemente tenemos que ejecutar:

```shell
$ kubectl get hpa
```

Si miramos el número de réplicas en la columna correspondiente
veremos que HPA ha reducido el número de estas a 1.
Lo que ha ocurrido es que el HPA ha detectado que no hay ninguna
actividad en esta app, y por tanto ha liberado recursos.
Sin embargo, si hubiese demanda en esta aplicación entonces
HPA escalaría de nuevo hacia arriba. Como podemos observar,
esto es muy conveniente a la hora de optimizar costes.

#### VPA

Pasado unos minutos, el auto-escalador VPA habrá ya entrado
en juego y re-escalado los pods. Para ver si es así podemos
comprobarlo mediante:

```shell
$ kubectl describe pod hello-server | sed -n "/Containers:$/,/Conditions:/p"
```

Buscando el campo `Requests`, deberíamos ver ahora un valor inferior en 
cuanto a CPU se refiere, lo que significaría que el VPA ha entrado
en acción y ha hecho lo que debía (dada la falta de actividad).


### 5. Autoescalado del cluster

El auto-escalador de cluster (o Cluster Autoscaler) está diseñado
para añadir o eliminar nodos en función de la demanda del servicio.
Esto nos permitirá mantener una alta disponibilidad de nuestro
cluster haciendo posible evitar costes desorbitados asociados
con el mantenimiento de muchas instancias innecesarias.
Para activar el autoescalado (horizontal) de cluster lo único
que tenemos que hacer es:

```shell
$ gcloud beta container clusters update $cluster_name \
  --enable-autoscaling 
  --min-nodes 1 \
  --max-nodes 5
```

Esta tarea tardará unos minutos en completarse. Pero, esto
nos lleva a la siguiente pregunta: 
¿Cómo se decidirá cuando crear o destruir un nodo?
Para ello podemos seleccionar un perfil de autoescalado:

- *Balanced*: El seleccionado por defecto
- *Optimize-utilization*: Prioriza la optimización de la utilización
  sobre el mantenimiento de recursos disponibles. Es decir,
  el cluster autoescalará de manera mas agresiva, ya que no va 
  a priorizar tener algún nodo por si acaso unos segundos más, 
  por lo que veremos una eliminación más rápida de nodos.
  
Para cambiar a éste último perfil, podemos usar el siguiente
comando:

```shell
$ gcloud beta container clusters update $cluster_name \
--autoscaling-profile optimize-utilization
```

Para comprobar los nodos disponibles podemos usar:

```shell
$ kubectl get nodes
```

Aunque también podemos usar el portal web para verlo de una forma
más gráfica.


### 6. Auto aprovisionamiento de nodos
El autoescalado NAP consiste en añadir nuevos nodos al pool
de nodos asociado al cluster, pero con el tamaño adecuado para
adaptarse a la demanda. En ausencia de NAP, el autoecalador
de cluster crearía nodos con las mismas características
de los ya existentes, no adaptándose así verticalmente a la
demanda. Es por ello que el NAP es tan conveniente para un
uso adecuado de los recursos, más aún cuando tenemos cargas
de trabajo que son secuenciales (por *batches*), ya que 
con este modo de escalamiento el pool está optimizado para
nuestro caso de uso específico.

Para activar NAP en nuestro cluster:

```shell
gcloud container clusters update $cluster_name \
    --enable-autoprovisioning \
    --min-cpu 1 \
    --min-memory 2 \
    --max-cpu 45 \
    --max-memory 160
```

Donde estamos especificando el mínimo y máximo número de recursos
de CPU y memoria. Recordemos que esta estrategia es aplicable
al cluster completo. El NAP puede tardar unos minutos en activarse,
y a pesar de ello, puede ser que en nuestro ejemplo no entre en
juego dado el estado actual de nuestro cluster.

### Liberación de los recursos

Para borrar el clúster, solo tenemos que ejecutar:

```shell
gcloud container clusters delete $cluster_name --quiet
```

El proceso de borrado del clúster puede llevar unos minutos.
Este borrado también se podría haber hecho mediante [clean.sh](clean.sh):

```shell
chmod a+x clean.sh && ./clean.sh
```


