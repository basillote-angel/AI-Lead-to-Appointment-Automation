# Milestone 12 --- Security

## 12.0 Security

**Status:** 🔵 NEXT IMPLEMENTATION

**Goal:** Harden the Voryn AI Lead-to-Appointment Automation against
credential exposure, unauthorized webhook access, excessive data
exposure, insecure logs, database access, accidental secret leakage, and
unsafe backups.

**Deliverable:** Security Checklist and Hardened Configuration.

------------------------------------------------------------------------

## 1. Milestone Objective

Milestone 12 is the security layer after Error Handling and Reliability.

The project already has:

-   n8n Lead Intake workflow
-   Webhook-based lead capture
-   Supabase lead storage
-   Gemini AI analysis
-   Calendly appointment processing
-   Google Calendar integration
-   Gmail notifications and customer emails
-   Reminder processing
-   Error Handler workflow
-   Persistent `automation_error_logs` table
-   Retry and error notification behavior

The master project plan defines Milestone 12 around protecting API keys,
OAuth credentials, webhook secrets, client information, database
credentials, environment configuration, access control, webhooks, logs,
GitHub exposure, and backups. The deliverable is a security checklist
and hardened configuration.

------------------------------------------------------------------------

## 2. Current Voryn Security Surface

The current workflow contains a `Receive Lead` webhook using the path:

``` text
voryn-lead
```

The workflow validates and normalizes incoming lead information before
inserting it into the Supabase `leads` table.

It also contains Gemini analysis, Supabase storage/update operations,
Calendly event processing, Google Calendar processing, customer/internal
email notifications, follow-up logic, and reminder processing.

These components handle both business data and external credentials.

------------------------------------------------------------------------

## 3. Security Principles

### Rule 1 --- Never hard-code secrets

Never place these directly inside Code nodes, expressions, prompts,
email bodies, URLs, notes, or exported documentation:

-   API keys
-   OAuth access tokens
-   OAuth refresh tokens
-   passwords
-   Supabase service-role keys
-   webhook signing secrets
-   Gemini API keys
-   Gmail passwords
-   Calendly tokens

Use n8n credentials or appropriate secret/environment storage.

### Rule 2 --- Never log secrets

`automation_error_logs` must never contain:

-   API keys
-   OAuth tokens
-   passwords
-   webhook secrets
-   authorization headers
-   credential objects

Keep error messages safe and useful.

### Rule 3 --- Minimize customer data

The workflow handles information such as:

-   name
-   email
-   phone
-   company
-   service
-   budget
-   timeline
-   message
-   appointment information

Only store and transmit information required for the automation.

### Rule 4 --- Keep credentials inside credential systems

The workflow JSON contains credential references for integrations such
as Supabase and Gemini. The actual secret values must remain inside the
credential system and must never be copied into the workflow code.

------------------------------------------------------------------------

# 4. M12.1 --- Credential Security

## Objective

Review every external credential used by Voryn.

  -----------------------------------------------------------------------
  Service                 Purpose                 Security action
  ----------------------- ----------------------- -----------------------
  Supabase                Lead database and error Verify credential
                          logging                 storage

  Google Gemini           Lead analysis/AI        Verify credential
                                                  storage

  Calendly                Appointment/event data  Verify credential
                                                  storage

  Google Calendar         Calendar operations     Verify credential
                                                  storage

  Gmail                   Notifications/emails    Verify credential
                                                  storage

  n8n                     Workflow execution      Review account access
  -----------------------------------------------------------------------

### Checklist

-   [ ] Credential is stored in n8n's credential mechanism.
-   [ ] Secret is not hard-coded in a Code node.
-   [ ] Secret is not inside an expression.
-   [ ] Secret is not inside an email body.
-   [ ] Secret is not inside a workflow note.
-   [ ] Secret is not committed to GitHub.
-   [ ] Screenshots do not expose secret values.
-   [ ] Development and production credentials are separated when
    production is introduced.

**Never send actual credential values in project documentation.**

------------------------------------------------------------------------

# 5. M12.2 --- n8n Access Control

The project is currently being developed in a local n8n environment.

Review:

-   [ ] n8n account access
-   [ ] computer/server access
-   [ ] workflow edit permissions
-   [ ] credential access
-   [ ] shared-user access
-   [ ] exported workflow handling

