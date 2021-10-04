En este ejemplo vamos a proceder a la creación de una máquina virtual
en Azure mediante linea de comandos. Para ello podemos proceder tanto desde
[azure shell](https://shell.azure.com/bash) como desde local si tenemos 
instalado y autenticado azure CLI, i.e. el comando `az`.

### Crear un grupo de recursos (resource group)

El primer paso es crear un [grupo de recursos](https://docs.microsoft.com/es-es/azure/azure-resource-manager/management/manage-resource-groups-portal) al 
que posteriormente asociaremos nuestra máquina virtual (VM). 
Para ello:

1. Ejecutar: 
   ```shell
   $ az group create \
      --name example-resource-group \
      --location eastus
   ```
   lo cual genera un grupo de recursos con nombre `example-resource-group` y
   cuya localización es `eastus`. Para conocer todas las localizaciones disponibles 
   podemos listarlas mediante:

   ````shell
   $ az account list-locations -o table
   ````

2. Una vez creado el grupo de recursos, vamos a crear la VM asociada a dicho 
   grupo, con una imagen de `Win2019Datacenter`:
   ```shell
    $ az vm create \
      --resource-group example-resource-group \
      --name my-first-vm \
      --image Win2019Datacenter \
      --public-ip-sku Standard \
      --admin-username azureuser
   ```
   Tras su ejecución tendremos que introducir una contraseña para el administrador 
   que tiene como username `azureuser`. Un ejemplo de password seguro: `vTL2yc-f3{@G$j#%`.
   
3. Finalmente obtendremos un resultado como:
   ```json
   {
    "fqdns": "",
    "id": "/subscriptions/ba177dd4-6f82-4747-8988-3e9c9abfa4c0/resourceGroups/example-resource-group/providers/Microsoft.Compute/virtualMachines/my-first-vm",
    "location": "eastus",
    "macAddress": "00-22-48-25-1C-6A",
    "powerState": "VM running",
    "privateIpAddress": "10.0.0.4",
    "publicIpAddress": "40.76.155.167",
    "resourceGroup": "example-resource-group",
    "zones": ""
   }
   ```
   Hemos de notar la dirección pública de la VM para poder acceder a ella posteriormente

4. A continuación, abrimos el puerto 80 para poder acceder a esta IP a posteriori a través de nuestro
   navegador web:
   ```shell
   $ az vm open-port --port 80 --resource-group example-resource-group --name my-first-vm
   ```
   
5. Ahora nos podemos conectar a la máquina via RDP (remote desktop protocol). 
   Una vez dentro de la máquina, procedemos a la instalación el `IIS web server`. 
   PAra ello, abrimos powershell y ejecutamos:
   
   ```shell
   $ Install-WindowsFeature -name Web-Server -IncludeManagementTools
   ```

6. Podemos proceder ahora a visitar la web que está sirviendo susodicha máquina
   simplemente abriendo en nuestro explorador web la IP de la máquina. 
   En el caso de este ejemplo: `40.76.155.167:80`
   
### Limpieza de recursos

Para no incurrir en gastos que consuman nuestros créditos de prueba tenemos que borrar
todo que hemos creado. Para ello podemos simplemente borrar el grupo de recursos mediante 
el siguiente código:

```shell
$ az group delete --name example-resource-group
```

