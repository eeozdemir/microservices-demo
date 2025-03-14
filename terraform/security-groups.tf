# Master Node SG
resource "aws_security_group" "eks_cluster_sg" {
  name        = "kl-eks-cluster-sg"
  description = "Cluster control plane SG"
  vpc_id      = aws_vpc.eks_vpc.id

  # Cluster'ın worker nodelarla iletişimi için gerekli portlar
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Control plane communication to worker nodes"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" #tüm protokoller için izin
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "kl-eks-cluster-sg"
  }
}

# Worker Node SG
resource "aws_security_group" "eks_worker_sg" {
  name        = "kl-eks-worker-sg"
  description = "Worker Nodes SG"
  vpc_id      = aws_vpc.eks_vpc.id

  # Nodeların API Server(!) ile iletişimi için gerekli olan port
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [aws_security_group.eks_cluster_sg.id]
    description = "worker nodes to communicate with master node"
  }

  # Nodelar arası tüm trafik
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    description = "Allow all traffic between worker nodes"
  }

  # Worker nodeların podlara erişimi için gerekli port
  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow worker nodes to access kubelet(!)"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "kl-eks-worker-sg"
  }
}

# Load Balancer SG
resource "aws_security_group" "lb_sg" {
  name        = "kl-lb-sg"
  description = "Load Balancer SG"
  vpc_id      = aws_vpc.eks_vpc.id

  # HTTP trafiği için
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP traffic from the internet"
  }

  # HTTPS trafiği için
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS traffic from the internet"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "kl-lb-sg"
  }
}
