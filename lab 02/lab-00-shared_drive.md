# 🗂️ Creating a Shared Drive for the Marketing Team on Domain Controller

This guide documents the **manual steps** taken to create a department-specific shared drive on a Windows Server Domain Controller, with access restricted to only the Marketing team.

---

## 📌 Objective

To create a shared folder (`E:\MarketingShare`) that is accessible **only by users in the Marketing department** through proper Active Directory group management, NTFS and Share permissions.

---

## 🧰 Environment

- **OS**: Windows Server 2019 (Domain Controller)
- **Role**: Active Directory Domain Services (AD DS)
- **Target Path**: `E:\MarketingShare`
- **Goal**: Restrict access to the `Marketing` security group only

---

## 🔧 Steps Taken

### 1. ✅ Create the Folder

- Logged into the **Domain Controller**.
- Opened **File Explorer**.
- Created a new folder at:  
  `E:\MarketingShare`

---

### 2. ✅ Create the Marketing Security Group

- Opened **Active Directory Users and Computers**.
- Navigated to the desired **Organizational Unit (OU)**.
- Right-clicked > **New > Group**.
  - **Group Name**: `Marketing`
  - **Group Scope**: Global
  - **Group Type**: Security
- Added all relevant users to the `Marketing` group.

---

### 3. ✅ Set Share Permissions

- Right-clicked the folder > **Properties > Sharing > Advanced Sharing**.
- Checked **“Share this folder”**.
- Set the **Share Name**: `Marketing`.
- Clicked **Permissions**:
  - Removed `Everyone`.
  - Added `Marketing` group with **Full Control**.

---

### 4. ✅ Set NTFS (Security) Permissions

- Switched to the **Security** tab.
- Clicked **Edit**.
- Removed inherited permissions (as needed).
- Added the `Marketing` group.
- Granted **Modify** or **Read/Write** access.
- Verified `Administrators` and `SYSTEM` retained **Full Control**.

---

### 5. ✅ Test Access

- Logged in as a **Marketing user** on a domain-joined workstation.
- Accessed the share via:  
  `\\<DC-Hostname>\Marketing`
- Verified that access was granted.
- Logged in as a **non-Marketing user** — access was **denied**, as expected.

---

## 🧠 Notes

- NTFS permissions **take precedence** over Share permissions.
- Using AD security groups instead of individual users ensures **scalability and easier management**.
- For enterprise environments, this structure supports compliance with **least privilege** principles.

---

## 📌 Next Steps (Optional)

- Map this shared folder via **Group Policy Preferences** using Drive Maps.
- Automate this process using our accompanying [PowerShell script](../scripts/create-marketing-share.ps1).
- Enable **auditing** for sensitive folders to monitor access.

---

## 🧾 Author

Created by [Your Name]  
Windows Server | Active Directory Lab Practice  
📍 Nigeria
