# Application Module - Main Configuration
# Create Azure Container Registry (ACR)
resource "azurerm_container_registry" "acr" {
  name                = "${replace(var.label_prefix, "-", "")}acr"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = true
}

# Create Kubernetes Provider Configuration for Test Environment
provider "kubernetes" {
  alias                  = "test"
  host                   = var.test_cluster_host
  client_certificate     = var.test_client_certificate
  client_key             = var.test_client_key
  cluster_ca_certificate = var.test_cluster_ca_certificate
}

# Create Kubernetes Provider Configuration for Production Environment
provider "kubernetes" {
  alias                  = "prod"
  host                   = var.prod_cluster_host
  client_certificate     = var.prod_client_certificate
  client_key             = var.prod_client_key
  cluster_ca_certificate = var.prod_cluster_ca_certificate
}

# Kubernetes Secret for Test Environment
resource "kubernetes_secret" "weather_app_secret_test" {
  provider = kubernetes.test
  
  metadata {
    name = "weather-app-secrets"
    namespace = "default"
  }

  data = {
    WEATHER_API_KEY = var.weather_api_key
    REDIS_URL = "rediss://:${var.test_redis_key}@${var.test_redis_host}:${var.test_redis_port}"
  }
}

# Kubernetes Secret for Production Environment
resource "kubernetes_secret" "weather_app_secret_prod" {
  provider = kubernetes.prod
  
  metadata {
    name = "weather-app-secrets"
    namespace = "default"
  }

  data = {
    WEATHER_API_KEY = var.weather_api_key
    REDIS_URL = "rediss://:${var.prod_redis_key}@${var.prod_redis_host}:${var.prod_redis_port}"
  }
}

# Kubernetes Deployment for Test Environment
resource "kubernetes_deployment" "weather_app_test" {
  provider = kubernetes.test

  metadata {
    name = "weather-app"
    namespace = "default"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "weather-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "weather-app"
        }
      }

      spec {
        container {
          image = "${azurerm_container_registry.acr.login_server}/weather-app:${var.image_tag}"
          name  = "weather-app"
          
          port {
            container_port = var.container_port
          }
          
          env_from {
            secret_ref {
              name = kubernetes_secret.weather_app_secret_test.metadata[0].name
            }
          }

          resources {
            limits = {
              cpu    = "1"
              memory = "1Gi"
            }
            requests = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }
        }
      }
    }
  }
}

# Kubernetes Service for Test Environment
resource "kubernetes_service" "weather_app_test" {
  provider = kubernetes.test

  metadata {
    name = "weather-app"
    namespace = "default"
  }

  spec {
    selector = {
      app = kubernetes_deployment.weather_app_test.metadata[0].labels.app
    }
    
    port {
      port        = 80
      target_port = var.container_port
    }

    type = "ClusterIP"
  }
}

# Kubernetes Deployment for Production Environment
resource "kubernetes_deployment" "weather_app_prod" {
  provider = kubernetes.prod

  metadata {
    name = "weather-app"
    namespace = "default"
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "weather-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "weather-app"
        }
      }

      spec {
        container {
          image = "${azurerm_container_registry.acr.login_server}/weather-app:${var.image_tag}"
          name  = "weather-app"
          
          port {
            container_port = var.container_port
          }
          
          env_from {
            secret_ref {
              name = kubernetes_secret.weather_app_secret_prod.metadata[0].name
            }
          }

          resources {
            limits = {
              cpu    = "1"
              memory = "1Gi"
            }
            requests = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }
        }
      }
    }
  }
}

# Kubernetes Service for Production Environment
resource "kubernetes_service" "weather_app_prod" {
  provider = kubernetes.prod

  metadata {
    name = "weather-app"
    namespace = "default"
  }

  spec {
    selector = {
      app = kubernetes_deployment.weather_app_prod.metadata[0].labels.app
    }
    
    port {
      port        = 80
      target_port = var.container_port
    }

    type = "LoadBalancer"
  }
} 