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

