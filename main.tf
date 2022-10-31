resource "kubernetes_config_map" "configmap" {
  metadata {
    name      = "${var.name}-fluentd-configmap"
    namespace = var.namespace
  }

  data = {
    fluentd_conf = templatefile(
      "${path.module}/fluentd.tmpl.conf",
      {
        broker_servers = var.broker_servers
        consumer_group = var.consumer_group
        topics         = var.topics

        max_bytes               = var.max_bytes
        max_wait_time           = var.max_wait_time
        min_bytes               = var.min_bytes
        offset_commit_interval  = var.offset_commit_interval
        offset_commit_threshold = var.offset_commit_threshold
        fetcher_max_queue_size  = var.fetcher_max_queue_size
        refresh_topic_interval  = var.refresh_topic_interval
        start_from_beginning    = var.start_from_beginning

        access_key        = var.access_key
        secret_key        = var.secret_key
        bucket_name       = var.bucket_name
        endpoint          = var.endpoint
        time_slice_format = var.time_slice_format

        path             = var.path
        timekey          = var.timekey
        timekey_wait     = var.timekey_wait
        timekey_use_utc  = var.timekey_use_utc
        chunk_limit_size = var.chunk_limit_size
      }
    )
  }
}

resource "kubernetes_persistent_volume_claim" "fluentd-buffer" {
  count = ${var.number}
  metadata {
    name = "${var.name}-buffer-volume"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "${pvc_buffer_size}"
      }
    }
  }
}

resource "kubernetes_deployment" "fluentd-kafka-s3-archiver" {
  depends_on = [kubernetes_config_map.configmap]

  metadata {
    name      = var.name
    namespace = var.namespace
  }

  spec {
    replicas = var.number
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
            name       = "${var.name}-buffer-volume"
          }

          volume_mount {
            mount_path = "/fluentd/etc"
            name       = "${var.name}-config-volume"
          }
        }

        volume {
          name = "${var.name}-buffer"
          persistent_volume_claim {
            claim_name = "${var.name}-buffer-volume-${count.index}"
          }
        }

        volume {
          name = "${var.name}-config-volume"

          config_map {
            name = "${var.name}-fluentd-configmap"

            items {
              key  = "fluentd_conf"
              path = "fluentd.conf"
            }
          }
        }
      }
    }
  }
}
