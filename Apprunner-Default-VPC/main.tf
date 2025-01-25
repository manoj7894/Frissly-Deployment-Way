module "app_runner_backend" {
  source = "./module/app_runner/backend"

  app_runner_service_name         = "Frissly-Backend"
  repository_name                 = "frissly-docker-repo" # Replace with your ECR repository name
  image_tag                       = "latest"              # Replace with your specific tag if necessary
  image_repository_type           = "ECR"
  auto_scaling_configuration_name = "Frissly-backend-autoscaling"
  max_concurrency                 = "100"
  min_size                        = "1" # Minimum number of instances
  max_size                        = "3" # Maximum number of instances
  port                            = 8081
  cpu                             = 256 # 0.25 vCPU
  memory                          = 512 # 0.5 GB RAM
  auto_deployments_enabled        = "true"
  interval                        = "10"  # App Runner sends a health check request every 10 seconds to determine the status of the service instance.
  timeout                         = "5"   # If the service does not respond to a health check request within 5 seconds, the health check will be marked as failed.
  healthy_threshold               = "3"   #  App Runner needs to receive 3 consecutive successful health check responses before marking the instance as healthy.
  unhealthy_threshold             = "3"   # App Runner will mark the instance as unhealthy after 3 consecutive failed health checks.
  protocol                        = "TCP" # App Runner will check if the service instance is reachable on the specified port using a TCP connection. No HTTP requests are sent in this case.

}


# Concurrent requests refer to the number of requests that are being processed at the same time by a service or application. 
# In the context of AWS App Runner, it indicates how many client requests a single instance of your service can handle simultaneously.