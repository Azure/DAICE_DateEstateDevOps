# Data Estate DevOps

This repository provides sample code and instructions for creating a DevOps pipeline for Azure Data Factory, a SQL database project, and Databricks Notebooks.  Included in this repo are:

* Infrastructure (ARM Templates) for Azure resources supporting a set of ETL jobs.
* Azure Data Factory Resources including pipelines, linked services, datasets, etc.
* A sample databricks notebook
* A sample SQL Database solution for SQL Server Data Tools

## Table of Contents

## Instructions

### SQL Build Pipeline

The SQL Build Pipeline will create a SQL Data-Tier Application file that can be deployed to your Azure SQL DB.  The solution file is generated using SQL Data Tools in Visual Studio.

**Steps:**

* Create a new Build pipeline.
* Select "Classic Editor"
* Select Azure Repos Git and choose the appropriate Team Project and repository name.
  * Default branch should be master.
* Select Empty Job
* Add the "MSBuild" Task to Agent job 1
  * Set Project to `sqldb/etldb/etldb.sln`
  * Leave all other fields as default.
* Add Copy Files task to Agent job 1 after the MSBuild task.
  * Change Source Folder to `$(agent.builddirectory)\s`
  * Change Contents to `**\bin\**`
  * Change Target Folder to `$(build.artifactstagingdirectory)`
* Add Publish Build Artifacts after the Copy Files task
  * Change Artifact Name to `DBDeployment`
* Save & Queue and you have a succesful build process for your Data-Tier Application!

### Release Data Estate Infrastructure

This release pipeline will deploy the necessary resources to have a working ETL pipeline.  Including Azure Data Factory, Databricks, SQL DB, Storage Accounts, Key Vault, and several secrets created automatically.  The secrets are: 
* sqlconnstr - the SQL connection string using admin name and password.
* datastoragekey - the Primary Key from the data storage account that would house your landed data.

**Steps:**

* Create an Artifact from the Azure DevOps git repo and name it `_infrastructure`.
* Create three stages: Dev, QA, Prod
* Create variables for each stage
  * **RG_Name**: The resource group name for each stage.
  * **SQLADMINPWD**: The SQL admin password.  Should be set as a secure string.
* Each stage has one task, a Resource Group Deployment task
  * Select and Authenticate your Azure Subscription (this creates a Service Principal).
  * Action: Create or update resource group
  * Resource Group: `$(RG_NAME)`
  * Location: Your location of choice
  * Template: `$(System.DefaultWorkingDirectory)/_infrastructure/azuredeploy.json`
  * Deployment Mode: `Incremental`
  * "Override template parameters" for each task with something similar to:
    * objectId is a guid for a service principal you must create in advance (see [manual Steps](#manual-steps))

```
-factoryNameRoot "DevFactory" 
-databricksNameRoot "DevDatabricks" 
-databricksManagedRoot "DevDatabricksRG" 
-keyVaultNameRoot "DevKV" 
-dataStorageNameRoot "DevDataSA" 
-serverNameRoot "DevSQL" 
-storageNameRoot "DevSQLSA" 
-objectId "xxx-xxx-xxxx-xxxx-xxxxx" 
-administratorLogin "admin" 
-administratorLoginPassword "$(SQLADMINPWD)" 
-location "westus2"
```

* Save and Create a Release to deploy to the specified resource groups.


### Release ADF Pipeline, SQL, and Databricks


### Manual Steps
* Creating a Service Principal to pass into infrastructure deployment.
  * You will need to create a service principal that gives access to your Key Vault to create secrets.
  * Note the **Object Id** rather than the application id.
* Creating an **Azure Databricks API** token must be completed manually.
  * Follow the [Azure Databricks Instructions](https://docs.microsoft.com/en-us/azure/databricks/dev-tools/api/latest/authentication)
  * Add that token as a secret to your Key Vault for the appropriate stage.
  * Name the secret `databricks-access-token`.
  * Repeat for each Databricks Workspace and each Key Vault.