Only authorized users should be able to modify the automation or access
its credentials.

------------------------------------------------------------------------

# 6. M12.3 --- Webhook Security

The public entry point is:

``` text
Receive Lead
        ↓
POST /voryn-lead
```

The existing workflow already validates:

-   name
-   email
-   email format
-   message
-   allowed service values

This is good input validation, but validation alone is not
authentication.

### Security checklist

-   [ ] Decide whether the webhook should be public or authenticated.
-   [ ] Use appropriate webhook authentication/signing if required.
-   [ ] Do not place a secret in browser-visible frontend code.
-   [ ] Reject malformed requests.
-   [ ] Restrict unnecessary fields.
-   [ ] Consider request-size limits.
-   [ ] Monitor abnormal request volume.
-   [ ] Keep duplicate protection active.

------------------------------------------------------------------------

# 7. M12.4 --- Input Security

Keep the existing `Validate & Normalize` step before database insertion.

The workflow already validates required information and allowed service
values.

Review whether additional limits are appropriate for:

-   name length
-   company length
-   message length
-   budget length
-   timeline length
-   unexpected objects/arrays
-   null/undefined values

The goal is to reject malformed or abusive input without destroying
legitimate customer information.

------------------------------------------------------------------------

# 8. M12.5 --- Supabase Database Security

The project uses:

``` text
leads
automation_error_logs
```

### Review

-   [ ] Supabase credentials are protected.
-   [ ] Credentials are not exposed to the frontend.
-   [ ] Row Level Security (RLS) has been reviewed.
-   [ ] `leads` read access is restricted.
-   [ ] `leads` write/update access is restricted.
-   [ ] `automation_error_logs` read access is restricted.
-   [ ] `automation_error_logs` write access is restricted.
-   [ ] Error logs are not publicly accessible.
-   [ ] The n8n credential has only the access required by the
    automation.

**Do not change RLS blindly.** First inspect the current policies and
understand how n8n accesses Supabase. A policy change can break the
working automation.

------------------------------------------------------------------------

# 9. M12.6 --- Error Log Security

The current table is:

``` text
automation_error_logs
```

with fields such as:

``` text
id
workflow_name
execution_id
last_node
error_category
error_code
error_message
occurred_at
retry_count
status
created_at
```

The logging system was tested during M11.

### Requirements

The error log must not become a secret-storage system.

Never put the following into `error_message`:

-   API keys
-   OAuth tokens
-   passwords
-   webhook secrets
-   authorization headers
-   full credential objects

The safe error-message approach from M11 must remain in place.

------------------------------------------------------------------------

# 10. M12.7 --- Gemini / AI Security

The workflow uses:

``` text
Analyze Lead (Gemini)
```

The current prompt sends lead information such as:

-   name
-   company
-   service
-   budget
-   timeline
-   message

### Security rules

-   [ ] Send only information Gemini needs.
-   [ ] Do not send credentials.
-   [ ] Do not send API keys.
-   [ ] Do not send database credentials.
-   [ ] Do not send webhook secrets.
-   [ ] Do not send unrelated private data.
-   [ ] Keep deterministic validation in n8n.
-   [ ] Do not treat AI output as a security control.

The workflow already has a `Parse AI Result` node that validates the
returned JSON. Keep that deterministic validation.

------------------------------------------------------------------------

# 11. M12.8 --- Calendly and Google Calendar Security

Appointment processing uses Calendly and Google Calendar data.

### Checklist

-   [ ] Calendly credential is protected.
-   [ ] Google Calendar credential is protected.
-   [ ] Provider tokens are never exposed.
-   [ ] Calendar credentials are never placed in Code nodes.
-   [ ] Event data is only sent where needed.
-   [ ] Appointment state is based on verified provider data.
-   [ ] Customer-submitted appointment information is not blindly
    trusted.

------------------------------------------------------------------------

# 12. M12.9 --- Email Security

The workflow sends:

-   internal team notifications
-   customer confirmations
-   follow-ups
-   reminders
-   error alerts

### Customer emails

Only send information necessary for the customer.

Do not expose:

-   internal errors
-   execution IDs
-   database details
-   API credentials
-   workflow debugging information

