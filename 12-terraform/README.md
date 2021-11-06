### Introducción 

El objetivo de este Lab es el de presentar las posibilidades 
ofrecidas por [Terraform](https://www.terraform.io/). 
En particular, vamos a crear un fichero de configuración que 
enuncia la creación de una máquina virtual, y posteriormente
procederemos a la planificación y aplicación de la susodicha
configuración mediante la línea de comando `terraform`.

Para la realización de este lab será necesario tener instalada
la línea de comando `terraform`. Podrás encontrar instrucciones 
sobre su descarga e instalación en la página oficial:
[aquí](https://www.terraform.io/downloads.html).

#### Fichero de configuración

Al igual que en el caso de Deployment Manager, necesitamos
un fichero de configuración que será en el que listemos los
recursos de infraestructura a desplegar. En este caso, vamos
a generar una configuración que finalmente generará una 
máquina virtual en nuestro proyecto. Recuerda que para que
este ejemplo funcione en tu proyecto, tendrás que cambiar el nombre
del proyecto para que coincida con el tuyo.

El fichero de configuración en este caso no será un YAML.
Esto se debe a que Terraform tiene su propia sintaxis que su
línea de comando es capaz de traducir a órdenes específicas
de cada una de las nubes con las que podemos trabajar. Podemos
ver rápidamente que el fichero es bastante más liviano 
que en el caso de Deplyment Manager:

```terraform
resource "google_compute_instance" "terraform" {
  project      = "innate-infusion-327910"
  name         = "terraform"
  machine_type = "n1-standard-1"
  zone         = "us-central1-a"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }
  network_interface {
    network = "default"
    access_config {
    }
  }
}
```

Se puede ver perfectamente como se está listando un recurso
de tipo `google_compute_instance`, cuyas características se
precisan dentro de la región de definición `{ ... }`.
Como vemos, la VM tendrá `Debian9` y será conectada a la
red por defecto de nuestro proyecto. 

Para entender la sintaxis particular de Terraform, nos
referimos a la documentación oficial [aquí](https://www.terraform.io/docs/language/index.html).

Una vez tenemos el fichero de configuración guardado como [instance.tf](instance.tf),
procedemos a la inicialización, planificación y aplicación del mismo:

#### Inicialización

A continuación mostramos el comportamiento esperado:
```shell
$ terraform init

Initializing the backend...

Initializing provider plugins...
- Finding latest version of hashicorp/google...
- Installing hashicorp/google v4.0.0...
- Installed hashicorp/google v4.0.0 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

Para comprobar que se ha descargado el plugin como debe
ser, podemos listar el contenido de la carpeta:

```shell
ll -a

drwxr-xr-x   6 staff   192B  6 Nov 17:37 .
drwxr-xr-x@ 21 staff   672B  6 Nov 17:23 ..
drwxr-xr-x   3 staff    96B  6 Nov 17:35 .terraform
-rw-r--r--   1 staff   1.1K  6 Nov 17:35 .terraform.lock.hcl
-rw-r--r--   1 staff   3.3K  6 Nov 17:37 README.md
-rw-r--r--   1 staff   349B  6 Nov 17:25 instance.tf
```

De hecho, el plugin mencionado estará en la subcarpeta:
`.terraform/providers/registry.terraform.io/hashicorp/google/4.0.0/darwin_amd64/`
y tendrá el nombre: `terraform-provider-google_v4.0.0_x5`

#### Planificación

A continuación mostramos el comportamiento esperado:

```shell
$ terraform plan

Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # google_compute_instance.terraform will be created
  + resource "google_compute_instance" "terraform" {
      + can_ip_forward       = false
      + cpu_platform         = (known after apply)
      + current_status       = (known after apply)
      + deletion_protection  = false
      + guest_accelerator    = (known after apply)
      + id                   = (known after apply)
      + instance_id          = (known after apply)
      + label_fingerprint    = (known after apply)
      + machine_type         = "n1-standard-1"
      + metadata_fingerprint = (known after apply)
      + min_cpu_platform     = (known after apply)
      + name                 = "terraform"
      + project              = "innate-infusion-327910"
      + self_link            = (known after apply)
      + tags_fingerprint     = (known after apply)
      + zone                 = "us-central1-a"

      + boot_disk {
          + auto_delete                = true
          + device_name                = (known after apply)
          + disk_encryption_key_sha256 = (known after apply)
          + kms_key_self_link          = (known after apply)
          + mode                       = "READ_WRITE"
          + source                     = (known after apply)

          + initialize_params {
              + image  = "debian-cloud/debian-9"
              + labels = (known after apply)
              + size   = (known after apply)
              + type   = (known after apply)
            }
        }

      + confidential_instance_config {
          + enable_confidential_compute = (known after apply)
        }

      + network_interface {
          + ipv6_access_type   = (known after apply)
          + name               = (known after apply)
          + network            = "default"
          + network_ip         = (known after apply)
          + stack_type         = (known after apply)
          + subnetwork         = (known after apply)
          + subnetwork_project = (known after apply)

          + access_config {
              + nat_ip       = (known after apply)
              + network_tier = (known after apply)
            }
        }

      + reservation_affinity {
          + type = (known after apply)

          + specific_reservation {
              + key    = (known after apply)
              + values = (known after apply)
            }
        }

      + scheduling {
          + automatic_restart   = (known after apply)
          + min_node_cpus       = (known after apply)
          + on_host_maintenance = (known after apply)
          + preemptible         = (known after apply)

          + node_affinities {
              + key      = (known after apply)
              + operator = (known after apply)
              + values   = (known after apply)
            }
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

───────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't
guarantee to take exactly these actions if you run "terraform apply" now.
```

Donde podemos ver fácilmente que Terraform va a proceder a la
creación de 1 nuevo recurso de infraestructura, en concreto una
VM con las especificaciones dadas. Podemos comprobar que hay 
muchos campos en los cuales tenemos: `(known after apply)`. 
Esto se debe a que susodichos campos no se han especificado en la
configuración, y por tanto serán poblados con los valores por 
defecto, y por ende solo serán conocidos tras su creación.


#### Aplicación

A continuación mostramos el comportamiento esperado:

```shell
terraform apply

Terraform used the selected providers to generate the following execution plan. Resource actions
are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # google_compute_instance.terraform will be created
  + resource "google_compute_instance" "terraform" {
      + can_ip_forward       = false
      + cpu_platform         = (known after apply)
      + current_status       = (known after apply)
      + deletion_protection  = false
      + guest_accelerator    = (known after apply)
      + id                   = (known after apply)
      + instance_id          = (known after apply)
      + label_fingerprint    = (known after apply)
      + machine_type         = "n1-standard-1"
      + metadata_fingerprint = (known after apply)
      + min_cpu_platform     = (known after apply)
      + name                 = "terraform"
      + project              = "innate-infusion-327910"
      + self_link            = (known after apply)
      + tags_fingerprint     = (known after apply)
      + zone                 = "us-central1-a"

      + boot_disk {
          + auto_delete                = true
          + device_name                = (known after apply)
          + disk_encryption_key_sha256 = (known after apply)
          + kms_key_self_link          = (known after apply)
          + mode                       = "READ_WRITE"
          + source                     = (known after apply)

          + initialize_params {
              + image  = "debian-cloud/debian-9"
              + labels = (known after apply)
              + size   = (known after apply)
              + type   = (known after apply)
            }
        }

      + confidential_instance_config {
          + enable_confidential_compute = (known after apply)
        }

      + network_interface {
          + ipv6_access_type   = (known after apply)
          + name               = (known after apply)
          + network            = "default"
          + network_ip         = (known after apply)
          + stack_type         = (known after apply)
          + subnetwork         = (known after apply)
          + subnetwork_project = (known after apply)

          + access_config {
              + nat_ip       = (known after apply)
              + network_tier = (known after apply)
            }
        }

      + reservation_affinity {
          + type = (known after apply)

          + specific_reservation {
              + key    = (known after apply)
              + values = (known after apply)
            }
        }

      + scheduling {
          + automatic_restart   = (known after apply)
          + min_node_cpus       = (known after apply)
          + on_host_maintenance = (known after apply)
          + preemptible         = (known after apply)

          + node_affinities {
              + key      = (known after apply)
              + operator = (known after apply)
              + values   = (known after apply)
            }
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value:
```

Podemos ver que Terraform nos vuelve a mostrar el plan de
ejecución y espera a que confirmemos que continuamos con 
él. Introducimos `yes` para continuar y proceder con la creación
de la máquina virtual. Obtendremos la siguiente salida:

```shell
google_compute_instance.terraform: Creating...
google_compute_instance.terraform: Still creating... [10s elapsed]
google_compute_instance.terraform: Still creating... [20s elapsed]
google_compute_instance.terraform: Still creating... [30s elapsed]
google_compute_instance.terraform: Creation complete after 37s [id=projects/innate-infusion-327910/zones/us-central1-a/instances/terraform]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

#### Liberación de los recursos

Para liberar recursos, solo tenemos que ejecutar:

```shell
$ terraform destroy
```

que hará las veces del ya habitual script de limpieza que hemos
usado en los anteriores labs (el conocido `clean.sh`).
Al igual que antes, Terraform nos preguntará antes de proceder, 
ya que se trata de un cambio de infraestructura relevante.
Solo tenemos que escribir `yes` y la infraestructura será
destruida.
  
