resource "azurerm_resource_group" "rg" {
  name     = var.rg_shared_name
  location = var.deploy_location
}

# Creates Log Anaylytics Workspace

resource "azurerm_log_analytics_workspace" "law" {
  name                = var.workspacename
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Creates App Service plan

resource "azurerm_service_plan" "appserviceplan" {
  name                = "app-serviceplam1983634"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "B1"
}

# Create the web app, pass in the App Service Plan ID
resource "azurerm_linux_web_app" "webapp" {
  name                  = var.webappname
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  service_plan_id       = azurerm_service_plan.appserviceplan.id
  https_only            = true
  site_config { 
    minimum_tls_version = "1.2"
  }
}

#  Deploy code from a public GitHub repo
resource "azurerm_app_service_source_control" "sourcecontrol" {
  app_id             = azurerm_linux_web_app.webapp.id
  repo_url           = "https://github.com:Azure-Samples/app-service-web-nodejs-manage"
  branch             = "master"
  use_manual_integration = true
  use_mercurial      = false
}
