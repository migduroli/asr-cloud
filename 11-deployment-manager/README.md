### Introducción

El objetivo de este Lab es el de presentar las posibilidades
ofrecidas por [Google Cloud Deployment Manager](https://cloud.google.com/deployment-manager/).
En particular, vamos a crear un manifiesto de configuración
que enuncia la creación de dos máquinas virtuales. 


#### Creación de dos máquinas virtuales

La generación de dos máquinas virtuales puede realizarse,
como ya vimos en los primeros ejemplos, simplemente usando
la líne de comandos `gcloud compute instances create [OPCIONES]`. 
Sin embargo, en este ejemplo vamos a usar un archivo de
configuración, en particular [two-vms.yaml](two-vms.yaml).
Dicho archivo de configuración está preparado para un 
proyecto genérico, llamado `MY_PROJECT`. Así que, antes de nada,
para que funcione en nuestro caso tendremos que sustituir 
`MY_PROJECT` con el identificador de nuestro proyecto. 
Esto lo podemos hacer manualmente, o usando:

```shell
$ sed -i -e 's/MY_PROJECT/{{project-id}}/g' two-vms.yaml
```

cambiando `project-id` por el identificador de nuestro proyecto.

Una vez tenemos el archivo de configuración preparado, 
solo tendremos que ejecutar el siguiente comando:

```shell
$ gcloud deployment-manager deployments create test-despliegue-dm \ 
      --config two-vms.yaml
```

Esto generará un despliegue que podremos monitorizar en nuestro
terminal, y en nuestro portal web. Una vez finalizado, deberíamos
obtener algo similar a lo siguiente:

```shell
Waiting for create [operation-1636208867613-5d01f90551bef-98f2b8ce-faafd643]...done.
Create operation operation-1636208867613-5d01f90551bef-98f2b8ce-faafd643 completed successfully.
NAME           TYPE                 STATE      ERRORS  INTENT
the-first-vm   compute.v1.instance  COMPLETED  []
the-second-vm  compute.v1.instance  COMPLETED  []
```

#### Liberación de recursos 

Para liberar recursos, solo tenemos que ejecutar: 

```shell
gcloud deployment-manager deployments delete deployment-with-2-vms
```

que hará las veces del ya habitual script de limpieza que hemos
usado en los anteriores labs (el conocido `clean.sh`).

El resultado de la ejecución debería ser algo similar a:

```shell
The following deployments will be deleted:
- deployment-with-2-vms

Do you want to continue (y/N)?  y
```
  
