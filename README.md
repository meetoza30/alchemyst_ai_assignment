# Architecture

## Infrastructure Layout

* One custom AWS VPC
* One public subnet hosting the API VM
* One private subnet hosting worker VMs
* Security groups for internal RPC communication
* Terraform-managed infrastructure provisioning

---

# Architecture Diagram
<img width="1393" height="753" alt="image" src="https://github.com/user-attachments/assets/3bd1cb7b-9a01-49b5-b077-6d549b678518" />
Video explaining assignment - https://www.youtube.com/watch?v=1ebQjwDlFk0

RPC Flow

Internet User
→ HTTP API
→ iii engine
→ caller-worker
→ inference-worker
→ response propagation back through iii engine

Workers communicate internally using private IPs over WebSocket RPC on port 49134.

---

# Infrastructure Provisioning

Infrastructure was provisioned using Terraform.

Resources created:

* VPC
* Public subnet
* Private subnet
* Route tables
* Security groups
* EC2 instances
* Internal communication rules

---

# Deployment Steps

## 1. Provision Infrastructure

```bash
terraform init
terraform apply
```

---

## 2. Start iii Engine on api-vm

```bash
iii
```

---

## 3. Run caller-worker container

```bash
docker run -d \
--name caller-worker \
-e III_URL=ws://<API_PRIVATE_IP>:49134 \
<dockerhub-username>/caller-worker:v1
```

---

## 4. Start inference worker

```bash
export III_URL=ws://<API_PRIVATE_IP>:49134

python inference_worker.py
```

---

# API Request Example

```bash
curl -X POST http://localhost:3111/v1/chat/completions \
-H "Content-Type: application/json" \
-d '{
  "messages": [
    {
      "role": "user",
      "content": "What is Docker?"
    }
  ]
}'
```

---

# Request Flow Verification

The distributed request pipeline was successfully validated.

The following stages were verified successfully:

* HTTP request received by api-vm
* caller-worker successfully connected to iii engine
* inference-worker successfully registered RPC function
* request propagation across VMs through iii RPC
* inference worker model initialization completed successfully
* distributed communication over internal VPC networking validated

The api-vm logs confirmed that the request:
"What is Docker?"
successfully reached the distributed worker system and triggered the inference pipeline.

---

# Challenges Faced

## 1. Resource Constraints on Inference Worker

The largest challenge during deployment was handling the heavy ML dependencies required for the inference worker.

The Python inference worker required:

* PyTorch
* Transformers
* GGUF runtime dependencies
* model loading and tensor conversion

On smaller EC2 instances, this caused:

* disk space exhaustion
* memory pressure
* dependency installation failures
* process termination during model loading

Initially, the inference VM ran out of disk space while installing PyTorch, resulting in repeated:

* "No space left on device"
* "Disk quota exceeded"

errors.

This was resolved by:

* increasing the EBS root volume
* expanding the filesystem manually
* upgrading the inference instance type temporarily

This highlighted a real-world operational challenge commonly faced while deploying AI workloads on cloud infrastructure.

---

## 2. Distributed Worker Coordination

Another challenge was coordinating:

* the HTTP trigger,
* TypeScript caller worker,
* and Python inference worker

across separate VMs.

This required debugging:

* worker registration
* RPC routing
* startup ordering
* distributed communication flow

The project successfully validated communication between all distributed components.

---

# Production Hardening Improvements

Before deploying this system to production, the following improvements would be implemented:

* Strict private subnet isolation for workers
* Bastion host for SSH access
* IAM roles with least-privilege permissions
* AWS Secrets Manager for credential management
* Centralized logging and monitoring
* Auto-scaling worker infrastructure
* CI/CD deployment pipeline

---

# Scaling for Models 100x Larger

If the model size increased significantly, several architectural improvements would be required.

The current CPU-based setup would not be sufficient for large-scale transformer inference.

Improvements would include:

* GPU-backed EC2 instances
* distributed model serving
* inference batching
* Kubernetes/EKS-based orchestration
* dedicated model serving frameworks
* request queues and load balancing
* caching and response optimization

Large-scale models would also require significantly more operational focus on:

* memory optimization,
* startup latency,
* GPU utilization,
* and horizontal scaling.
