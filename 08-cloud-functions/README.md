### Introducción

El objetivo de este lab es la demostración de como
podemos desplegar de manera sencilla una función
en Google Cloud Function. Para este propósito hemos
creado una función en Python cuyo "trigger" es
una llamada HTTP (para ver los posibles triggers
que acepta una cloud function, consultar la 
[documentación oficial](https://cloud.google.com/functions/docs/concepts/events-triggers)).

### Función y Despliegue

La función es bastante sencilla, consiste de un
único método que devuelve un número aleatorio, 
uniformemente distribuido en el rango de un 
intervalo que se definirá acorde a los valores
mínimo y máximo pasados como carga JSON de la request:

```python
from random import uniform

def uniform_random_value(l_boundary: float, r_boundary: float) -> float:
    """
    Returns a random number according to uniform distribution
    """
    return uniform(l_boundary, r_boundary)

def get_urandom(request):
    """
    Returns a uniformly distributed random number provided the
    bounds of the interval are passed as a JSON load of the
    request in the form:

        json_load = {"a": 1.123, "b": 2.345}

    The the number returned will be: x ∈ [a,b]

    :return: Dict
    """

    print("The request has entered...")
    request_json = request.get_json(silent=True)

    print(f"request = {request}")

    r = {}
    if request_json and ("a" in request_json):
        print("Correct parsing and parameter was in json...")
        r = request_json
    else:
        print("Something happened with the parsing...")
        r = {"a": 0, "b": 1}

    print(f"The JSON load has been read: {r}")
    
    return {"value": uniform_random_value(r["a"], r["b"])}
```

El despliegue de susodicha *function* es bastante
sencillo, como se puede comprobar en [deployment.sh](deployment.sh):

```shell
gcloud functions deploy urandom-generator \
        --entry-point=get_urandom \
        --region europe-west1 \
        --runtime python38 \
        --trigger-http \
        --memory 128MB \
        --timeout 60s \
        --allow-unauthenticated
```

En el despliegue se especifica el *runtime* que 
vamos a usar, i.e. `Python 3.8`, así como una 
mínima información sobre la memoria requerida y 
detalles sobre la seguridad de quien puede "llamar"
a esta función (`--allow-unauthenticated`).

Una vez haya terminado el despliegue, Google SDK
nos informará de que se ha generado una URL 
para la función. Para probarla podemos usar:

```shell
curl -X POST $URL \
  -H "Content-Type:application/json" \
  -d '{"a": 10, "b":12}'
```

esto nos devolverá como respuesta un JSON
con una clave-valor `{"key": "value"}`, donde 
`value` será un valor aleatorio uniformemente distribuido
en el intervalo `[10, 12]`.

### Liberación de los recursos

Para liberar recursos, como es ya costumbre, 
disponemos de un script de limpieza.
Solo tenemos que ejecutar:

```shell
chmod a+x clean.sh && ./clean.sh
```