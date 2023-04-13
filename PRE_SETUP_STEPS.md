# Setting Up Workload Identity for GitHub Actions and Terraform

> This script helps to set up workload identity for GitHub actions and Terraform using Workload Identity Federation. 

### The following steps are performed by the script:

- Run the following export statements to be later used in the lower code snippets

`export PROJECT_ID=INSERT_PROJECT_ID`

`export PROJECT_NUMBER=INSERT_PROJECT_NUMBER`

`export STATE_BUCKET=INSERT_BUCKET_NAME_TO_BE_CREATED`

- You can get the Project ID and Project Number by typing the following : <pre><code>gcloud config list</code></pre>  

- Create a GCP storage bucket to store Terraform state.
<pre><code>gcloud storage buckets create gs://$STATE_BUCKET
--project=$PROJECT_ID
--default-storage-class=STANDARD
--location=US-EAST1
--uniform-bucket-level-access
</code></pre>

- Create a workload identity pool named "github" in the specified GCP project with a specified description and display name.

<pre><code>gcloud iam workload-identity-pools create github
--project=$PROJECT_ID
--location="global"
--description="GitHub pool"
--display-name="GitHub pool"
</code></pre>

- Create an OpenID Connect (OIDC) identity provider named "github" with the specified display name, attribute mapping, and issuer URI. The attribute mapping maps the GitHub Action event attributes to Google Cloud's principalSet format.

<pre><code>gcloud iam workload-identity-pools providers create-oidc "github"
--project="${PROJECT_ID}"
--location="global"
--workload-identity-pool="github"
--display-name="GitHub provider"
--attribute-mapping="google.subject=assertion.sub,attribute.workflow_ref=assertion.job_workflow_ref,attribute.event_name=assertion.event_name"
--issuer-uri="https://token.actions.githubusercontent.com"
</code></pre>

- Add an IAM policy binding to the tf-plan-sa service account, granting it the roles/iam.workloadIdentityUser role and mapping the GitHub Action event attributes to Google Cloud's principalSet format, with specific values for repository_name, actor, and event_name.

<pre><code>gcloud iam service-accounts add-iam-policy-binding "tf-plan-sa@${PROJECT_ID}.iam.gserviceaccount.com" \
--project="${PROJECT_ID}" \
--role="roles/iam.workloadIdentityUser" \
--member="principalSet://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/github/attribute.repository_name/GITHUB_REPO_NAME/attribute.actor/GITHUB_USER/attribute.event_name/pull_request" \
--role="roles/iam.serviceAccountTokenCreator"</code></pre>

- Add an IAM policy binding to the tf-apply-sa service account, granting it the roles/iam.workloadIdentityUser role and mapping the GitHub Action workflow reference to Google Cloud's principalSet format, with specific values for workflow_ref.

<pre><code>gcloud iam service-accounts add-iam-policy-binding "tf-apply-sa@${PROJECT_ID}.iam.gserviceaccount.com" \
--project="${PROJECT_ID}" \
--role="roles/iam.workloadIdentityUser" \
--member="principalSet://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/github/attribute.workflow_ref/GITHUB_USER/GITHUB_REPO_NAME/.github/workflows/terraform.yaml@refs/heads/main" \
--role="roles/iam.serviceAccountTokenCreator"</code></pre>

- Note that you will need to replace the placeholder values for **PROJECT_ID**, **PROJECT_NUMBER**, **STATE_BUCKET**, **GITHUB_REPO_NAME**, and **GITHUB_USER** with your own values.


- Once you run this script, your Terraform scripts can use the google provider with the workload_identity_config block to assume the tf-plan-sa and tf-apply-sa service accounts, allowing them to interact securely with GCP resources.

## Links and references to aid in setup:
- [OutofDevops WIF Setup tutorial](https://www.youtube.com/watch?v=DMwl9WcSAL8)
- [Getting started with Gcloud CLI](https://cloud.google.com/sdk/docs/install)