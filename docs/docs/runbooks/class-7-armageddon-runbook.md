# Class 7 Armageddon Runbook: Event-Driven WAF Detection and Response

## Goal

Deploy and validate the Lab 12a and Lab 12b event-driven security workflow.

Expected behavior:

```text
AWS WAF blocks malicious requests.
Lambda normalizes and correlates WAF events.
Amazon Bedrock classifies security findings.
The SOAR workflow sends high-severity alerts.
The executive dashboard agent writes a security report to Amazon S3.
```

> Run security tests only against an endpoint you own or are explicitly authorized to test.

---

## Existing Resources

This lab uses the Terraform and Lambda source supplied by the lead engineering team.

Core resources:

```text
Cognito user pool: test_user_pool
Cognito app client: user_pool_client
API Gateway REST API: terraform_rest_api
AWS WAF Web ACL: waf_rest_api
DynamoDB table: waf-events-1
DynamoDB table: waf-correlation-findings
DynamoDB table: security-incidents
EventBridge Pipe: pipe-findings-to-eventbridge
Lambda: waf-analyzer
Lambda: waf-threat
Lambda: soar-response
Lambda: executive-dashboard-agent
S3 bucket: executive-reports
```

Required local files:

```text
Terraform configuration
Lambda source directories
layers archive supplied by the lead engineering team
06-pipe.tf
13-outputs.tf
```

---

## Security Rules

Do not commit or publish:

```text
Passwords
Access keys
Client secrets
MFA QR codes or secret keys
MFA codes
Access tokens
Session tokens
Unredacted account or user information
```

Use a unique password stored outside the repository. Verify IAM permissions against the intended least-privilege design rather than checking only whether policy statements use `Allow`.

---

## 1. Prepare the Terraform Directory

Clone the approved repository and extract the supplied `layers` archive.

Place the extracted content in the location expected by the Terraform configuration.

Confirm:

```text
Terraform files are present.
Lambda source directories are present.
Layer artifacts are present.
Local paths match the Terraform references.
```

Expected result:

```text
Terraform can resolve every referenced local file.
```

Screenshot proof:

![Screenshot proof](../../screenshots/armageddon/page-01-figure-01.png)

---

## 2. Initialize and Validate Terraform

From the Terraform working directory, run:

```bash
terraform init
terraform validate
terraform plan
```

If Terraform prompts for a password, enter the approved lab value at the prompt. Do not place it in a command, source file, screenshot, or Git commit.

Expected result:

```text
Terraform initializes successfully.
The configuration is valid.
The plan contains the expected resources.
The plan contains no unexpected deletions.
```

Screenshot proof:

![Screenshot proof](../../screenshots/armageddon/page-02-figure-01.png)

![Screenshot proof](../../screenshots/armageddon/page-02-figure-02.png)

![Screenshot proof](../../screenshots/armageddon/page-02-figure-03.png)

---

## 3. Deploy the Infrastructure

Run:

```bash
terraform apply
```

Review the plan and approve the deployment.

Display the outputs:

```bash
terraform output
```

Copy the API Gateway invoke URL returned by `13-outputs.tf`.

Expected result:

```text
Terraform apply completes successfully.
The API Gateway invoke URL is available.
```

Screenshot proof:

![Screenshot proof](../../screenshots/armageddon/page-02-figure-04.png)

---

## 4. Confirm the SNS Subscription

Open the inbox configured as the Amazon SNS endpoint.

Open the AWS subscription message and select:

```text
Confirm subscription
```

Expected result:

```text
Subscription confirmed.
The endpoint can receive security notifications.
```

Screenshot proof:

![Screenshot proof](../../screenshots/armageddon/page-03-figure-01.png)

![Screenshot proof](../../screenshots/armageddon/page-03-figure-02.png)

![Screenshot proof](../../screenshots/armageddon/page-03-figure-03.png)

---

## 5. Validate Cognito Authentication and MFA

Go to:

```text
Amazon Cognito -> User pools -> test_user_pool
```

Open:

```text
Applications -> App clients -> user_pool_client -> View login page
```

Sign in with the configured test user.

When prompted:

```text
Scan the MFA QR code with an authenticator app.
Enter the current 6-digit code.
Complete sign-in.
```

Expected result:

