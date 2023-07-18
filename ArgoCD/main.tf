# Crear el espacio de nombres de ArgoCD
resource "kubernetes_namespace" "argocd_namespace" {
  metadata {
    name = "argocd"
  }
}

# Instalar ArgoCD en el espacio de nombres de ArgoCD
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "2.1.6"
  namespace  = kubernetes_namespace.argocd_namespace.metadata.0.name
}

# Crear el balanceador de carga para el acceso externo a ArgoCD
resource "aws_lb" "argocd_lb" {
  name               = "argocd-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = ["subnet-xxx", "subnet-yyy"]  # Reemplazar con los identificadores de las subredes adecuadas

  tags = {
    Name = "argocd-lb"
  }
}

# Crear el grupo de destino del balanceador de carga
resource "aws_lb_target_group" "argocd_lb_target_group" {
  name        = "argocd-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = "vpc-xxx"  # Reemplazar con el identificador de la VPC adecuada

  health_check {
    healthy_threshold   = 3
    interval            = 30
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 3
  }

  tags = {
    Name = "argocd-tg"
  }
}

# Asociar el grupo de destino con el balanceador de carga
resource "aws_lb_listener" "argocd_lb_listener" {
  load_balancer_arn = aws_lb.argocd_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.argocd_lb_target_group.arn
  }
}

# Obtener las credenciales de ArgoCD
data "aws_lb" "argocd_lb_data" {
  arn = aws_lb.argocd_lb.arn
}

output "argocd_credentials" {
  value = "Username: admin\nPassword: ${data.aws_lb.argocd_lb_data.dns_name}"
}