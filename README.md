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

## 💰 Cost Breakdown

| Service | Free? | Notes |
|---|---|---|
| Node.js / TypeScript / Express | ✅ Free | Open source |
| AWS IAM | ✅ Free | No cost for users or access keys |
| AWS CloudTrail | ✅ Free tier | One trail free per region |
| AWS CloudWatch | ✅ Free tier | Basic monitoring and alarms included |
| AWS Lambda | ✅ Free tier | 1M requests/month |
| AWS SNS | ✅ Free tier | 1,000 email notifications/month |
| AWS DynamoDB | ✅ Free tier | 25GB storage, 25 read/write capacity units |
| Terraform | ✅ Free | Open source CLI |
| Docker | ✅ Free | Docker Desktop free for personal use |

**Total estimated monthly cost: $0.00**

> Swapping MongoDB for DynamoDB removes the one external dependency — everything lives natively in AWS.

---

## 🏗️ Build Phases

### Phase 0 — Infrastructure as Code (Terraform)

Define and provision your entire AWS stack before writing a single line of app code:

- [ ] Install Terraform CLI
- [ ] Write `main.tf` to provision: IAM decoy user + access key, CloudTrail trail, CloudWatch log group + alarm, Lambda function, SNS topic + email subscription, DynamoDB table
- [ ] Run `terraform apply` — entire security stack spins up in one command
- [ ] Store Terraform state remotely in an S3 backend (optional but good practice)

### Phase 1 — Signal (Detection Only)

Build the core detection pipeline end to end:

- [ ] Set up Node.js + TypeScript + Express project
- [ ] Create decoy IAM user via Terraform with an access key and an explicit `Deny *` policy
- [ ] Enable CloudTrail to capture all API calls in your account
- [ ] Set up CloudWatch alarm filtering for `UnauthorizedOperation` errors tied to your decoy key's ID
- [ ] Write Lambda function — triggered by CloudWatch, fires SNS alert
- [ ] Configure SNS topic — subscribe your email/phone number
- [ ] Set up DynamoDB table — log every attempt with Key ID, IP, timestamp, AWS region, action attempted
- [ ] Containerize the Express app with Docker
- [ ] Test end to end: use the decoy key → confirm CloudTrail logs it → confirm you receive an alert

### Phase 2 — Response (SOAR: Security Orchestration, Automation and Response)

Add automated remediation on top of the detection layer:

- [ ] **Credential rotation** — Lambda automatically deactivates the triggered decoy key and generates a fresh one, cutting off further attempts with the same key
- [ ] **IP blocking** — update an AWS WAF (Web Application Firewall) rule to blacklist the offending IP address automatically
- [ ] **Breach report dashboard** — a simple frontend that reads from DynamoDB and displays confirmed breach attempts with metadata, severity tags, and timestamps

---

## 🎤 How to Talk About This in Interviews

### If you've only built Phase 1 (signals):
> *"The project focuses on detection — the philosophy being that fast, reliable alerting gives security teams the information they need to respond appropriately. Automated remediation without human review can sometimes cause more damage than the attack itself."*

### If you've completed Phase 2 (SOAR):
> *"I implemented automated response using Lambda — when a honeytoken is accessed, the system deactivates the compromised key and blacklists the IP automatically, reducing response time to near zero. This is a lightweight SOAR system — Security Orchestration, Automation and Response."*

### On Terraform specifically:
> *"I provisioned the entire security stack — IAM roles, CloudTrail, CloudWatch alarms, Lambda, SNS, and DynamoDB — with a single `terraform apply`. This means the whole project is reproducible, version-controlled, and deployable in any AWS account in minutes."*

### Key concepts to name-drop:
- **Honeytoken / Deception-based detection** — you think like an attacker, not just a developer
- **Zero legitimate access** — any usage of a honeytoken is by definition malicious
- **UnauthorizedOperation** — the specific CloudTrail signal this project monitors for
- **Principle of Least Privilege** — the decoy IAM key has an explicit `Deny *` policy, so it literally cannot do anything even if someone grabs it
- **SOAR** — automated response, not just alerting
- **Infrastructure as Code** — entire stack is version-controlled and reproducible
- **AWS Shared Responsibility Model** — you understand what AWS secures vs. what you're responsible for
- **Cloud-native architecture** — DynamoDB + Lambda + CloudWatch all scale automatically with zero server management

---

## 📁 Suggested Project Structure

```
honeytoken-monitor/
├── src/
│   ├── app.ts                  # Express app entry point
│   ├── routes/
│   │   └── trap.ts             # Trap endpoints
│   └── services/
│       ├── dynamodb.ts         # DynamoDB logging service
│       ├── cloudwatch.ts       # CloudWatch interactions
│       └── sns.ts              # SNS notification logic
├── lambda/
│   └── alertHandler.ts         # Lambda function — triggered by CloudWatch
├── infra/
│   ├── main.tf                 # Core Terraform config
│   ├── variables.tf            # Input variables
│   ├── outputs.tf              # Output values (e.g. SNS ARN, table name)
│   └── backend.tf              # Remote state config (S3)
├── docker/
│   └── Dockerfile
├── .env.example                # Example env vars (never commit real .env)
├── package.json
└── README.md
```

---

## 🔐 Environment Variables

Never commit real credentials. Use a `.env` file locally and AWS environment variables in production.

```env
# AWS
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key

# DynamoDB
DYNAMODB_TABLE_NAME=honeytoken-access-logs

# SNS
SNS_TOPIC_ARN=arn:aws:sns:us-east-1:...

# App
PORT=3000
```

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
| SOAR (Phase 2) | Automated key deactivation + IP blocking |
| Principle of Least Privilege | Decoy key has zero effective permissions |

---

*Built as a portfolio project to demonstrate real-world cloud security engineering concepts.*