```text
Cognito accepts the username, password, and MFA code.
Authentication completes successfully.
```

> A redirect error may be expected when the lab does not implement the callback application. Confirm that authentication completed before the redirect.

Screenshot proof:

![Screenshot proof](../../screenshots/armageddon/page-04-figure-01.png)

![Screenshot proof](../../screenshots/armageddon/page-04-figure-02.png)

![Screenshot proof](../../screenshots/armageddon/page-04-figure-03.png)

![Screenshot proof](../../screenshots/armageddon/page-05-figure-01.png)

![Screenshot proof](../../screenshots/armageddon/page-06-figure-01.png)

![Screenshot proof](../../screenshots/armageddon/page-07-figure-01.png)

![Screenshot proof](../../screenshots/armageddon/page-08-figure-01.png)

---

## 6. Confirm DynamoDB Tables

Go to:

```text
Amazon DynamoDB -> Tables
```

Confirm:

```text
waf-events-1                  -> partition key: event_id
waf-correlation-findings      -> partition key: finding_id
security-incidents            -> partition key: incident_id
```

Expected result:

```text
All three tables are Active.
Each partition key matches the Terraform configuration.
```

Screenshot proof:

![Screenshot proof](../../screenshots/armageddon/page-08-figure-02.png)

![Screenshot proof](../../screenshots/armageddon/page-09-figure-01.png)

![Screenshot proof](../../screenshots/armageddon/page-10-figure-01.png)

![Screenshot proof](../../screenshots/armageddon/page-11-figure-01.png)

---

## 7. Confirm the `waf-analyzer` Function

Go to:

```text
AWS Lambda -> Functions -> waf-analyzer
```

Confirm:

```text
The handler points to the expected Python module.
Environment variables match the Terraform configuration.
The execution role can read WAF logs.
The execution role can write to waf-events-1.
The role contains no unrelated or unexpected wildcard permissions.
```

Expected result:

```text
waf-analyzer is configured to normalize WAF logs and write DynamoDB events.
```

Screenshot proof:

![Screenshot proof](../../screenshots/armageddon/page-11-figure-02.png)

![Screenshot proof](../../screenshots/armageddon/page-12-figure-01.png)

![Screenshot proof](../../screenshots/armageddon/page-13-figure-01.png)

![Screenshot proof](../../screenshots/armageddon/page-14-figure-01.png)

---

## 8. Confirm the `waf-threat` Function

Go to:

```text
AWS Lambda -> Functions -> waf-threat
```

Confirm:

```text
Code source: waf_threat_correlation_agent.py
Environment variables match Terraform.
The execution role can read normalized events.
The execution role can write correlated findings.
The execution role can invoke the configured analysis service.
```

Expected result:

```text
waf-threat is configured to correlate related WAF events.
```

Screenshot proof:

![Screenshot proof](../../screenshots/armageddon/page-15-figure-01.png)

![Screenshot proof](../../screenshots/armageddon/page-16-figure-01.png)

![Screenshot proof](../../screenshots/armageddon/page-17-figure-01.png)

![Screenshot proof](../../screenshots/armageddon/page-18-figure-01.png)

---

## 9. Confirm the `soar-response` Function

Go to:

```text
AWS Lambda -> Functions -> soar-response
```

Confirm:

```text
Code source: soar_response_agent.py
Environment variables match Terraform.
The execution role can perform the intended response actions.
The execution role can publish the configured notification.
```

Expected result:

```text
soar-response is configured to respond to qualifying security findings.
```

Screenshot proof:

![Screenshot proof](../../screenshots/armageddon/page-19-figure-01.png)

![Screenshot proof](../../screenshots/armageddon/page-20-figure-01.png)

![Screenshot proof](../../screenshots/armageddon/page-20-figure-02.png)

---

## 10. Confirm the `executive-dashboard-agent` Function

Go to:

```text
AWS Lambda -> Functions -> executive-dashboard-agent
```

Confirm:

```text
The handler points to the expected executive dashboard module.
Environment variables match Terraform.
The execution role can read the required incident data.
The execution role can write only to the intended S3 bucket and prefix.
```

Expected result:

```text
The function can generate and store the executive security report.
```

Screenshot proof:

