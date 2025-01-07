# Can we use exxisting security group for EFS
You can use an existing security group for your EFS setup, but it is typically recommended to create a separate security group for EFS for better security and isolation. This way, you can manage and audit the access specifically for EFS separately from other resources.

**Using an Existing Security Group:**
If you decide to use an existing security group for your EFS mount targets, the security group needs to allow inbound access to port 2049 (NFS) from the instances or services that will be mounting the EFS file system (like Kubernetes pods in your private subnets).

# Why It's Recommended to Create a Separate Security Group for EFS:
**Granular Access Control:** By creating a dedicated security group for EFS, you can control which resources can access EFS without impacting other resources.
For instance, you could allow only specific EC2 instances or Kubernetes nodes to mount EFS, which makes it easier to manage access.
S**ecurity Best Practices:** Security groups should follow the principle of least privilege, meaning that they should allow only the necessary traffic. Having a separate security group allows you to define rules specific to the EFS mount points and avoid broad access granted by a general security group.