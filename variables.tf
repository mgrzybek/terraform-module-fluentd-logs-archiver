#####################################################
# Kubernetes
#
variable "name" {
  type        = string
  description = "Name and prefix of the created objects"
}

variable "namespace" {
  type        = string
  description = "The namespace used to install bucket"
}

variable "number" {
  type        = number
  description = "Number of pods to start"
  default     = 1
}

variable "image" {
  type        = string
  description = "Container image providing fluentd with kafka et s3 support"
  default     = "ghcr.io/mgrzybek/fluentd-kafka-s3-logs-archiver:main"
}

#####################################################
# Kafka
#
variable "broker_servers" {
  type        = string
  description = "host:port,"
}

variable "consumer_group" {
  type        = string
  description = "The key used to consumer using several archivers in parallel"
}

variable "destination_tech_topic" {
  type        = string
  description = "The topic to write the tech logs into"
}

variable "topics" {
  type        = list(string)
  description = "A list a topics to read from"
}

variable "max_bytes" {
  type = number
  default = 1048576
  description = "ruby-kafka consumer option"
}

variable "max_wait_time" {
  type = number
  default = nil
  description = "ruby-kafka consumer option"
}

variable "min_bytes" {
  type = number
  default = nil
  description = "ruby-kafka consumer option"
}

variable "offset_commit_interval" {
  type = number
  default = nil
  description = "ruby-kafka consumer option"
}

variable "offset_commit_threshold" {
  type = number
  default = nil
  description = "ruby-kafka consumer option"
}

variable "fetcher_max_queue_size" {
  type = number
  default = nil
  description = "ruby-kafka consumer option"
}

variable "refresh_topic_interval" {
  type = number
  default = nil
  description = "ruby-kafka consumer option"
}

variable "start_from_beginning" {
  type = boolean
  default = true
  description = "ruby-kafka consumer option"
}

#####################################################
# S3
#
variable "access_key" {
  type = string
}

variable "secret_key" {
  type = string
}

variable "bucket_name" {
  type = string
}

variable "endpoint" {
  type = string
}

variable "time_slice_format" {
  type = string
  default = "%Y-%m-%d-%H-%M"
  description = "Timestamp added to each object"
}

#####################################################
# Buffer
#
variable "path" {
  type = string
  default = "/var/log/td-agent/s3"
  description = ""
}

variable "timekey" {
  type = string
  default = "60m"
  description = "Flush the accumulated chunks every n minutes"
}

variable "timekey_wait" {
  type = string
  default = "1m"
  description = "Wait n minutes before flushing"
}

variable "timekey_use_utc" {
  type = boolean
  default = true
  description = "Use UTC timestamps"
}

variable "chunk_limit_size" {
  type = string
  default = "256m"
  description = "The maximum size of each chunk"
}

#####################################################
# PVC
#
variable "pvc_buffer_size" {
  type = string
  default = "5Gi"
  description = "Size of the volume provided to fluentd's buffer"
}