![Screenshot proof](../../screenshots/armageddon/page-21-figure-01.png)

---

## 11. Confirm the DynamoDB Stream

Go to:

```text
Amazon DynamoDB -> Tables -> waf-correlation-findings -> Exports and streams
```

Confirm:

```text
Stream status: On
Stream view type: matches Terraform and EventBridge Pipe requirements
```

Expected result:

```text
The table stream is available as the EventBridge Pipe source.
```

Screenshot proof:

![Screenshot proof](../../screenshots/armageddon/page-22-figure-01.png)

---

## 12. Confirm the EventBridge Pipe

Go to:

```text
Amazon EventBridge -> Pipes -> pipe-findings-to-eventbridge
```

Confirm:

```text
Source: waf-correlation-findings DynamoDB stream
Filter: matches 06-pipe.tf
Target: default EventBridge event bus
Input transformer: matches 06-pipe.tf
Pipe state: Running
```

Expected result:

```text
The pipe can forward qualifying findings to EventBridge.
```

Screenshot proof:

![Screenshot proof](../../screenshots/armageddon/page-23-figure-01.png)

![Screenshot proof](../../screenshots/armageddon/page-24-figure-01.png)

![Screenshot proof](../../screenshots/armageddon/page-24-figure-02.png)

![Screenshot proof](../../screenshots/armageddon/page-25-figure-01.png)

![Screenshot proof](../../screenshots/armageddon/page-25-figure-02.png)

---

## 13. Retrieve the API Gateway Invoke URL

Use the value returned by:

```bash
terraform output
```

Or go to:

```text
Amazon API Gateway -> terraform_rest_api -> Stages -> <deployed-stage>
```

Copy:

```text
Invoke URL
```

Expected result:

```text
The console URL matches the Terraform output.
```

Screenshot proof:

![Screenshot proof](../../screenshots/armageddon/page-26-figure-01.png)

![Screenshot proof](../../screenshots/armageddon/page-26-figure-02.png)

---

## 14. Run the Authorized WAF Test

Open the approved WAF validation tool.

Enter:

```text
API Gateway invoke URL
```

Select the required test categories and start the scan.

Expected result:

```text
Requests that match prohibited patterns are blocked by the intended WAF rules.
No malicious test request returns a successful 2xx response.
```

> A non-200 response alone does not prove that every WAF rule works. Confirm the terminating rule and action in the WAF logs.

Screenshot proof:

![Screenshot proof](../../screenshots/armageddon/page-27-figure-01.png)

![Screenshot proof](../../screenshots/armageddon/page-27-figure-02.png)

![Screenshot proof](../../screenshots/armageddon/page-28-figure-01.png)

![Screenshot proof](../../screenshots/armageddon/page-28-figure-02.png)

---

## 15. Confirm WAF Logs

Go to:

```text
AWS WAF and Shield -> Protection packs (Web ACLs) -> waf_rest_api
```

Open:

```text
Logging and metrics -> Logging destination -> latest log stream
```

Search the test window for the requests generated by the WAF validation tool.

Expected result:

```text
WAF logs contain the test requests.
The expected terminating rule and action are recorded.
```

Screenshot proof:

![Screenshot proof](../../screenshots/armageddon/page-29-figure-01.png)

![Screenshot proof](../../screenshots/armageddon/page-29-figure-02.png)

![Screenshot proof](../../screenshots/armageddon/page-29-figure-03.png)

---

## 16. Confirm `waf-analyzer` Processing

Go to:

```text
AWS Lambda -> waf-analyzer -> Monitor -> View CloudWatch logs
```

Open the latest log stream from the test window.

Then go to:

```text
Amazon DynamoDB -> waf-events-1 -> Explore table items
```

Expected result:

```text
waf-analyzer processes the WAF records without an unhandled error.
Corresponding event records appear in waf-events-1.
```

Screenshot proof:

![Screenshot proof](../../screenshots/armageddon/page-30-figure-01.png)

![Screenshot proof](../../screenshots/armageddon/page-31-figure-01.png)

---

## 17. Confirm `waf-threat` Correlation

Go to:

```text
AWS Lambda -> waf-threat -> Monitor -> View CloudWatch logs
```

Open the invocation associated with the test window.

Then go to:

