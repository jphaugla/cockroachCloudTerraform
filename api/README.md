## to use these API commands
cd ~/.cockroachCloud
* set the cockroach API using *source setEnv.sh*
  * this file is created using the API key and secret key from the service account 
  * [manage service accounts](https://www.cockroachlabs.com/docs/cockroachcloud/managing-access#manage-service-accounts)
* go to api subdirectory *cd api*
* Get the cluster id using *./getClusters.sh*
  * this returns the cluster id which is passed as first parameter for all the other scripts
```bash
./getClusters.sh
{
  "clusters": [
    {
      "id": "e27c1f2f-blah-474b-blah-c6bcf5817c29",
```
* retrieve information for just this cluster
```bash
./getCluster.sh e27c1f2f-blah-474b-blah-c6bcf5817c29
```
these scripts similarly use the cluster id as the first argument, *getUsers.sh, getNodes.sh, deleteCluster.sh, deleteUser.sh*.  deleteUser has a second  username paramater to choose the username to delete.

The next set of scripts user the cluster id as the first argument but they also have a .json file in the same directory holding the necessary data for the query:  *createUser.sh, changeUserPW.sh, 

*getAuditLogs.sh* only needs the API token.
*increaseNodes.sh* uses the cluster id but also has a json spec to change the node count

## Disruption API
Use the same script *disrupt.sh* but with different json file specified at the top of the script

