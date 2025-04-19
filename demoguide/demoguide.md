[comment]: <> (please keep all comment items at the top of the markdown file)
[comment]: <> (please do not change the ***, as well as <div> placeholders for Note and Tip layout)
[comment]: <> (please keep the ### 1. and 2. titles as is for consistency across all demoguides)
[comment]: <> (section 1 provides a bullet list of resources + clarifying screenshots of the key resources details)
[comment]: <> (section 2 provides summarized step-by-step instructions on what to demo)


[comment]: <> (this is the section for the Note: item; please do not make any changes here)
***
### Azure LogicApps with EventHubs - ISS SpaceCenter Data

<div style="background: lightgreen; 
            font-size: 14px; 
            color: black;
            padding: 5px; 
            border: 1px solid lightgray; 
            margin: 5px;">

**Note:** Below demo steps should be used **as a guideline** for doing your own demos. Please consider contributing to add additional demo steps.
</div>

[comment]: <> (this is the section for the Tip: item; consider adding a Tip, or remove the section between <div> and </div> if there is no tip)

***
### 1. What Resources are getting deployed
<add a one-paragraph lengthy description of what the scenario is about, and what is getting deployed>

Provide a bullet list of the Resource Group and all deployed resources with name and brief functionality within the scenario. 

* rg-%azdenvironmentname - Azure Resource Group.
* EventHubsconnection - API Connection from Azure LogicApps to Event Hub
* EvHub%uniquestring& - Azure Event Hub for streaming data from ISS 
* Fabric%uniquestring% - Microsoft Fabric Capacity (F2 sku)
* LogicApp-Pause-Fabric - Azure LogicApp to pause the Fabric Capacity (to save cost; runs every 4 hours Mon-Fri)
* LogicApp-Pull-ISS - Azure LogicApp which uses GET HTTP requests to pull in the necessary data from ISS

<img src="https://raw.githubusercontent.com/petender/issdata/refs/heads/main/demoguide/ResourceGroup_Overview.png" alt="ISS Fabric Scenario - Resource Group" style="width:70%;">
<br></br>

### 2. What can I demo from this scenario after deployment

TRACKING THE INTERNATIONAL SPACE STATION WITH MICROSOFT FABRIC

## DEMO GUIDE

### Contents

#### Validate Deployed Resources

- Fabric Capacity (F2 SKU)
- Event Hub Namespace
	- Event Hub
- Logic Apps - these may not be running on creation - go into Overview of resource and select `Run` to initialize
	- Fabric Capacity Pause - pauses capacity every 4 hrs
	- ISS data transfer to Event Hub - requests data from ISS HTTPS and sends to Event Hub


#### Setting Up Real-Time Workflow

- Create a Fabric Workspace

  - Navigate to https://app.powerbi.com/

<img src="https://raw.githubusercontent.com/petender/issdata/refs/heads/main/demoguide/Fabric_Dashboard.png" alt="ISS Fabric Scenario - Dashboard" style="width:70%;">
<br></br>

- Fill in the fields (Domain not needed) - ensure that under Advanced section, that created F2 Fabric Capacity is selected

<img src="https://raw.githubusercontent.com/petender/issdata/refs/heads/main/demoguide/Create_Workspace.png" alt="ISS Create Fabric Workspace" style="width:70%;">
<br></br>

- Once you’ve built the workspace you will build an Eventhouse.

<img src="https://raw.githubusercontent.com/petender/issdata/refs/heads/main/demoguide/Create_EventHouse.png" alt="ISS Create Fabric EventHouse" style="width:70%;">
<br></br>

- Once the Eventhouse is created, it should automatically create a KQL Database - can create new DB

<img src="https://raw.githubusercontent.com/petender/issdata/refs/heads/main/demoguide/Create_KQLDatabase.png" alt="ISS Create Fabric KQL Database" style="width:70%;">
<br></br>

- Create a new Eventstream

<img src="https://raw.githubusercontent.com/petender/issdata/refs/heads/main/demoguide/Create_EventStream.png" alt="ISS Create Fabric EventStream" style="width:70%;">
<br></br>

- Now you need to connect the Eventstream to your Event Hub

<img src="https://raw.githubusercontent.com/petender/issdata/refs/heads/main/demoguide/Connect_EventStream.png" alt="ISS Connect Fabric EventStream" style="width:70%;">
<br></br>

- Your Event Hub should show up in the list for you to select.

<img src="https://raw.githubusercontent.com/petender/issdata/refs/heads/main/demoguide/Fabric_Dashboard.png" alt="ISS Connect Fabric EventStream" style="width:70%;">
<br></br>

- Configure the connection settings

<img src="https://raw.githubusercontent.com/petender/issdata/refs/heads/main/demoguide/Fabric_ConnectionSettings.png" alt="ISS Connect Fabric Connection Settings" style="width:70%;">
<br></br>

- You will need to create a new connection

<img src="https://raw.githubusercontent.com/petender/issdata/refs/heads/main/demoguide/Fabric_Connection.png" alt="ISS Connect Fabric Connection" style="width:70%;">
<br></br>

- Once you connect you will be sent to your Eventstream page, and you should see the connections and data. If data is showing up, you can now click the Publish button.

<img src="https://raw.githubusercontent.com/petender/issdata/refs/heads/main/demoguide/Fabric_EventStream.png" alt="ISS Fabric EventStream" style="width:70%;">
<br></br>


<img src="https://raw.githubusercontent.com/petender/issdata/refs/heads/main/demoguide/Fabric_EventStream2.png" alt="ISS Fabric EventStream" style="width:70%;">
<br></br>

#### Create KQL queries to analyze data

- Go back to your KQL Database to run the following queries. In order to run queries, we need to create a Table to store data from the Eventstream

<img src="https://raw.githubusercontent.com/petender/issdata/refs/heads/main/demoguide/KQL_Query.png" alt="ISS Fabric KQL Query" style="width:70%;">
<br></br>

- Give your Table a name and in the dropdown for Workspace and Eventstream select your Workspace and Eventstream

<img src="https://raw.githubusercontent.com/petender/issdata/refs/heads/main/demoguide/Fabric_CreateTable.png" alt="ISS Fabric Create Data Table" style="width:70%;">
<br></br>

- Once you select next, it may take a minute, but you should see something similar to this showing data that will be populated into your table. Select Finish.

<img src="https://raw.githubusercontent.com/petender/issdata/refs/heads/main/demoguide/DataStream.png" alt="ISS Fabric DataStream" style="width:70%;">
<br></br>

- Once this is completed, you will now see a table with the name you created with data populated (may require refresh to view)
<img src="https://raw.githubusercontent.com/petender/issdata/refs/heads/main/demoguide/DataStream_Table.png" alt="ISS Fabric DataStream Table" style="width:70%;">
<br></br>

- KQL queries

**Hint - have participants use Copilot web to get the KQL query formatted**

// 1. See how many ISS location data records there are in the table.

    tableName
    | count

// 2. Show a preview of 100 records in a table layout.

    tableName
    | take 100

// 3. Determine the timerange of the ISS location data you have in the KQL database. Hint: use unixtime_seconds_todatetime and min() max()

    tableName
    | summarize max(unixtime_seconds_todatetime(timestamp)), min(unixtime_seconds_todatetime(timestamp))

// 4. Render a map that displays the ISS trajectory for the last 100 seconds

    tableName
    | top 100 by timestamp
    | project toreal(longitude), toreal(latitude)
    | render scatterchart with (kind = map)

// 5. The International Space Station (ISS) takes approximately 90 minutes to complete one orbit around the Earth. Show this on a map.

    tableName
    | where unixtime_seconds_todatetime(timestamp) > ago(90m)
    | project toreal(longitude), toreal(latitude)
    | render scatterchart with ( kind=map )

Based on this result, participants should determine whether the ISS was visible during the last 90 minutes where they are located

#### Create a Power BI Report

#### Option 1: via PowerBI Desktop (if PBI desktop not an option, use option 2)

- If you have not already done so, Install PowerBI Desktop. Link to download https://www.microsoft.com/en-us/download/details.aspx?id=58494&msockid=08fe7a2161c263140975699c60696250

- Open up a blank report and ensure that the user is signed into PowerBI with the UID associated with Fabric

- Select `Get Data` and from `Microsoft Fabric` Select KQL database

<img src="https://raw.githubusercontent.com/petender/issdata/refs/heads/main/demoguide/Select_KQL_Database.png" alt="ISS Fabric Select KQL Database" style="width:70%;">
<br></br>

- Select the KQL DB created in the Fabric workspace

- Add a Map visual to the report page, displaying ISS location.

- In the Visualizations section select the Map Icon. On the right select the Altitude, Latitude, and Longitude options.

  - ensure that the fields aren't summarized (select dropdown from field in Visualization pane and select `Dont Summarize`)
 
<img src="https://raw.githubusercontent.com/petender/issdata/refs/heads/main/demoguide/Map_Visualization.png" alt="ISS Visualization Map" style="width:70%;">
<br></br>

- Turn on Auto Page Refresh in Power BI Desktop (even if the participant sets a low granularity, there may be an admin setting for a specified granularity - this can be viewd under the `Show Details` option in the auto-page refresh settings)

- Publish the report to your Fabric Workspace

<img src="https://raw.githubusercontent.com/petender/issdata/refs/heads/main/demoguide/Publish_to_PowerBI.png" alt="Publish to PowerBI" style="width:70%;">
<br></br>

#### Option 2: via Fabric

- Navigate to the KQL query that created the map visual

- From the UI, select `Create Power BI Report`

<img src="https://raw.githubusercontent.com/petender/issdata/refs/heads/main/demoguide/Visual_Formatting.png" alt="ISS Visualization Formatting" style="width:70%;">
<br></br>

- This will open up the visual in an editable report

- configure auto refresh as in the previous option

- Save the file (provide a Name and select the appropriate workspace)

You know have a real=time tracking app for ISS information, frequenty getting updated (5 seconds), and presenting the actual data information into an appealing dashboard using EventHub Streaming media.



[comment]: <> (this is the closing section of the demo steps. Please do not change anything here to keep the layout consistant with the other demoguides.)
<br></br>
***
<div style="background: lightgray; 
            font-size: 14px; 
            color: black;
            padding: 5px; 
            border: 1px solid lightgray; 
            margin: 5px;">

**Note:** This is the end of the current demo guide instructions.
</div>




