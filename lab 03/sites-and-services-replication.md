# Lab 03: Configure Active Directory Sites and Services

## Objective:

Properly configure Active Directory Sites and Services to reflect a multi-subnet/multi-location environment using DC01 and DC02, with routing handled by pfSense.

---

## Lab Topology Overview

* **DC01**:

  * Subnet: `192.168.16.0/24`
  * Site: `Default-First-Site-Name`
  * Network: innet
* **DC02**:

  * Subnet: `192.168.17.0/24`
  * Site: `Branch-Site`
  * Network: winnet
* **pfSense**:

  * Acts as router between intnet and winnet

---

## Step-by-Step Guide

### Step 1: Open Active Directory Sites and Services

1. Log into either DC01 or DC02.
2. Open **Active Directory Sites and Services**:

   * Run: `dssite.msc`
   * Or via: **Server Manager → Tools → Active Directory Sites and Services**

---

### Step 2: Create a New Site for DC02

1. In the left-hand pane, right-click **Sites** → **New Site**
2. Enter the name: site-dc02
3. Select **DEFAULTIPSITELINK** as the site link
4. Click **OK**

---

### Step 3: Create a New Subnet for DC02

1. Right-click **Subnets** → **New Subnet**
2. Enter DC02's subnet in CIDR format:

   * Example: `192.168.17.0/24`
3. Select the new site site-dc02
4. Click **OK**

> 💡 This maps the subnet to a site, allowing AD to locate resources properly based on IP.

---

### Step 4: Move DC02 to the New Site

1. Navigate to: **Sites → Default-First-Site-Name → Servers**
2. Right-click on `DC02` → **Move**
3. Select `Branch-Site` and confirm

> ✅ DC02 now belongs to the correct logical site in AD.

---

### Step 5: Review Replication Configuration

1. Expand: **Inter-Site Transports → IP**
2. Click on `DEFAULTIPSITELINK`
3. Configure:

   * **Replication Frequency** (e.g. every 180 mins)
   * **Cost** (e.g. lower cost for faster links)
   * **Schedule** (e.g. 24/7 or off-peak only)

---

## Verification

1. Run `Get-ADDomainController -Filter *` on DC01 or DC02 to view site placements
2. Use `repadmin /replsummary` to confirm replication status
3. Run `nslookup`, `ping`, and `dcdiag` across DCs to validate DNS and health

---

With this configuration:

* AD understands that DC01 and DC02 are in separate physical/logical sites
* AD traffic is routed intelligently via pfSense
* Replication and logon behavior follow site-aware logic

> 🎯 You’ve successfully set up a multi-site AD environment in your virtual lab!
