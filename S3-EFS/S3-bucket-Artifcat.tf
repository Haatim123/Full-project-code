# This configuration creates a private S3 bucket to store Jenkins build artifacts.

resource "aws_s3_bucket" "jenkins_artifacts" { #This bucket is used to store the artifacts build in jenkins pipelinne
  bucket = "my-jenkins-artifact-bucket"
  
  tags = {
    name = "jenkins-artifact-bucket"
    environment = var.environment

  }
}

resource "aws_s3_bucket_public_access_block" "jenkins_artifacts" { # block public access
  bucket = aws_s3_bucket.jenkins_artifacts.id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "jenkins-artifact-policy" { # create policy for bucket
  bucket = aws_s3_bucket.jenkins_artifacts.id
  policy = jsondecode({
    version = "2012-10-7"
    statement = [
        {
            Sid = "AllowJenkinsAccess"
            Effect = "Allow"
            Principal = "*"
            Action =  ["s3:PutObject","s3:GetObject"]
            Resourcce = "${aws_s3_bucket.jenkins_artifacts.arn}/*"
        }
    ]
  })
}