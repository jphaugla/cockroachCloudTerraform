# **Disruption API Workflow**

This document outlines the procedure for initiating and managing controlled disruptions in a CockroachDB Cloud cluster using scripts in the [cockroachCloudTerraform/api](https://github.com/jphaugla/cockroachCloudTerraform/tree/main/api) repository.

---

## **1. Initial Setup**

### **Create a Service Account and API Token**

Follow the official CockroachDB documentation to set up a service account and generate an API token:

🔗 [Manage Service Accounts — CockroachDB Docs](https://www.cockroachlabs.com/docs/cockroachcloud/managing-access#manage-service-accounts)

> ⚠️ **Important:** The API token is **ephemeral** and **must be saved at creation**, as it cannot be retrieved later.

### **Set the API Token Environment Variable**

1. Create a shell script (e.g., `setToken.sh`) with the following content:

   ```bash
   export COCKROACH_API_TOKEN=<your_token_here>
   ```
2. Source the script:

   ```bash
   source ./setToken.sh
   ```

> This `COCKROACH_API_TOKEN` is required for all subsequent API scripts.

---

## **2. Retrieve Cluster ID**

1. Run the cluster listing script:

   ```bash
   ./getClusters.sh
   ```
2. Identify the target cluster in the JSON output. The cluster ID is shown directly **above** the cluster name.
3. Export the ID:

   ```bash
   export CLUSTER_ID=<your_cluster_id>
   ```
4. Validate the cluster ID by running:

   ```bash
   ./getCluster.sh
   ```

> Both `COCKROACH_API_TOKEN` and `CLUSTER_ID` must be set for all scripts in the API directory.

---

## **3. Pre-Disruption Validation**

Before triggering any disruption:

* Confirm the cluster is in the **Available** state in the **CockroachCloud Console**.
* Visit the **CockroachDB Console → Overview** page to confirm all nodes are healthy and the database is operational.

---

## **4. Disruption and Restoration Process**

### **A. Node Disruption**

1. List all nodes in the cluster:

   ```bash
   ./getNodes.sh
   ```

2. Identify a node and region to target.

3. Edit `kill1node.json`:

   * Set the `node_name` and `region` fields based on the `getNodes.sh` output.

4. Disrupt the node:

   ```bash
   ./disrupt.sh kill1node.json
   ```

5. Observe the result:

   * Open the **CockroachDB Console** and confirm that the targeted node has gone down.
   * The cluster and database should remain fully operational.

6. Restore the node:

   ```bash
   ./disrupt.sh restore.json
   ```

---

### **B. Region Disruption**

1. Edit `killRegion.json` to specify the region to be taken down.
2. Disrupt the region:

   ```bash
   ./disrupt.sh killRegion.json
   ```
3. Confirm behavior in the **CockroachDB Console**.
4. Restore the region:

   ```bash
   ./disrupt.sh restore.json
   ```

---

## **Appendix A: API Script Descriptions**

| Script Name          | Description (from top comment)                                               |
| -------------------- | ---------------------------------------------------------------------------- |
| `getClusters.sh`     | Retrieves a list of all CockroachDB clusters for the service account.        |
| `getCluster.sh`      | Validates and retrieves details about the currently selected cluster.        |
| `getNodes.sh`        | Lists nodes in the cluster along with their status and region.               |
| `disrupt.sh`         | Executes a disruption using a JSON definition (kill or restore node/region). |
| `getSQLUsers.sh`     | Lists SQL users for the current cluster.                                     |
| `getSQLUser.sh`      | Fetches details for a specific SQL user.                                     |
| `deleteSQLUser.sh`   | Deletes a specified SQL user.                                                |
| `createSQLUser.sh`   | Creates a new SQL user.                                                      |
| `listClouds.sh`      | Lists cloud providers and supported regions.                                 |
| `getClusterState.sh` | Retrieves the current operational state of the cluster.                      |

---

## **Appendix B: Error Codes**

| Error Code | Message Summary                | Cause                                                                                       |
| ---------- | ------------------------------ | ------------------------------------------------------------------------------------------- |
| 14         | `concurrent operation running` | A disruption was attempted while another operation was already in progress for the cluster. |

---

Let me know if you want this converted into a publishable README, markdown doc, or PDF, or if you'd like automation added for any of these steps.

