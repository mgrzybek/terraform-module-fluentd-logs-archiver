resource "kubernetes_config_map" "configmap" {
  metadata {
    name      = "${var.name}-fluentd-configmap"
    namespace = var.namespace
  }

  data = {
    fluent_conf = templatefile(
      "${path.module}/fluent.tmpl.conf",
      {
        broker_servers = var.broker_servers
        consumer_group = var.consumer_group
        topics         = join(",", var.topics)

        start_from_beginning = var.start_from_beginning

        access_key        = var.access_key
        secret_key        = var.secret_key
        bucket_name       = var.bucket_name
        endpoint          = var.endpoint
        time_slice_format = var.time_slice_format

        verify_peer = var.verify_peer

        region           = var.region
        path             = var.path
        timekey          = var.timekey
        timekey_wait     = var.timekey_wait
        timekey_use_utc  = var.timekey_use_utc
        chunk_limit_size = var.chunk_limit_size
      }
    )
  }
}

resource "kubernetes_persistent_volume_claim" "buffer" {
  metadata {
    name      = "${var.name}-buffer-volume"
    namespace = var.namespace
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.pvc_buffer_size
      }
    }
  }
}

resource "kubernetes_deployment" "fluentd-kafka-s3-archiver" {
  metadata {
    name      = var.name
    namespace = var.namespace
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = var.name
      }
    }

    template {
      metadata {
        labels = {
          app = var.name
        }
      }

      spec {
        container {
          image = var.image
          name  = var.name

          resources {
            limits = {
              cpu    = "1000m"
              memory = "1Gi"
            }
            requests = {
              cpu    = "800m"
              memory = "1Gi"
            }
          }

          volume_mount {
            mount_path = var.path
            name       = "${var.name}-buffer"
          }

          volume_mount {
            mount_path = "/fluentd/etc"
            name       = "${var.name}-config"
          }
        }

        volume {
          name = "${var.name}-buffer"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.buffer.metadata.0.name
          }
        }

        volume {
          name = "${var.name}-config"

          config_map {
            name = kubernetes_config_map.configmap.metadata.0.name

            items {
              key  = "fluent_conf"
              path = "fluent.conf"
            }
          }
        }
      }
    }
  }
}