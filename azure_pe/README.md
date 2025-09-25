# Azure Private Endpoint for CockroachDB — README

This mini toolkit creates and wires up an **Azure Private Endpoint (PE)** to a CockroachDB Cloud **Private Link Service (PLS)**, then configures **Private DNS** so your clients reach CockroachDB over **private IP**.

> **Quick path:** `source setEnv.sh` → `./createEndpoint.sh` → paste the printed **PE resource ID** into the CockroachDB Cloud UI → once approved, run `./dns_setup.sh` → update `addArecord.sh` with the PE IP and run it.

---

## Prerequisites

* **Azure CLI** installed and logged in: `az login`
* Sufficient RBAC on the target resource group / VNet:

  * *Network Contributor* on the VNet/Subnet
  * *Contributor* on the Resource Group (for PE and NIC)
  * *Private DNS Zone Contributor* (for DNS zone + links)
* A CockroachDB Cloud cluster with **Private Link** enabled (you’ll paste your PE resource ID into the CockroachDB UI for validation/approval).
* **Bash** shell (`set -euo pipefail` compatible)

Optional but handy: `jq` for pretty JSON.

---

## Files in this folder

* **`setEnv.sh`** — Centralized environment variables for resource names and CRDB Cloud values.
* **`createEndpoint.sh`** — Creates the Private Endpoint in your VNet/subnet and prints its **resource ID**.
* **`dns_setup.sh`** — Creates the Private DNS zone, links it to your VNet, and attaches a DNS zone group to the PE.
* **`addArecord.sh`** — Adds an apex **A record** ("@") in your private zone pointing to the PE’s **private IP**.
* **`someStatus.sh`** — Quick status queries for the PE connection state.

> The repo also includes a helper snippet (embedded in `dns_setup.sh`) that demonstrates how to find the PE’s **NIC** and **private IP** if you need it programmatically.

---

## 1) Configure environment

Edit `setEnv.sh` as needed. Then **source it** in your shell:

```bash
source ./setEnv.sh
# Optional: confirm values
env | egrep '^(RG|LOC|VNET|SUBNET|CRDB_|PE_|DNS_|ZONE_)='
```

**What the variables mean:**

* `RG`, `LOC`, `VNET`, `SUBNET` — where to create the PE and DNS artifacts
* `CRDB_PLS_ID` — Azure resource ID of the **CockroachDB Private Link Service** (from CockroachDB Cloud)
* `CRDB_INTERNAL_DNS` — your private DNS zone name for the cluster, e.g. `internal-byoc-<...>.azure-<region>.crdb.io`
* `PE_NAME`, `PE_CONN_NAME`, `DNS_LINK_NAME`, `ZONE_GROUP_NAME` — names for new Azure resources this toolkit creates

> Ensure your current subscription is correct: `az account show` (switch with `az account set -s <SUBSCRIPTION_ID>`)

---

## 2) Create the Private Endpoint

Run:

```bash
./createEndpoint.sh
```

This script:

1. **Enables** Private Endpoint network policies on the subnet (required)
2. **Creates** a PE to the CockroachDB PLS (manual request)
3. **Prints** the PE resource ID

**Action required:** Copy the printed **resource ID** and paste it into the **CockroachDB Cloud** UI (Private Link → Validate/Approve). CockroachDB will validate and **approve** your PE request.

> You can track the PE connection state with:
>
> ```bash
> ./someStatus.sh
> ```

Expect `status: { status: "Approved" or "Succeeded" }` once CockroachDB approves.

---

## 3) Configure Private DNS

After approval (and once the NIC/private IP is assigned):

```bash
./dns_setup.sh
```

This will:

* Create the Private DNS **zone**: `${CRDB_INTERNAL_DNS}`
* **Link** it to your VNet (non-registering link)
* Create a **DNS zone group** on the PE

### Capture the PE’s private IP

You can fetch the private IP like this (shown in the repo as a helper):