```text
Amazon DynamoDB -> waf-correlation-findings -> Explore table items
```

Expected result:

```text
The function completes without an unhandled error.
Qualifying events produce correlated findings.
Nonqualifying events do not produce false high-severity incidents.
```

Screenshot proof:

![Screenshot proof](../../screenshots/armageddon/page-32-figure-01.png)

![Screenshot proof](../../screenshots/armageddon/page-32-figure-02.png)

---

## 18. Confirm the SOAR Response and Alert

Go to:

```text
AWS Lambda -> soar-response -> Monitor -> View CloudWatch logs
```

Confirm that the finding was processed with the expected severity and response.

For a high-severity finding, check the confirmed SNS inbox.

Correlate:

```text
Finding ID
Severity
Source IP address
Timestamp
Notification
```

Expected result:

```text
A qualifying high-severity finding triggers the configured response.
The subscribed security endpoint receives an alert.
```

Screenshot proof:

![Screenshot proof](../../screenshots/armageddon/page-33-figure-01.png)

![Screenshot proof](../../screenshots/armageddon/page-33-figure-02.png)

![Screenshot proof](../../screenshots/armageddon/page-34-figure-01.png)

---

## 19. Generate the Executive Security Report

Go to:

```text
AWS Lambda -> executive-dashboard-agent -> Test
```

Use the approved test event and select:

```text
Test
```

Expected result:

```text
The function invocation succeeds.
A new executive security report is written to Amazon S3.
```

Screenshot proof:

![Screenshot proof](../../screenshots/armageddon/page-35-figure-01.png)

---

## 20. Retrieve and Validate the Report

Go to:

```text
Amazon S3 -> executive-reports -> <year> -> <month> -> <day>
```

Open the newly generated report.

Confirm:

```text
Report date and generation time
Overall security posture
Key security metrics
Material changes or significant findings
Business impact
Recommended remediation or leadership actions
```

Expected result:

```text
The report is readable and complete.
The S3 date path is correct.
The report matches the incident and correlation records from the test.
```

Screenshot proof:

![Screenshot proof](../../screenshots/armageddon/page-36-figure-01.png)

![Screenshot proof](../../screenshots/armageddon/page-37-figure-01.png)

![Screenshot proof](../../screenshots/armageddon/page-37-figure-02.png)

---

## Final Check

```text
Terraform deployed the expected resources.
The SNS subscription is confirmed.
Cognito authentication and MFA succeeded.
DynamoDB tables use the expected partition keys.
Lambda configuration matches Terraform.
The DynamoDB stream is enabled.
The EventBridge Pipe is running.
WAF test requests appear in the expected logs.
waf-analyzer created normalized events.
waf-threat created qualifying correlated findings.
soar-response processed the finding and sent the expected alert.
executive-dashboard-agent created a complete report in Amazon S3.
```

---

## Quick Troubleshooting

```text
Terraform failure
-> Check credentials, Region, backend configuration, variables, and local layer paths.

Missing DynamoDB record
-> Check the upstream Lambda logs, environment variables, IAM permissions, and input event.

EventBridge Pipe not running
-> Check the stream ARN, filter, execution role, target permissions, and pipe state.

Missing WAF test event
-> Check the API URL, Web ACL association, logging destination, Region, and timestamp.

Missing executive report
-> Check the Lambda result, bucket variable, s3:PutObject permission, prefix, and scheduler logs.
```

---

## Cleanup

When the lab is complete and required evidence has been captured, run:

```bash
terraform plan -destroy
terraform destroy
```

Expected result:

```text
Terraform removes the managed lab resources.
No unexpected billable resources remain.
```

---

## Security Checklist

Before commit or push:

```bash
git status --short
git ls-files | grep -Ei 'tfstate|\.tfvars|token|secret|credential|password'
grep -RInE 'AKIA[0-9A-Z]{16}|BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY|AccessToken|IdToken|RefreshToken|client[_ -]?secret|password[" ]*[:=]' . \
  --exclude-dir=.git \
  --exclude-dir=.terraform 2>/dev/null
```

Expected result:

```text
No Terraform state or secret-bearing variable files are tracked.
No credentials, tokens, passwords, MFA seeds, or private keys appear in committed files.
All screenshots are reviewed and sensitive values are redacted.
```
