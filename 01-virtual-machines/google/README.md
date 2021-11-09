En este ejemplo vamos a proceder a la creación de una máquina virtual
en Google mediante línea de comandos. Para ello podemos proceder tanto desde
[cloud shell](https://shell.cloud.google.com/) como desde local si tenemos
instalado y autenticado Google SDK, i.e. el comando `gcloud`.

### Crear un prototipo de instancia

En este caso, el primer paso va a ser la creación de un prototipo de instancia.
Un prototipo de instancia (*instance template*) es un recurso que podemos usar a
posteriori para la creación de VMs tanto no gestionadas como gestionadas (*managed
instance groups*, o MIGs) de manera rápida y eficiente. 
Para ello:

1. Ejecutar:
    ```shell
    $ gcloud beta compute instance-templates create asr-template-vm \
      --machine-type=e2-medium \
      --tags=http-server,https-server \
      --image=debian-10-buster-v20210916 \
      --image-project=debian-cloud \
      --boot-disk-size=10GB \
      --metadata-from-file=startup-script=startup-script.sh
    ```
    
    Tras lo que deberíamos recibir un mensaje parecido a:
    ```shell
    WARNING: You have selected a disk size of under [200GB]. This may result in poor I/O performance. For more information, see: https://developers.google.com/compute/docs/disks#performance.
    Created [https://www.googleapis.com/compute/beta/projects/innate-infusion-327910/global/instanceTemplates/my-first-vm].
    
    NAME         MACHINE_TYPE  PREEMPTIBLE  CREATION_TIMESTAMP
    asr-template-vm  e2-medium                  2021-10-04T02:26:54.922-07:00
    ```

2. Para saber qué prototipos tenemos creados en nuestro proyecto, podemos listarlos mediante
   el comando:
   
   ```shell
   $ gcloud compute instance-templates list
   ```
   
   Lo cual nos devolverá precisamente la misma salida que el mensaje anterior


3. A continuación podemos ejecutar: 
   ```shell
   $ gcloud compute instances create example-instance \
      --zone=europe-west1-b \
      --source-instance-template=asr-template-vm
   ```
   Lo que nos creará la máquina virtual `example-instance`


5. Ahora nos podemos proceder ahora a visitar la web que está sirviendo susodicha máquina
   simplemente abriendo en nuestro explorador web la IP de la máquina. 
   En principio, esto no debería mostrarnos nada porque tenemos que 
   habilitar el ingreso por el puerto `80` en la red `default`. 
   En este ejemplo, esta *firewall rule* la creamos mediante el
   portal web, aunque en proximos labs veremos como hacerlo programáticamente.

### Limpieza de recursos

Para no incurrir en gastos que consuman nuestros créditos de prueba tenemos que borrar
todo que hemos creado. Para ello podemos simplemente borrar el la máquina virtual mediante
el siguiente comando:

```shell
$ gcloud compute instances delete example-instance
```

