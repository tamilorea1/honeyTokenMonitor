# 🍯 Honeytoken Monitor

A cloud-native, deception-based intrusion detection system that alerts you the moment a fake credential is accessed — signalling a potential breach in real time. Entire infrastructure deployed with a single `terraform apply`.

---

## 🧠 What Is This Project?

Imagine leaving a clearly-labelled fake stack of bills in a corner of a bank vault. Nobody legitimate should ever touch it. The moment someone does — an alarm goes off.

That's a **honeytoken**. You create fake credentials (a decoy IAM user with an access key that has zero permissions) that look completely real but can't actually do anything. You then "leak" them somewhere believable — like a fake commit in a public GitHub repo, or a misconfigured config file.

The second someone finds and tries to use them, AWS denies the request with an `UnauthorizedOperation` error — and your system fires an alert. Since no legitimate user would ever touch those credentials, **any access attempt = a confirmed breach.**

This project can be summarized as:

> *"Helping users know when and if their credentials have been leaked — in real time."*

---

## 🔁 Core Flow

```
Attacker finds leaked decoy IAM key and tries to use it
        ↓
AWS denies the request → UnauthorizedOperation error
        ↓
CloudTrail logs the event (who, what, when, where)
        ↓
CloudWatch alarm detects the UnauthorizedOperation
        ↓
Lambda function is triggered
        ↓
SNS sends an alert to your phone/email within seconds
        ↓
DynamoDB logs the full attempt (Key ID, IP, timestamp, region, etc.)
```

---

## 🛠️ Tech Stack

### Backend
| Technology | Purpose |
|---|---|
| Node.js + TypeScript | Core API logic and trap endpoints |
| Express | HTTP server, handles incoming requests to trap routes |

### AWS Services
| Service | Purpose |
|---|---|
| IAM (Decoy User) | The honeytoken itself — a real access key with zero permissions |
| AWS CloudTrail | Audit log of every AWS API call — catches `UnauthorizedOperation` events |
| AWS CloudWatch | Monitors CloudTrail logs and triggers an alarm on any decoy key usage |
| AWS Lambda | Serverless function triggered by CloudWatch — orchestrates the response |
| AWS SNS | Sends email or SMS alert the moment a trap is triggered |
| AWS DynamoDB | Serverless-native database — logs every breach attempt with full metadata |

### DevOps
| Technology | Purpose |
|---|---|
| Terraform | Infrastructure as Code — provisions the entire AWS stack with one command |
| Docker | Containerizes the Node.js app — shows full deployment pipeline awareness |

---

## 🏗️ Build Phases

### Phase 0 — Infrastructure as Code (Terraform)

Define and provision your entire AWS stack before writing a single line of app code:

- [x] Install Terraform CLI
- [x] Write `main.tf` to provision: IAM decoy user + access key, CloudTrail trail, CloudWatch log group + alarm, Lambda function, SNS topic + email subscription, DynamoDB table
- [x] Run `terraform apply` — entire security stack spins up in one command
- [x] Store Terraform state remotely in an S3 backend

### Phase 1 — Signal (Detection Only)

Build the core detection pipeline end to end:

- [x] Set up Node.js + TypeScript + Express project
- [x] Create decoy IAM user via Terraform with an access key and an explicit `Deny *` policy
- [x] Enable CloudTrail to capture all API calls in your account
- [x] Set up CloudWatch alarm filtering for `UnauthorizedOperation` errors tied to your decoy key's ID
- [x] Write Lambda function — triggered by CloudWatch, fires SNS alert
- [x] Configure SNS topic — subscribe your email/phone number
- [x] Set up DynamoDB table — log every attempt with Key ID, IP, timestamp, AWS region, action attempted
- [x] Containerize the Express app with Docker
- [x] Test end to end: use the decoy key → confirm CloudTrail logs it → confirm you receive an alert

### Phase 2 — Response (SOAR: Security Orchestration, Automation and Response)

Add automated remediation on top of the detection layer:

- [x] **Credential deactivation** — Lambda automatically deactivates the triggered decoy key the moment it's used, cutting off further attempts with the same key. Regeneration is a deliberate manual step, not automated — a honeytoken has no live service depending on it staying active, so a human stays in the loop on resetting the trap.
- [ ] **IP blocking** — skipped. AWS WAF isn't part of the AWS Free Tier (~$5+/month per web ACL), and credential deactivation already neutralizes the compromised key, so this was deprioritized in favor of staying cost-free.
- [x] **Breach report dashboard** — a simple frontend served by Express that reads from DynamoDB and displays every confirmed incident (IAM honeytoken triggers and HTTP trap hits) with metadata and timestamps.
- [x] **HTTP trap layer** — Express endpoints (`/api/admin`, `/api/keys`, `/api/config`) that look like real internal services. Any hit logs to DynamoDB and fires an SNS alert, the same pipeline as the IAM honeytoken.

---

## 📚 Concepts This Project Demonstrates

| Concept | Where it appears |
|---|---|
| Deception-based security | Decoy IAM user honeytoken design |
| AWS Identity Management | IAM user, access key, explicit Deny policy |
| Audit logging | AWS CloudTrail capturing all API calls |
| Threat detection | CloudWatch alarm on `UnauthorizedOperation` |
| Serverless architecture | AWS Lambda |
| Event-driven design | CloudTrail → CloudWatch → Lambda → SNS pipeline |
| Serverless-native storage | DynamoDB for breach attempt logs |
| Containerization | Docker |
| Infrastructure as Code | Terraform — entire stack deployed in one command |
| SOAR (Phase 2) | Automated key deactivation + breach dashboard |
| Principle of Least Privilege | Decoy key has zero effective permissions |

---

*Built as a portfolio project to demonstrate real-world cloud security engineering concepts.*