```bash
# Get the NIC attached to the PE
PE_NIC_ID=$(az network private-endpoint show -g "$RG" -n "$PE_NAME" --query 'networkInterfaces[0].id' -o tsv)
# Try primary IP from NIC
PE_IP=$(az network nic show --ids "$PE_NIC_ID" \
  --query "ipConfigurations[?primary].privateIPAddress | [0]" -o tsv)
# Fallback via PE custom DNS configs if needed
[[ -z "$PE_IP" || "$PE_IP" == "null" ]] && \
  PE_IP=$(az network private-endpoint show -g "$RG" -n "$PE_NAME" \
    --query "customDnsConfigs[0].ipAddresses[0]" -o tsv)

echo "PE_IP=$PE_IP"
```

---

## 4) Add the A record (zone apex → PE IP)

Update **`addArecord.sh`** with the `PE_IP` you just discovered (it sets `PE_IP="..."` at the top). Then run:

```bash
./addArecord.sh
```

The script is idempotent: if the IP is already present, it won’t add it again. The record created is:

```
@.${CRDB_INTERNAL_DNS}  A  PE_IP
```

> If you prefer not to edit the file, you can patch it inline:
>
> ```bash
> sed -i.bak "s/^PE_IP=.*/PE_IP=\"$PE_IP\"/" addArecord.sh
> ./addArecord.sh
> ```

---

## 5) Validate resolution & connectivity

From a VM **inside** the linked VNet/subnet (or anything that uses that VNet’s resolver):

```bash
nslookup ${CRDB_INTERNAL_DNS}
# or
dig ${CRDB_INTERNAL_DNS} +short
```

You should see the **private IP** you added. Application traffic to your CockroachDB Cloud endpoints will now traverse the **Private Endpoint**.

---

## Status & troubleshooting

### Check PE connection state

```bash
./someStatus.sh
```

Look for `status: Approved` (request approved) and `description: "Connection approved"`. If it’s still `Pending`, make sure you pasted the **PE resource ID** into the CockroachDB Cloud UI and completed validation.

### No private IP yet

* Give Azure a minute after approval; then re-run the IP helper commands
* Confirm the PE’s NIC exists: `az network nic show --ids "$PE_NIC_ID"`

### Permission errors

* Ensure your identity has **Network Contributor** on the VNet/Subnet, **Contributor** on the resource group, and **Private DNS Zone Contributor** on the zone’s RG.

### Different region

* `LOC` (in `setEnv.sh`) should match your VNet region; the PLS can be in a compatible region as exposed by CockroachDB Cloud.

---

## Cleanup (optional)

Remove the resources created by these scripts:

```bash
# Delete the A record (if you want to keep the zone)
az network private-dns record-set a remove-record \
  -g "$RG" -z "$CRDB_INTERNAL_DNS" -n "@" --ipv4-address "$PE_IP" --yes

# Delete the DNS zone group and PE
a z network private-endpoint dns-zone-group delete -g "$RG" --endpoint-name "$PE_NAME" -n "$ZONE_GROUP_NAME" --yes
az network private-endpoint delete -g "$RG" -n "$PE_NAME"

# Delete the DNS link and zone
az network private-dns link vnet delete -g "$RG" --zone-name "$CRDB_INTERNAL_DNS" -n "$DNS_LINK_NAME" --yes
az network private-dns zone delete -g "$RG" -n "$CRDB_INTERNAL_DNS" --yes
```

---

## Notes

* Scripts are written to be **idempotent** where practical and will no-op if resources already exist.
* `createEndpoint.sh` uses `--manual-request true`; approval happens in **CockroachDB Cloud**.
* `addArecord.sh` targets the **zone apex** (`@`). If you need per-host records (e.g., `sql.<zone>`), adapt the `-n` argument accordingly.

---

## TL;DR commands

```bash
# 0) Login and set subscription (if needed)
az login
az account set -s <SUBSCRIPTION_ID>

# 1) Env
source ./setEnv.sh

# 2) Create PE & copy printed resource ID into CockroachDB UI
./createEndpoint.sh

# 3) After approval: DNS
./dns_setup.sh

# 4) Get PE IP and add A record
# (use the helper snippet to discover PE_IP), then:
sed -i.bak "s/^PE_IP=.*/PE_IP=\"$PE_IP\"/" addArecord.sh
./addArecord.sh

# 5) Verify
./someStatus.sh
nslookup ${CRDB_INTERNAL_DNS}
```
