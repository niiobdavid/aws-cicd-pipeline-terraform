# NextWork CI/CD pipeline — Terraform

Builds the whole "Build a CI/CD Pipeline with AWS" project in one go:

GitHub → CodePipeline → CodeBuild (+ CodeArtifact) → S3 → CodeDeploy → EC2 web server

| File | What it creates |
|---|---|
| `codeartifact.tf` | Domain `nextwork`, repos `maven-central-store` (upstream to Maven Central) and `nextwork-devops-cicd` |
| `s3.tf` | Artifact bucket `nextwork-devops-cicd-nii-artifacts` |
| `iam.tf` | Roles for CodeBuild, CodeDeploy, CodePipeline and the web server, with every permission you had to add by hand |
| `codebuild.tf` | CodeBuild project (Amazon Linux 2, corretto8 via your buildspec) |
| `webserver.tf` | Amazon Linux 2 EC2 web server + security group; CodeDeploy agent installed on boot |
| `codedeploy.tf` | CodeDeploy app + deployment group (in-place, AllAtOnce, auto-rollback) |
| `codepipeline.tf` | GitHub connection + 3-stage pipeline (Source → Build → Deploy) |

## Before you start

1. **Delete the resources you built by hand** (or they'll clash on names):
   - CodePipeline, CodeDeploy app, CodeBuild project named `nextwork-devops-cicd`
   - CodeArtifact repos and the `nextwork` domain
   - The CloudFormation stack for the old web server (`nextwork-codedeploy-ec2-stack`)
2. **Your GitHub repo must contain** (at the root): `buildspec.yml`, `appspec.yml`, `settings.xml`, `scripts/`, `pom.xml`, `src/`.
   - The buildspec `artifacts:` section must include `appspec.yml` and `scripts/**/*`.
   - `settings.xml` must point at the URL shown in the `codeartifact_repository_url` output.
3. AWS CLI configured (`aws sts get-caller-identity` works) and Terraform installed.

## Run it

```bash
cp terraform.tfvars.example terraform.tfvars   # edit github_repo etc.
terraform init
terraform plan
terraform apply
```

## One manual step: approve the GitHub connection

Terraform creates the GitHub connection as **Pending** — AWS requires a human to authorise it.

1. Open the `approve_github_connection_here` link from the outputs.
2. Select `nextwork-devops-cicd-github` → **Update pending connection** → install/authorise the AWS Connector GitHub App for your repo.
3. Status should change to **Available**.
4. Open the pipeline (`pipeline_url` output) → **Release change**, or just `git push` to `master`.

The pipeline's first automatic run (right after `apply`) will fail at Source because the connection wasn't approved yet — that's expected.

## Check it

- Pipeline: all three stages green.
- Open the `web_app_url` output — use **http://**, not https (turn off Brave's HTTPS upgrade for the site if needed).
- Shell into the web server: EC2 → instance → **Connect** → Session Manager (no key pair needed) or EC2 Instance Connect.

## Tear it all down

```bash
terraform destroy
```

Removes everything this created, including the artifact bucket and its contents.

## Notes

- The web server uses **Amazon Linux 2** so your existing scripts (`yum`, `tomcat`, `/usr/share/tomcat/webapps`) work unchanged. Amazon Linux 2 is past its standard support date; if the AMI lookup ever fails, switch to Amazon Linux 2023 and update the scripts (Tomcat there is `tomcat9`/`tomcat10` with different paths).
- The HTTP rule allows anyone by default. Set `allowed_http_cidr = "<your-ip>/32"` to restrict it.
- Never commit `terraform.tfstate` or `terraform.tfvars` — `.gitignore` already excludes them.
