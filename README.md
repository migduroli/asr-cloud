## ASR Cloud 🚀

Este repositorio contiene las prácticas (quick-labs) que se siguen en el 
módulo de Cloud Computing del curso de *Arquitectura de Sistemas en Red - Cloud Computing*,
que se imparte en el primer curso del Master en Ingeniería de Telecomunicación 
en la Universidad Pontificia de Comillas.

## Uso de la consola: cloud shell, cloud console y sdk

En primera instancia, las tareas que vamos a programar en los primeros ejemplos
serán lo suficientemente sencillas como para poderse hacer directamente desde la consola (terminal)
que se ofrece en el portal del proveedor cloud:

- Microsoft Azure (AZ): [Azure Cloud Shell](https://docs.microsoft.com/en-us/azure/cloud-shell/overview)
- Google Cloud Platform (GCP): [Cloud Shell](https://cloud.google.com/shell)

### Azure

Para utilizar el terminal de Azure, podemos proceder tan fácilmente como:

1. Ir a la siguiente dirección: [https://shell.azure.com]( https://shell.azure.com)
2. Seleccionar el icono de Cloud Shell en el [portal web](https://portal.azure.com/#home): ![img.png](.images/az-portal-shell.png)

Ambas dos opciones nos llevarán a una version online de un terminal que nos va a 
permitir trabajar con los servicios y recursos Cloud de AZ de manera programática.
La referencia de los comandos que podemos usar para estas taréas se puede encontrar
en la [web](https://docs.microsoft.com/en-us/cli/azure/reference-index?view=azure-cli-latest).


### Google
Para utilizar el terminal de Google, podemos proceder tan fácilmente como:

1. Ir a la siguiente dirección: [https://shell.cloud.google.com/](https://shell.cloud.google.com/)
2. Seleccionar el icono de Cloud Shell en el portal [portal web](https://console.cloud.google.com): ![img.png](.images/gcp-portal-shell.png)

Ambas dos opciones nos llevarán a una version online de un terminal que nos va a
permitir trabajar con los servicios y recursos Cloud de Google de manera programática.
La referencia de los comandos que podemos usar para estas taréas se puede encontrar
en la [web](https://cloud.google.com/sdk/gcloud/reference).


### Software Development Kits: Azure y Google 

A medida que avancemos en el curso, será costumbre en nuestras prácticas el trabajar con nuestro
terminal, tanto en Windows como en sistemas Linux. 
Por ello, lo primero que tenemos que asegurarnos es que tenemos instalado el kit de desarrollo del proveedor:

- Azure: [Instrucciones de instalación en todos los OS](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- Google: [Instrucciones de instalación en todos los OS](https://cloud.google.com/sdk/docs/install)

Una vez instalados, tendremos la posibilidad de ejecutar los comandos de Cloud Shell desde 
local. El primero y más importantes de estos comandos es la inicialización. 
Para Azure, el comando de terminal es ``az``, y procederíamos como sigue:

```shell
$ az login
```

En el caso de Google, el comando de terminal es ``gcloud``, y se procede de la siguiente
forma:

```shell
$ gcloud init
```

Con esto, deberíamos tener todo listo para empezar a trabajar en el fascinante 
mundo Cloud ☁️

## Terminales recomendados

Para hacer más agradable la tarea de *shell scripting* recomendamos las siguientes
terminales según OS:

- Windows:
  
    1. [Fluent Terminal](https://www.microsoft.com/es-es/p/fluent-terminal/9p2krlmfxf9t)
    2. [Windows terminal](https://www.microsoft.com/es-es/p/windows-terminal/9n0dx20hk701?rtc=1)
    3. [Terminus](https://tabby.sh/)
    
- Mac OS:

    1. [iTerm2](https://iterm2.com/) + [OhMyZsh](https://ohmyz.sh/)

- Linxu:
    1. La terminal nativa + [OhMyZsh](https://ohmyz.sh/)

## Colaboración

El repositorio está abierto a la colaboración y mejora de los ejemplos, pero siempre siguiendo
unas normas básicas de estilo y comportamiento. Los pasos de contribución están especificados
en [Contributing.md](CONTRIBUTING.md)
