targetScope = 'resourceGroup'

@description('Please specify a location')
param location string = resourceGroup().location

@description('Please specify the Fabric capacity administrator')
param admin string

@description('Please specify the Fabric capacity SKU')
param sku string

@description('Allocates a unique name for the Fabric capacity')
param fabricName string

@description('Allocates a unique name for the EventHub namespace')
param evhubnamespace string

@description('Allocates a unique name for the EventHub')
param evhubname string


resource fabric 'Microsoft.Fabric/capacities@2023-11-01' = {
  location: location
  name: fabricName
  properties: {
    administration: {
      members: [
        admin
      ]
    }
  }
  sku: {
    name: sku
    tier: 'Fabric'
  }
}

resource logicapp_pause_fabric 'Microsoft.Logic/workflows@2019-05-01' = {
  name: 'logicapp-pause-fabric'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    definition: {
      '$schema': 'https://schema.management.azure.com/schemas/2016-06-01/Microsoft.Logic.json'
      contentVersion: '1.0.0.0'
      parameters: {
        '$suspenduri': {
          type: 'String'
        }
        '$getdetailsuri': {
          type: 'String'
        }
      }
      triggers: {
        Every_15_minutes: {
          recurrence: {
            frequency: 'Week'
            interval: 1
            schedule: {
              hours: [
                '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23'
              ]
              minutes: [
                0, 15, 30, 45
              ]
              weekDays: [
                'Monday'
                'Tuesday'
                'Wednesday'
                'Thursday'
                'Friday'
              ]
            }
            timeZone: 'Romance Standard Time'
          }
          type: 'Recurrence'
        }
      }
      actions: {
        Condition: {
          actions: {
            Suspend: {
              runAfter: {}
              type: 'Http'
              inputs: {
                authentication: {
                  type: 'ManagedServiceIdentity'
                }
                method: 'POST'
                uri: '@parameters(\'$suspenduri\')'
              }
            }
          }
          runAfter: {
            Parse_JSON: [
              'Succeeded'
            ]
          }
          expression: {
            and: [
              {
                not: {
                  equals: [
                    '@body(\'Parse_JSON\')?[\'properties\']?[\'state\']'
                    'Paused'
                  ]
                }
              }
            ]
          }
          type: 'If'
        }
        Get_Fabric_Capacity: {
          runAfter: {}
          type: 'Http'
          inputs: {
            authentication: {
              type: 'ManagedServiceIdentity'
            }
            method: 'GET'
            uri: '@parameters(\'$getdetailsuri\')'
          }
        }
        Parse_JSON: {
          runAfter: {
            Get_Fabric_Capacity: [
              'Succeeded'
            ]
          }
          type: 'ParseJson'
          inputs: {
            content: '@body(\'Get_Fabric_Capacity\')'
            schema: {
              properties: {
                id: {
                  type: 'string'
                }
                location: {
                  type: 'string'
                }
                name: {
                  type: 'string'
                }
                properties: {
                  properties: {
                    administration: {
                      properties: {
                        members: {
                          items: {
                            type: 'string'
                          }
                          type: 'array'
                        }
                      }
                      type: 'object'
                    }
                    mode: {
                      type: 'string'
                    }
                    provisioningState: {
                      type: 'string'
                    }
                    state: {
                      type: 'string'
                    }
                  }
                  type: 'object'
                }
                sku: {
                  properties: {
                    capacity: {
                      type: 'integer'
                    }
                    name: {
                      type: 'string'
                    }
                    tier: {
                      type: 'string'
                    }
                  }
                  type: 'object'
                }
                tags: {
                  properties: {}
                  type: 'object'
                }
                type: {
                  type: 'string'
                }
              }
              type: 'object'
            }
          }
        }
      }
      outputs: {
      }
    }
    parameters: {
      '$suspenduri': {
        type: 'String'
        value: '${environment().resourceManager}subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Fabric/capacities/${fabricName}/suspend?api-version=2023-11-01'
      }
      '$getdetailsuri': {
        type: 'String'
        value: '${environment().resourceManager}subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Fabric/capacities/${fabricName}?api-version=2023-11-01'
      }
    }
  }
}

resource EventHubNameSpace 'Microsoft.EventHub/namespaces@2024-05-01-preview' = {
  name: evhubnamespace
  location: location
  sku: {
    name: 'Basic'
    tier: 'Basic'
    capacity: 1
  }
  properties: {
    geoDataReplication: {
      maxReplicationLagDurationInSeconds: 0
      locations: [
        {
          locationName: location
          roleType: 'Primary'
        }
      ]
    }
    minimumTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: false
    zoneRedundant: true
    isAutoInflateEnabled: false
    maximumThroughputUnits: 0
    kafkaEnabled: true
  }
}

