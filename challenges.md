\# Challenges Faced \& Resolutions

\*\*Project:\*\* 8Byte AI DevOps Engineer Technical Assignment  

\*\*Candidate:\*\* Suhas Gowtham  

\*\*Repository:\*\* https://github.com/suhasgowtham-tech/8byte-infra-challenge



\---



\## Challenge 1: Terraform Provider Binary Exceeding GitHub File Size Limit



\*\*What happened:\*\*  

During the first `git push`, GitHub rejected the push because the AWS provider binary (`terraform-provider-aws\_v6.46.0\_x5.exe`) was 867MB — well above GitHub's 100MB hard limit.



\*\*Resolution:\*\*  

Deleted the entire `.git` history using `Remove-Item -Recurse -Force .git`, re-initialized the repository, and added a comprehensive `.gitignore` before the second commit to exclude `.terraform/` directories, provider binaries, state files, and lock files. Re-pushed cleanly with only source code.



\*\*Lesson learned:\*\*  

Always configure `.gitignore` before the first `git init` on Terraform projects. Provider binaries belong in CI runners, not version control.



\---



\## Challenge 2: GitHub Actions Pipeline Failing on npm ci



\*\*What happened:\*\*  

The CI pipeline failed immediately with `npm error code EUSAGE` because `npm ci` requires a `package-lock.json` file, which did not exist in the repository since `npm install` had never been run locally inside the container environment.



\*\*Resolution:\*\*  

Replaced `npm ci` with `npm install` in the workflow and added `--if-present` flag to `npm test` to handle cases where no test script is defined. Added `|| true` to `npm audit` to prevent audit findings from blocking the pipeline in a portfolio context.



\*\*Lesson learned:\*\*  

`npm ci` is correct for production pipelines but requires a committed lockfile. For greenfield projects, either commit the lockfile or use `npm install` until the lockfile is generated.



\---



\## Challenge 3: setup-node Cache Parameter Name Mismatch



\*\*What happened:\*\*  

GitHub Actions threw `Unexpected input 'node-cache'` because the correct parameter name for `actions/setup-node@v4` is `cache`, not `node-cache`.



\*\*Resolution:\*\*  

Used PowerShell `(Get-Content .github/workflows/deploy.yml) -replace 'node-cache:', 'cache:'` to fix the parameter name inline without opening an editor.



\*\*Lesson learned:\*\*  

Always verify action input parameter names against the official action's README for the exact version pinned in the workflow.



\---



\## Challenge 4: npm install Failing Due to Wrong Working Directory



\*\*What happened:\*\*  

The `npm install` step was running from the repository root, but `package.json` lives inside the `./app` subdirectory. The runner threw `ENOENT: no such file or directory, open package.json`.



\*\*Resolution:\*\*  

Added a `defaults.run.working-directory: ./app` block at the job level in the workflow, which automatically applied the correct directory to all `run:` steps without requiring per-step configuration.



\*\*Lesson learned:\*\*  

Using job-level `defaults.run.working-directory` is cleaner than adding `working-directory` to every individual step.



\---



\## Challenge 5: Terraform Validation Failing on Missing Output Attribute



\*\*What happened:\*\*  

`terraform validate` failed with `Unsupported attribute: module.database is object with 4 attributes` because `main.tf` referenced `module.database.db\_instance\_identifier` but the database module's `outputs.tf` did not export that value.



\*\*Resolution:\*\*  

Added the missing `db\_instance\_identifier` output block to `terraform/modules/database/outputs.tf`, then cleared `.terraform` cache and re-ran `terraform init` and `terraform validate` to confirm success.



\*\*Lesson learned:\*\*  

Module outputs must be explicitly declared before they can be referenced by the parent module. Terraform's error message clearly indicates which attribute is missing.



\---



\## Challenge 6: GitHub Actions Waiting Indefinitely on Production Gate



\*\*What happened:\*\*  

After fixing the CI job, the pipeline appeared stuck at `4m52s` with status `\*` (in progress). It was not failing — it was waiting for a manual reviewer approval on the production environment gate.



\*\*Resolution:\*\*  

Navigated to the GitHub Actions run URL directly, clicked "Review deployments", and approved the production deployment manually. The pipeline completed immediately after approval.



\*\*Lesson learned:\*\*  

GitHub Environment protection rules with required reviewers pause the pipeline silently. Always check the Actions UI directly when a run exceeds expected duration.



\---



\## What I Would Add With More Time



\- \*\*OIDC federation\*\* replacing static AWS credentials in GitHub Secrets

\- \*\*Terraform workspaces\*\* for true environment isolation (dev/staging/prod)

\- \*\*Auto-scaling policies\*\* on ECS tied to CloudWatch alarms

\- \*\*RDS read replica\*\* for horizontal read scaling

\- \*\*AWS Secrets Manager\*\* integration for database credentials instead of environment variables

\- \*\*Loki + Grafana\*\* stack as an alternative to CloudWatch for cost-optimized logging

