# Scalable Web Application with ALB and Auto Scaling

## 1. Project Overview

This project demonstrates a highly available, scalable, and secure web application architecture built on Amazon Web Services (AWS).

The architecture uses multiple AWS services to provide:

- **High Availability:** Deploy application resources across multiple Availability Zones.
- **Auto Scaling:** Automatically adjust EC2 capacity based on application demand.
- **Security:** Protect application traffic using AWS WAF, Security Groups, and Network ACLs.
- **Global Content Delivery:** Use Amazon CloudFront to cache static assets and reduce latency.
- **Load Balancing:** Distribute incoming application traffic across multiple EC2 instances.
- **Monitoring:** Monitor infrastructure performance and receive notifications through Amazon CloudWatch and SNS.

The infrastructure is deployed inside an Amazon VPC and uses Amazon RDS for managed PostgreSQL database services.

---

## 2. Architecture Components

### 2.1 DNS and Content Delivery Layer

**Amazon Route 53**

Amazon Route 53 provides DNS resolution for the application domain.

Responsibilities:
- Manage DNS records.
- Route users to the application endpoint.
- Integrate with CloudFront for global content delivery.

**Amazon CloudFront**

Amazon CloudFront is a Content Delivery Network (CDN) that distributes application content through AWS edge locations.

Responsibilities:
- Cache static assets such as images, CSS, and JavaScript.
- Reduce latency for geographically distributed users.
- Reduce the number of requests reaching the origin infrastructure.
- Improve application performance.

### 2.2 Application Security Layer

**AWS Web Application Firewall (AWS WAF)**

AWS WAF protects the application against common web-based attacks.

Responsibilities:
- Protect against common OWASP Top 10 threats.
- Filter malicious HTTP requests.
- Apply security rules and request filtering.
- Help mitigate common application-layer attacks.

### 2.3 Load Balancing Layer

**Application Load Balancer (ALB)**

The Application Load Balancer distributes incoming HTTP/HTTPS requests across multiple EC2 instances.

Responsibilities:
- Distribute traffic across healthy application instances.
- Perform health checks on registered targets.
- Improve application availability.
- Integrate with EC2 Auto Scaling Groups.

The ALB acts as the entry point to the application infrastructure inside the VPC.

---

## 3. Network Architecture

### 3.1 Amazon VPC

The architecture uses an Amazon Virtual Private Cloud (VPC) with the following CIDR block:

`10.0.0.0/16`

The VPC is distributed across two Availability Zones to improve availability and fault tolerance.

### 3.2 Availability Zone A

**Public Subnet A**

CIDR: `10.0.1.0/24`

Contains:
- NAT Gateway.

Purpose:
- Provide outbound internet connectivity for resources in private subnets.
- Support communication with external AWS services and software repositories.

**Private Subnet A**

CIDR: `10.0.11.0/24`

Contains:
- EC2 application instances managed by an Auto Scaling Group.

Purpose:
- Host application workloads without exposing EC2 instances directly to the public internet.
- Receive application traffic through the ALB.

### 3.3 Availability Zone B

**Public Subnet B**

CIDR: `10.0.2.0/24`

Contains:
- NAT Gateway.

Purpose:
- Provide outbound internet connectivity.
- Maintain network redundancy across Availability Zones.

**Private Subnet B**

CIDR: `10.0.12.0/24`

Contains:
- EC2 application instances managed by an Auto Scaling Group.

Purpose:
- Run additional application instances.
- Maintain application availability if one Availability Zone becomes unavailable.

---

## 4. Compute Layer – EC2 Auto Scaling

**Amazon EC2**

Amazon EC2 provides the virtual machines responsible for running the web application.

The EC2 instances are deployed in private subnets across both Availability Zones.

**EC2 Auto Scaling Group**

The Auto Scaling Group automatically adjusts the number of EC2 instances based on configured scaling policies.

Responsibilities:
- Maintain the desired number of application instances.
- Automatically launch new instances when demand increases.
- Terminate unnecessary instances when demand decreases.
- Replace unhealthy instances.
- Distribute application capacity across Availability Zones.

This approach helps maintain application performance while optimizing infrastructure costs.

---

## 5. Database Layer – Amazon RDS

**Amazon RDS for PostgreSQL**

Amazon RDS provides a managed relational database service using PostgreSQL.

The architecture uses Multi-AZ deployment to improve database availability.

Responsibilities:
- Store application data.
- Manage database backups.
- Support automated failover.
- Reduce database administration overhead.
- Provide high availability through Multi-AZ deployment.

The application EC2 instances communicate with the database through private network connectivity.

Database access should be restricted using Security Groups to allow connections only from authorized application instances.

---

## 6. Security Architecture