### Internal error alerts

Internal alerts may contain:

-   workflow name
-   execution ID
-   failed node
-   safe error message
-   timestamp
-   retry count
-   status

They must not contain secrets.

------------------------------------------------------------------------

# 13. M12.10 --- Workflow Data Exposure

Review expressions using:

``` text
$json
```

and cross-node references.

Avoid sending a complete object when only one field is required.

Prefer:

``` javascript
{{ $json.email }}
```

over passing an entire customer object when only the email is needed.

Review especially:

-   email nodes
-   Gemini prompts
-   error logging
-   HTTP/API nodes
-   calendar nodes
-   webhook responses

------------------------------------------------------------------------

# 14. M12.11 --- GitHub and Workflow Export Security

Before publishing workflow JSON or project files, search for:

``` text
apiKey
api_key
token
access_token
refresh_token
password
secret
authorization
Bearer
```

Also inspect:

-   `.env`
-   workflow exports
-   SQL files
-   README files
-   screenshots
-   configuration files
-   backup archives

### If a real secret is exposed

1.  Revoke/rotate it.
2.  Remove it from the public location.
3.  Check repository history.
4.  Replace the credential.
5.  Test the integration again.

Removing a secret from the latest file is not enough if it was already
committed to a public Git history.

------------------------------------------------------------------------

# 15. M12.12 --- Environment Variables

For local development:

-   [ ] Keep secrets outside source code.
-   [ ] Protect `.env` files.
-   [ ] Add `.env` to `.gitignore`.
-   [ ] Never upload `.env`.
-   [ ] Never put real credentials in documentation.

Recommended patterns where applicable:

``` text
.env
.env.*
!.env.example
.n8n/
*.log
```

Use only patterns that match the actual project structure.

------------------------------------------------------------------------

# 16. M12.13 --- Backup Security

Back up:

-   workflow definitions
-   SQL/schema definitions
-   documentation
-   configuration instructions

Do not casually back up raw credentials.

### Backup checklist

-   [ ] Workflow JSON backed up
-   [ ] Supabase schema/SQL backed up
-   [ ] Documentation backed up
-   [ ] Credentials excluded
-   [ ] Backup location access restricted
-   [ ] Restore process documented

------------------------------------------------------------------------

# 17. M12.14 --- Security Test Cases

## Test A --- Invalid webhook

Send:

``` json
{
  "email": "not-an-email"
}
```

Expected:

-   validation rejects the request
-   invalid lead is not stored
-   no customer email is sent
-   safe validation/error information is produced

## Test B --- Missing required data

Remove `name` or `message`.

Expected:

-   validation fails
-   lead is not incorrectly processed
-   customer message is not sent

## Test C --- Secret exposure scan

Search workflow files and documentation for:

``` text
API_KEY
TOKEN
PASSWORD
SECRET
Bearer
```

Expected:

-   no real secret values are found

## Test D --- Error-log safety

Trigger a controlled workflow error.

Inspect:

`automation_error_logs`

Expected:

-   execution ID is present
-   useful error information is present
-   no credentials/tokens are present

## Test E --- AI prompt safety

Inspect the Gemini prompt.

Expected:

-   only required lead information is sent
-   no credentials or secrets are included

## Test F --- Customer email safety

Inspect confirmation/reminder content.

Expected:

-   customer receives relevant appointment information
-   internal debugging information is not exposed
-   credentials are not exposed

------------------------------------------------------------------------

# 18. Security Review Matrix

  -------------------------------------------------------------------------
  Area                    Current state             Action
  ----------------------- ------------------------- -----------------------
  n8n credentials         Credential                Verify
                          nodes/references are used 

  Supabase credentials    Credential reference is   Verify
                          used                      

  Gemini credentials      Credential reference is   Verify
                          used                      

  Calendly credentials    Integration exists        Verify

  Google Calendar         Integration exists        Verify
  credentials                                       

  Gmail credentials       Email integration exists  Verify

  Lead webhook            `voryn-lead`              Harden/review

  Input validation        Implemented               Review limits

  Supabase RLS            Not established in        Review
                          current project           
                          documentation             

  Error logs              `automation_error_logs`   Secure

  AI data exposure        Lead data is sent to      Minimize/review
                          Gemini                    

  Email exposure          Customer/internal emails  Review
                          exist                     

  GitHub exposure         Not yet verified          Audit

  Environment secrets     Not yet verified          Audit

  Backups                 Not yet verified          Secure/document
  -------------------------------------------------------------------------

