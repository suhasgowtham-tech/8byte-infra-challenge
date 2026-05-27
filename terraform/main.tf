# 1. Core Network Foundation Module
module "networking" {
  source      = "./modules/networking"
  vpc_cidr    = var.vpc_cidr
  environment = var.environment
}

# 2. Dynamic High Availability Compute Cluster Module
module "compute" {
  source                 = "./modules/compute"
  environment            = var.environment
  vpc_id                 = module.networking.vpc_id
  public_subnet_ids      = module.networking.public_subnet_ids
  private_app_subnet_ids = module.networking.private_app_subnet_ids
}

# 3. Isolated PostgreSQL RDS Storage Layer Module
module "database" {
  source                = "./modules/database"
  environment           = var.environment
  vpc_id                = module.networking.vpc_id
  private_db_subnet_ids = module.networking.private_db_subnet_ids
  app_security_group_id = module.compute.ecs_tasks_security_group_id
}

# 4. Centralized Monitoring, Alerting, & Logging Module (Part 3 Complete)
module "monitoring" {
  source                 = "./modules/monitoring"
  environment            = var.environment
  ecs_cluster_name       = module.compute.ecs_cluster_name
  ecs_service_name       = module.compute.ecs_service_name
  db_instance_identifier = module.database.db_instance_identifier
}