Security is implemented across multiple layers.

### AWS WAF
- Protects against common web application attacks.
- Filters incoming HTTP/HTTPS requests.
- Applies managed and custom security rules.

### Security Groups
- Control inbound and outbound traffic at the resource level.
- Restrict database access to authorized application instances.
- Allow only required application ports.

### Network ACLs (NACLs)
- Provide subnet-level network traffic filtering.
- Control inbound and outbound traffic.
- Add another layer of network security.

### Private Subnets
- Keep application EC2 instances inaccessible directly from the public internet.
- Route outbound traffic through NAT Gateways.

### AWS Systems Manager – Session Manager

Session Manager provides secure access to EC2 instances without requiring a traditional bastion host.

Benefits:
- No need to expose SSH ports publicly.
- Centralized access management through IAM.
- Session logging and auditing capabilities.
- Secure administrative access to private EC2 instances.

---

## 7. Monitoring and Notifications

### Amazon CloudWatch

CloudWatch provides infrastructure monitoring and observability.

Responsibilities:
- Collect EC2 metrics.
- Monitor application and infrastructure logs.
- Create alarms based on configured thresholds.
- Monitor resource utilization and performance.

### Amazon SNS

Amazon Simple Notification Service delivers notifications when CloudWatch alarms are triggered.

Example scenarios:
- High EC2 CPU utilization.
- Application health check failures.
- Infrastructure performance issues.
- Other configured monitoring events.

This allows administrators to respond quickly to infrastructure problems.

---

## 8. Application Request Flow

The application request follows this sequence:

1. Users access the application through their domain name.
2. Amazon Route 53 resolves the domain.
3. Amazon CloudFront receives the request.
4. CloudFront serves cached static assets when available.
5. Requests requiring the application origin continue through the configured security and origin path.
6. AWS WAF inspects incoming requests.
7. The Application Load Balancer receives application traffic.
8. The ALB distributes requests across healthy EC2 instances.
9. EC2 instances process application requests.
10. Application instances communicate with Amazon RDS PostgreSQL when database operations are required.
11. CloudWatch collects monitoring metrics and logs.
12. CloudWatch alarms can trigger Amazon SNS notifications.

---

## 9. High Availability and Fault Tolerance

High availability is achieved through several architectural decisions:

**Multi-AZ Deployment**
- Application instances run across two Availability Zones.
- The ALB distributes traffic across available application instances.
- NAT Gateways provide outbound connectivity in both Availability Zones.
- Amazon RDS uses Multi-AZ deployment for database availability.

**Health Checks**
- ALB continuously checks the health of registered application targets.
- Unhealthy targets are removed from traffic distribution.
- Auto Scaling can replace unhealthy EC2 instances.

**Fault Tolerance**

If one Availability Zone experiences an outage, the architecture is designed to continue serving traffic through resources in the remaining Availability Zone, subject to available capacity and database failover.

---

## 10. Scalability

The architecture supports horizontal scaling through EC2 Auto Scaling Groups.

When application traffic increases:
- Auto Scaling launches additional EC2 instances.
- The new instances become registered targets after passing health checks.
- The ALB distributes traffic across healthy instances.

When traffic decreases:
- Auto Scaling can reduce the number of EC2 instances.
- Infrastructure costs can be optimized according to demand.

CloudFront also helps reduce origin traffic by caching static content.

---

## 11. Architecture Benefits

| Feature | AWS Service | Benefit |
|---|---|---|
| DNS Management | Route 53 | Domain resolution |
| Global Delivery | CloudFront | Reduced latency |
| Web Security | AWS WAF | Application protection |
| Load Balancing | ALB | Traffic distribution |
| Compute | EC2 | Application hosting |
| Auto Scaling | EC2 Auto Scaling | Dynamic capacity |
| Networking | Amazon VPC | Network isolation |
| Outbound Connectivity | NAT Gateway | Private subnet internet access |
| Database | Amazon RDS | Managed PostgreSQL |
| Monitoring | CloudWatch | Metrics, logs, alarms |
| Notifications | Amazon SNS | Alert delivery |
| Secure Access | Systems Manager | Bastion-less administration |

---

## 12. Conclusion

This architecture demonstrates how AWS services can work together to build a scalable, highly available, and secure web application.

By combining Application Load Balancer, EC2 Auto Scaling, Multi-AZ deployment, Amazon CloudFront, AWS WAF, and Amazon RDS, the infrastructure provides a foundation for reliable application hosting.

The design also incorporates monitoring, security controls, and centralized administrative access to support operational reliability and infrastructure management.

The architecture follows important AWS Well-Architected principles, particularly:

- Operational Excellence.
- Security.
- Reliability.
- Performance Efficiency.
- Cost Optimization.