resource EventHubNameSpaceRootManageSharedAccessKey 'Microsoft.EventHub/namespaces/authorizationrules@2024-05-01-preview' = {
  parent: EventHubNameSpace
  name: 'RootManageSharedAccessKey'
  properties: {
    rights: [
      'Listen'
      'Manage'
      'Send'
    ]
  }
}



resource EventHub 'Microsoft.EventHub/namespaces/eventhubs@2024-05-01-preview' = {
  parent: EventHubNameSpace
  name: evhubname
  properties: {
    messageTimestampDescription: {
      timestampType: 'LogAppend'
    }
    retentionDescription: {
      cleanupPolicy: 'Delete'
      retentionTimeInHours: 2
    }
    messageRetentionInDays: 1
    partitionCount: 1
    status: 'Active'
  }
}

resource EventHubNameSpaceNetworkrulesets 'Microsoft.EventHub/namespaces/networkrulesets@2024-05-01-preview' = {
  parent: EventHubNameSpace
  name: 'default'
  properties: {
    publicNetworkAccess: 'Enabled'
    defaultAction: 'Allow'
    virtualNetworkRules: []
    ipRules: []
    trustedServiceAccessEnabled: false
  }
}

resource apiConnection 'Microsoft.Web/connections@2016-06-01' = {
  name: 'eventhubsconnection'
  location: location 
  properties: {
    api: {
      id: subscriptionResourceId('Microsoft.Web/locations/managedApis', location, 'eventhubs')
    }
    displayName: 'logicapp_pull_iss'
    parameterValues: {
      connectionString: listkeys(resourceId('Microsoft.EventHub/namespaces/authorizationrules', EventHubNameSpace.name, 'RootManageSharedAccessKey'), '2024-05-01-preview').primaryConnectionString
    }
  
  }
  
}

resource logicapp_pull_iss 'Microsoft.Logic/workflows@2017-07-01' = {
  name: 'logicapp_pull_iss'
  location: location
  properties: {
    state: 'Enabled'
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      contentVersion: '1.0.0.0'
      parameters: {
        '$connections': {
          defaultValue: {}
          type: 'Object'
        }
      }
      triggers: {
        Recurrence: {
          recurrence: {
            interval: 5
            frequency: 'Second'
            timeZone: 'UTC'
          }
          evaluatedRecurrence: {
            interval: 5
            frequency: 'Second'
            timeZone: 'UTC'
          }
          type: 'Recurrence'
        }
      }
      actions: {
        HTTP: {
          runAfter: {}
          type: 'Http'
          inputs: {
            uri: 'https://api.wheretheiss.at/v1/satellites/25544'
            method: 'GET'
          }
          runtimeConfiguration: {
            contentTransfer: {
              transferMode: 'Chunked'
            }
          }
        }
        Send_event: {
          runAfter: {
            HTTP: [
              'Succeeded'
            ]
          }
          type: 'ApiConnection'
          inputs: {
            host: {
                connection: {
                  name: '@parameters(\'$connections\')[\'eventhubs\'][\'connectionId\']'
                }
            }
            method: 'post'
            body: {
              ContentData: '@base64(body(\'HTTP\'))'
            }
            path: '/@{encodeURIComponent(\'${EventHub.name}\')}/events'
          }
        }
      }
      outputs: {}
    }
    parameters: {
       '$connections': {
        value: {
          eventhubs: {
            id: subscriptionResourceId('Microsoft.Web/locations/managedApis', location, 'eventhubs')
            connectionId: apiConnection.id 
            connectionName: 'eventhubs'
          }
        }
       }
    }
  }
}
  

// add a new resource to assign Contributor permissions to the Resource Group, which allows Logic App to access the Fabric resource
resource LogicAppRBAC 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(concat(resourceGroup().id), logicapp_pause_fabric.id, 'b24988ac-6180-42a0-ab88-20f7382dd24c')
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c') // contributor
    principalId: reference(logicapp_pause_fabric.id, '2017-07-01', 'full').identity.principalId
    scope: resourceGroup().id
    principalType: 'ServicePrincipal'
  }
}

output fabricId string = fabric.id
output fabricName string = fabric.name
output logicappid string = logicapp_pause_fabric.id
output logicappname string = logicapp_pause_fabric.name
