Lab 01 – Fine-Grained Password Policy (FGPP) using ADAC

Objective

To apply different password policies to specific groups or users using Active Directory Administrative Center (ADAC) and verify their effect with PowerShell.
So I had to create dummy users and O/Us for this specific purpose.

---
Lab Setup
- Domain Functional Level: Windows Server 2019
- Tools Required:
  - Active Directory Administrative Center (ADAC) (GUI). N.b It can be done in powershell too.
  - PowerShell
- Account: Administrator
---

 Theory

Group Policy Management Console (GPMC) controls domain-level password policy, but it cannot target specific users or groups. So the general policy that had been created in a different lab(will do a breakdown soon)
It will apply to the entire domain. To be more specific to various O/Us we create groups, add members and apply FGPP.
To achieve granular password enforcement, you must use Fine-Grained Password Policies (FGPP), stored in the Password Settings Container within ADAC.
FGPPs override the domain password policy but only apply to direct users or group memberships (not OUs).
---
 🪟 Steps in ADAC

1️⃣ Open ADAC
- Run `dsac.exe` from Run (`Win + R`) or via Server Manager → Tools → ADAC.
---
2️⃣ Navigate to Password Settings Container
- Click your domain name on the left.
- Scroll → Click `System` → then `Password Settings Container`.
---
3️⃣ Create a New Password Policy
Click "New" > "Password Settings" and fill as:

| Setting                  | Value                |
|--------------------------|----------------------|
| Name                     | *ExecPolicy*          |
| Precedence               | 1                    |
| Minimum password length  | 16                   |
| Maximum password age     | 365 days             |
| Password history         | 24 passwords         |
| Complexity enabled       | Yes                  |
| Reversible encryption    | No                   |
| Lockout duration         | 30 minutes           |
| Lockout threshold        | 5 attempts           |
| Observation window       | 30 minutes           |

Click OK to save.
N.B. You can change this as much as you want. Ensure that precedence is 1 as the higher preference is usually picked when there are multiple policies.
---
4️⃣ Apply Policy to a Group
- Right-click your new policy → Add Applies To
- Select a group (e.g., `HR`)

Apply FGPP to security groups, not individual users.
---
We can verify using Powershell with this command.

Get-ADUserResultantPasswordPolicy -Identity someuser
