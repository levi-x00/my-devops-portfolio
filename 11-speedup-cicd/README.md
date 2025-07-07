# CodeBuild Cache

This project to show how can you speedup your CI/CD pipeline by caching the `.terraform` files instead download them again everytime the pipieline triggered by changes. This features also can save you a lot with cost reduction for data transfer out.

Services that being used for this projects:

1. AWS CodePipeline
2. AWS CodeBuild
3. GitHub

You can follow these steps to setup:

1. Create a new repository for this project, then clone it
   ![Alt text](./images/Screenshot-demo-repo.png?raw=true)
2. Copy the files from `01-network-stack` to the cloned repository, then commit the terraform files, for example in my case I created a new demo repository called `tf-network-stacks`

```sh
   git add .
   git config user.name 'your username'
   git config user.email 'your useremail'
   git commit -m 'init'
   git push origin master
```

3. Now that the files already commited, go to AWS CodePipeline console, then click Create pipeline
   ![Alt text](./images/Screenshot-codepipeline-console.png?raw=true)

4. Select `Build custom pipeline`
   ![Alt text](./images/Screenshot-pipeline-category.png?raw=true)

5. Name the pipeline, select `Queued` as the execution mode, for the service role select new service role or the existing service role
   ![Alt text](./images/Screenshot-pipeline-settings.png?raw=true)
   In advance settings, leave it as default
   ![Alt text](./images/Screenshot-pipeline-adv-settings.png?raw=true)
   Once done, then click `Next`

6. In pipeline source select GitHub (via OAuth app), then click `Connect to GitHub`
   ![Alt text](./images/Screenshot-pipeline-src.png?raw=true)
   Once the GitHub connected, select the repository and the branch, then click `Next`
   ![Alt text](./images/Screenshot-pipeline-src2.png?raw=true)

7. In build stage select `Other build providers`, then select `AWS CodeBuild`, click `Create project`
   ![Alt text](./images/Screenshot-pipeline-build.png?raw=true)

8. Name the build project (e.g `tf-network-build`), and the project type is `Default project`
   ![Alt text](./images/Screenshot-pipeline-buildname.png?raw=true)
9. For Environment, follow the configuration below

- Provisioning model: On-Demand
- Environment image: Managed image
- Compute: EC2
- Running mode: Container
- OS: Amazon Linux
- Runtime(s): Standard
- Image: aws/codebuild/amazonlinux-x86_64-standard:5.0
- Image version: always use the latest version
- Service role: New service role

10. Configure the buildspec for the build project, select `Insert build commands` then `Switch to editor`
    ![Alt text](./images/Screenshot-pipeline-buildspec.png?raw=true)
    Copy the following [buildspec.yml](./buildspec.yml) to the editor pad

11. Name the CloudWatch logs `/aws/codebuild/tf-network-build`, then click `Continue to CodePipeline`
    ![Alt text](./images/Screenshot-pipeline-logs.png?raw=true)

12. After CodeBuild project created, select the build type is `Single build` then click `Next`
    ![Alt text](./images/Screenshot-pipeline-buildartf.png?raw=true)
13. Skip the test and deploy stage, Review and `Create Pipeline`

14. At first, the CodePipeline will automatically run after the creation, and in the build logs shows that `.terraform.lock.hcl` is created for the first time
    ![Alt text](./images/Screenshot-tf-init.png?raw=true)

15. Go to AWS CodeBuild select the previous created project `tf-network-build`, in `Project details` tab, scroll down in the `Artifact`, click `Edit`
    ![Alt text](./images/Screenshot-pipeline-cache.png?raw=true)

16. Expand the Addtional configuration, select the Cache type as `Amazon S3`, pick the s3 bucket, and fill the path prefix, once done click `Update artifacts`
    ![Alt text](./images/Screenshot-pipeline-cache2.png?raw=true)

17. Once done try to make changes in the repository then notice that `terraform init` reuse the existing installed aws/hashicorp
    ![Alt text](./images/Screenshot-tf-init2.png?raw=true)
    This command proofs that `.terraform` and `.terraform.hcl.lock` are cached
    ![Alt text](./images/Screenshot-ls.png?raw=true)

18. The more resources managed in terraform, the bigger `.terraform` directory becomes, with cache will make the pipeline become more faster instead of downloading more terraform resources from the ground