------------------------------------------------------------------------

# 19. M12 Implementation Order

Follow this order:

``` text
1. Credential audit
        ↓
2. n8n access review
        ↓
3. Webhook security
        ↓
4. Input security
        ↓
5. Supabase/RLS review
        ↓
6. Error-log security
        ↓
7. Gemini data review
        ↓
8. Calendly/Calendar review
        ↓
9. Email security review
        ↓
10. GitHub/export audit
        ↓
11. Environment/secret audit
        ↓
12. Backup security
        ↓
13. Security tests
        ↓
14. Document results
```

------------------------------------------------------------------------

# 20. M12 Progress Tracker

-   [ ] **12.0** Security audit
-   [ ] **12.1** Credential security
-   [ ] **12.2** n8n access control
-   [ ] **12.3** Webhook security
-   [ ] **12.4** Input security
-   [ ] **12.5** Supabase/database security
-   [ ] **12.6** Error-log security
-   [ ] **12.7** Gemini/AI security
-   [ ] **12.8** Calendly/Calendar security
-   [ ] **12.9** Email security
-   [ ] **12.10** Workflow expression/data exposure review
-   [ ] **12.11** GitHub/export security
-   [ ] **12.12** Environment variable/secret review
-   [ ] **12.13** Backup security
-   [ ] **12.14** Security testing

**Status:** 🔵 NEXT IMPLEMENTATION

------------------------------------------------------------------------

# 21. M12 Completion Criteria

M12 is complete when:

-   [ ] No real credentials are hard-coded in workflows.
-   [ ] Credentials use the appropriate credential mechanism.
-   [ ] Webhook exposure has been reviewed and protected appropriately.
-   [ ] Input validation is enforced.
-   [ ] Supabase access and RLS have been reviewed.
-   [ ] Error logs contain safe information only.
-   [ ] Gemini receives only necessary information.
-   [ ] Calendar credentials and appointment data are protected.
-   [ ] Customer emails do not expose internal information.
-   [ ] Workflow exports have been checked for secrets.
-   [ ] GitHub exposure has been checked.
-   [ ] Environment files are protected.
-   [ ] Backups do not contain raw credentials.
-   [ ] Security tests pass.
-   [ ] Security decisions are documented.

------------------------------------------------------------------------

# 22. Deliverable

**Security Checklist and Hardened Voryn Configuration**

The completed milestone should protect:

``` text
Credentials
    ↓
Webhook
    ↓
Input
    ↓
Database
    ↓
AI
    ↓
Calendar
    ↓
Email
    ↓
Error Logs
    ↓
Workflow Exports
    ↓
Backups
```

------------------------------------------------------------------------

# 23. Implementation Protocol

For every M12 task, follow:

**WHY → WHAT → CONCEPT → TOOL → BUILD → TEST → DEBUG → DOCUMENT →
CHECKPOINT → NEXT**

Do not make broad security changes blindly.

A security change that breaks lead capture, Supabase writes, Gemini
analysis, Calendly processing, email delivery, or reminders must be
tested before moving forward.

------------------------------------------------------------------------

# 24. Project Security Rule

Do not place actual credential values in this documentation.

Use credential names such as:

-   `Supabase account`
-   `Google Gemini(PaLM) Api account`
-   `Calendly credential`
-   `Google Calendar credential`
-   `Gmail credential`

Never document the actual secret value.

------------------------------------------------------------------------

## Project Progress

``` text
Milestone 11 — Error Handling & Reliability    🟢 COMPLETE
Milestone 12 — Security                        🔵 NEXT
Milestone 13 — Full End-to-End Testing         ⬜
Milestone 14 — Production Deployment           ⬜
Milestone 15 — Monitoring & Maintenance        ⬜
Milestone 16 — Final Documentation             ⬜
Milestone 17 — Portfolio Demonstration         ⬜
Milestone 18 — Productize the Project          ⬜
```
