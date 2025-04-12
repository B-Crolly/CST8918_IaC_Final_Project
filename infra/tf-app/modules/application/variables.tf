# Application Module - Variables
variable "label_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

# AKS Cluster Connection Details - Test
variable "test_cluster_host" {
  description = "The Kubernetes cluster server host for the test cluster"
  type        = string
}

variable "test_client_certificate" {
  description = "Base64 encoded certificate used by clients to authenticate to the Kubernetes cluster"
  type        = string
  sensitive   = true
}

variable "test_client_key" {
  description = "Base64 encoded private key used by clients to authenticate to the Kubernetes cluster"
  type        = string
  sensitive   = true
}

variable "test_cluster_ca_certificate" {
  description = "Base64 encoded public CA certificate used as the root of trust for the Kubernetes cluster"
  type        = string
  sensitive   = true
}

# AKS Cluster Connection Details - Production
variable "prod_cluster_host" {
  description = "The Kubernetes cluster server host for the production cluster"
  type        = string
}

variable "prod_client_certificate" {
  description = "Base64 encoded certificate used by clients to authenticate to the Kubernetes cluster"
  type        = string
  sensitive   = true
}

variable "prod_client_key" {
  description = "Base64 encoded private key used by clients to authenticate to the Kubernetes cluster"
  type        = string
  sensitive   = true
}

variable "prod_cluster_ca_certificate" {
  description = "Base64 encoded public CA certificate used as the root of trust for the Kubernetes cluster"
  type        = string
  sensitive   = true
}

# Redis Connection Details - Test
variable "test_redis_host" {
  description = "The hostname of the Redis Cache in the test environment"
  type        = string
}

variable "test_redis_port" {
  description = "The port of the Redis Cache in the test environment"
  type        = number
}

variable "test_redis_key" {
  description = "The primary access key for the Redis Cache in the test environment"
  type        = string
  sensitive   = true
}

# Redis Connection Details - Production
variable "prod_redis_host" {
  description = "The hostname of the Redis Cache in the production environment"
  type        = string
}

variable "prod_redis_port" {
  description = "The port of the Redis Cache in the production environment"
  type        = number
}

variable "prod_redis_key" {
  description = "The primary access key for the Redis Cache in the production environment"
  type        = string
  sensitive   = true
}

# Weather API Configuration
variable "weather_api_key" {
  description = "API key for the OpenWeather API"
  type        = string
  sensitive   = true
}

# Container Configuration
variable "image_tag" {
  description = "The tag to use for the container image"
  type        = string
  default     = "latest"
}

variable "container_port" {
  description = "The port the container exposes"
  type        = number
  default     = 80
} 