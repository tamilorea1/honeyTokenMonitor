# Learnings

Transferable concepts from building this project, organized by week. The goal is to capture what generalizes beyond this specific project — patterns and habits worth carrying into the next one.

---

## Week 1 — Terraform Fundamentals

- **State** is Terraform's memory of what it created. Lose it, and Terraform no longer knows what exists.
- **Remote state (S3 + DynamoDB)** solves two problems: state becomes a single point of failure if it's just a local file, and DynamoDB locking prevents two people (or two `apply` runs) from corrupting state by writing simultaneously.
- **Chicken-and-egg bootstrapping**: you can't point Terraform at a backend that doesn't exist yet. Create the backend resources with local state first, then migrate.
- **`data` blocks** read or compute things without creating resources (`aws_caller_identity`, `archive_file`, `aws_iam_policy_document`). Useful any time you need information Terraform must look up rather than declare.

**Reusable elsewhere:** any IaC project needs this same bootstrapping pattern and the same state-locking discipline — not honeytoken-specific.

---

## Week 2 — Event-Driven AWS Pipelines

- **IAM has two policy types**: trust policies (who can assume a role) and permission policies (what that role can do). Every AWS service-to-service interaction (CloudTrail→CloudWatch, Lambda execution) needs both.
- **`aws_iam_role_policy` vs `aws_iam_policy`** — inline (tied to one role) vs standalone managed (needs separate attachment). Easy mistake, hard to notice until something silently lacks permissions.
- **Event chains**: CloudTrail (audit log) → CloudWatch (pattern match + alarm) → SNS (fan-out) → Lambda (compute) is a general pattern for "detect X, then react." This shape repeats constantly in cloud architecture, not just security.
- **`treat_missing_data`** and similar alarm-tuning settings matter — without them you get false positives during quiet periods.
- **Least privilege**: scope IAM resources to specific ARNs, not `"*"`, even when it's tempting to move faster.

**Reusable elsewhere:** this CloudTrail→CloudWatch→SNS→Lambda shape applies to almost any "watch for X, alert and react" system on AWS — cost anomaly detection, infrastructure drift, login anomalies, etc.

---

## Week 3 — Application Layer (Node.js / Express / Docker)

- **Service layer pattern**: routes handle HTTP concerns, services handle external system calls (DynamoDB, SNS). Keeps routes thin and logic testable/reusable.
- **Middleware** (`router.use()`) runs before route handlers — the place for cross-cutting concerns like logging, auth checks, or request enrichment.
- **`textContent` over `innerHTML`** — any time you render data that originated from an untrusted source (user input, attacker-controlled headers), avoid `innerHTML`. This is a general XSS-prevention habit, not project-specific.
- **Docker layer caching**: copying `package*.json` and running `npm ci` *before* copying source code means dependency installs are cached and only rerun when dependencies actually change.
- **Environment variables + `.env`**: keep config out of code, never commit secrets, ship a `.env.example` so others know what's required without seeing real values.

**Reusable elsewhere:** the service-layer/middleware pattern and Docker layer-caching trick apply to virtually any Node/Express project built next.

---

## Phase 2 — Automated Response (SOAR)

- **Contain before investigate**: deactivating credentials (not deleting) preserves forensic evidence while immediately cutting off access — the standard incident-response instinct.
- **Scoped IAM grants**: Lambda's new permissions were locked to one specific user ARN, not `"*"` — same least-privilege discipline as Week 2, applied again deliberately.
- **DynamoDB Scan vs Query**: Scan reads everything (fine at small scale, expensive at large scale); Query is targeted and requires a known key. Know which one is actually needed.
- **Honest scoping**: choosing to skip WAF for cost reasons, and documenting *why*, is itself a skill — every real project has tradeoffs, and being able to explain them clearly (in a README, in an interview) is as valuable as the code.
