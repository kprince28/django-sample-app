# Django Sample App - Docker & Kubernetes Learning 🐍🐳

[![Docker Hub](https://img.shields.io/docker/pulls/deskpkumar/django-sample-app?logo=docker)](https://hub.docker.com/r/deskpkumar/django-sample-app)
[![GitHub Stars](https://img.shields.io/github/stars/kprince28/django-sample-app?logo=github)](https://github.com/kprince28/django-sample-app)
[![Python 3.12](https://img.shields.io/badge/python-3.12-blue.svg)](https://python.org)
[![Django 5.0](https://img.shields.io/badge/django-5.0-green.svg)](https://djangoproject.com)

> **🎓 Educational Project:** A beginner-friendly Django application specifically designed for learning Docker, Kubernetes, and containerization concepts with real-world database integration patterns.

## 🎯 Learning Objectives

This project helps you master:

- **🐳 Docker fundamentals** - Containerizing Python/Django applications
- **☸️ Kubernetes basics** - Deploying containers in production
- **🔧 Environment management** - Configuration with environment variables  
- **🗄️ Database integration** - SQLite to PostgreSQL migration patterns
- **🛡️ Container security** - Non-root users, secure configurations
- **📦 Multi-stage deployments** - Development to production workflows

## 🚀 Quick Start

### Method 1: Docker Hub (Fastest)

```bash
# Simple run with SQLite
docker run -p 8000:8000 deskpkumar/django-sample-app:latest

# Open: http://localhost:8000
```

### Method 2: Build from Source

```bash
git clone https://github.com/kprince28/django-sample-app.git
cd django-sample-app
docker build -t django-learning .
docker run -p 8000:8000 django-learning
```

## 📚 Learning Path

### 🔰 Beginner: Basic Containerization

**Goal:** Understand how Django runs in containers

```bash
# 1. Pull and run the basic container
docker run -p 8000:8000 deskpkumar/django-sample-app:latest

# 2. Explore the container
docker exec -it container_name bash
ls -la /app
whoami  # You'll see 'appuser' - non-root execution!

# 3. Check the database
docker exec -it container_name python manage.py dbshell
```

**Learning points:**
- Container isolation and port mapping
- Non-root user security
- File system structure in containers

### 🎓 Intermediate: Environment Configuration

**Goal:** Learn environment variable management

```bash
# 1. Copy environment template
cp .env.sample .env

# 2. Generate secure secret key
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"

# 3. Edit .env with your values
SECRET_KEY=your-generated-secret-key-here
DEBUG=False
ALLOWED_HOSTS=localhost,127.0.0.1

# 4. Run with environment file
docker run --env-file .env -p 8000:8000 deskpkumar/django-sample-app:latest
```

**Learning points:**
- Environment variable precedence (.env vs OS env)
- Security implications of DEBUG mode
- Host restrictions for production

### 🏆 Advanced: Database Integration

**Goal:** Master database configuration patterns

```bash
# 1. Run PostgreSQL container
docker run -d --name learning-postgres \
  -e POSTGRES_DB=django_learning \
  -e POSTGRES_USER=student \
  -e POSTGRES_PASSWORD=learning123 \
  postgres:15-alpine

# 2. Connect Django to PostgreSQL
docker run -p 8000:8000 \
  --link learning-postgres:postgres \
  -e DB_ENGINE=postgresql \
  -e DB_NAME=django_learning \
  -e DB_USER=student \
  -e DB_PASSWORD=learning123 \
  -e DB_HOST=postgres \
  deskpkumar/django-sample-app:latest
```

**Learning points:**
- Container networking and linking
- Database connection configuration
- Environment-based service discovery

## 🛠️ Development Setup

### Prerequisites
- Docker installed
- Git installed
- Basic command line knowledge

### Local Development

```bash
# 1. Clone the repository
git clone https://github.com/kprince28/django-sample-app.git
cd django-sample-app

# 2. Create your environment file
cp .env.sample .env

# 3. Generate a secure secret key
python3 -c "import secrets; print(secrets.token_urlsafe(50))"

# 4. Update .env with your values
cat > .env << EOF
SECRET_KEY=your-secret-key-here
DEBUG=True
ALLOWED_HOSTS=localhost,127.0.0.1,0.0.0.0
DB_ENGINE=sqlite
EOF

# 5. Build and run
docker build -t django-learning .
docker run --env-file .env -p 8000:8000 django-learning
```

### With PostgreSQL (Full Stack Learning)

```bash
# 1. Use Docker Compose for full stack
cat > docker-compose.yml << EOF
version: '3.8'

services:
  django:
    build: .
    ports:
      - "8000:8000"
    environment:
      - SECRET_KEY=learning-secret-key-not-for-production
      - DEBUG=True
      - DB_ENGINE=postgresql
      - DB_NAME=django_learning
      - DB_USER=postgres
      - DB_PASSWORD=postgres123
      - DB_HOST=postgres
      - ALLOWED_HOSTS=localhost,127.0.0.1
    depends_on:
      postgres:
        condition: service_healthy

  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: django_learning
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres123
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5

volumes:
  postgres_data:
EOF

# 2. Start the full stack
docker-compose up --build
```

## ☸️ Kubernetes Learning

### Basic Deployment

```yaml
# k8s-basic.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: django-learning-app
  labels:
    app: django-learning
spec:
  replicas: 2
  selector:
    matchLabels:
      app: django-learning
  template:
    metadata:
      labels:
        app: django-learning
    spec:
      containers:
      - name: django
        image: deskpkumar/django-sample-app:latest
        ports:
        - containerPort: 8000
        env:
        - name: SECRET_KEY
          value: "k8s-learning-secret-change-in-production"
        - name: DEBUG
          value: "True"
        - name: ALLOWED_HOSTS
          value: "*"
---
apiVersion: v1
kind: Service
metadata:
  name: django-learning-service
spec:
  selector:
    app: django-learning
  ports:
  - port: 80
    targetPort: 8000
  type: LoadBalancer
```

**Deploy to Kubernetes:**
```bash
# Apply the configuration
kubectl apply -f k8s-basic.yaml

# Check deployment status
kubectl get deployments
kubectl get pods
kubectl get services

# Get external IP (if using cloud provider)
kubectl get services django-learning-service
```

### Advanced: ConfigMaps and Secrets

```yaml
# k8s-advanced.yaml
apiVersion: v1
kind: Secret
metadata:
  name: django-secrets
type: Opaque
stringData:
  secret-key: "your-super-secret-key-here"
  db-password: "secure-db-password"
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: django-config
data:
  DEBUG: "False"
  ALLOWED_HOSTS: "your-domain.com,www.your-domain.com"
  DB_ENGINE: "postgresql"
  DB_NAME: "production_db"
  DB_USER: "django_user"
  DB_HOST: "postgres-service"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: django-production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: django-production
  template:
    metadata:
      labels:
        app: django-production
    spec:
      containers:
      - name: django
        image: deskpkumar/django-sample-app:latest
        ports:
        - containerPort: 8000
        envFrom:
        - configMapRef:
            name: django-config
        env:
        - name: SECRET_KEY
          valueFrom:
            secretKeyRef:
              name: django-secrets
              key: secret-key
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: django-secrets
              key: db-password
```

## 🔧 Configuration Reference

### Environment Variables

| Variable | Default | Description | Required |
|----------|---------|-------------|----------|
| `SECRET_KEY` | `django-insecure-*` | Django cryptographic key | Production: Yes |
| `DEBUG` | `True` | Enable Django debug mode | No |
| `ALLOWED_HOSTS` | `*` | Comma-separated allowed hosts | Production: Yes |
| `DB_ENGINE` | `sqlite` | Database backend (`sqlite` or `postgresql`) | No |
| `DB_NAME` | `django_db` | Database name | PostgreSQL: Yes |
| `DB_USER` | `postgres` | Database username | PostgreSQL: Yes |
| `DB_PASSWORD` | `` | Database password | PostgreSQL: Yes |
| `DB_HOST` | `localhost` | Database host | PostgreSQL: Yes |
| `DB_PORT` | `5432` | Database port | No |

### Security Best Practices

```bash
# ✅ DO: Use strong secret keys
SECRET_KEY=$(python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())")

# ✅ DO: Restrict allowed hosts in production
ALLOWED_HOSTS="yourdomain.com,www.yourdomain.com"

# ✅ DO: Disable debug in production
DEBUG=False

# ❌ DON'T: Use default values in production
# SECRET_KEY=django-insecure-change-me-in-production  # BAD!
# DEBUG=True  # BAD in production!
# ALLOWED_HOSTS=*  # BAD in production!
```

## 📊 Project Structure

```
django-sample-app/
├── app/                    # Django project directory
│   ├── __init__.py
│   ├── settings.py        # 🔧 Environment-aware configuration
│   ├── urls.py
│   └── wsgi.py
├── manage.py              # Django management script
├── requirements.txt       # Python dependencies
├── Dockerfile            # 🐳 Container configuration
├── .env.sample           # Environment template
├── docker-compose.yml    # Full stack setup
└── README.md            # This file
```

## 🐛 Troubleshooting Guide

### Container Issues

**Problem:** Container exits immediately
```bash
# Check logs
docker logs container_name

# Common solutions:
# 1. Missing SECRET_KEY in production (DEBUG=False)
# 2. Database connection failed
# 3. Port already in use
```

**Problem:** Database connection refused
```bash
# For PostgreSQL issues:
# 1. Check if PostgreSQL container is running
docker ps | grep postgres

# 2. Test connection
docker exec -it django_container python manage.py dbshell

# 3. Verify environment variables
docker exec -it django_container env | grep DB_
```

**Problem:** Static files not loading
```bash
# Static files are collected during build
# Rebuild if you added new static files
docker build --no-cache -t django-learning .
```

### Kubernetes Issues

**Problem:** Pods not starting
```bash
# Check pod status
kubectl describe pod pod_name

# Check events
kubectl get events --sort-by=.metadata.creationTimestamp

# Common solutions:
# 1. Image pull issues
# 2. Resource limits
# 3. ConfigMap/Secret not found
```

## 🧪 Testing & Validation

### Basic Functionality Tests

```bash
# 1. Health check
curl http://localhost:8000/

# 2. Admin interface
curl http://localhost:8000/admin/

# 3. Database connectivity (PostgreSQL)
docker exec -it container_name python manage.py dbshell
\l  # List databases
\q  # Quit
```

### Load Testing (Learning)

```bash
# Simple load test with curl
for i in {1..100}; do
  curl -s http://localhost:8000/ > /dev/null
  echo "Request $i completed"
done

# Or use Apache Bench if available
ab -n 100 -c 10 http://localhost:8000/
```

## 📈 Next Steps & Advanced Learning

### Production Readiness Checklist

- [ ] **Security:** Generate unique SECRET_KEY
- [ ] **Configuration:** Set DEBUG=False
- [ ] **Networking:** Configure proper ALLOWED_HOSTS  
- [ ] **Database:** Use managed PostgreSQL service
- [ ] **Monitoring:** Add health checks and logging
- [ ] **Scaling:** Configure horizontal pod autoscaling
- [ ] **Storage:** Use persistent volumes for media files
- [ ] **SSL:** Configure HTTPS termination

### Suggested Extensions

1. **Add Redis for caching**
2. **Implement CI/CD pipelines**
3. **Add monitoring with Prometheus**
4. **Configure log aggregation**
5. **Implement blue-green deployments**
6. **Add database migrations in init containers**

## 🤝 Contributing

This is a learning project! Contributions that help others learn are welcome:

1. **Fork** the repository
2. **Create** a learning-focused feature branch
3. **Add** educational comments to your code
4. **Test** with both SQLite and PostgreSQL
5. **Submit** a pull request with learning notes

### Ideas for Contributions

- Additional database backends (MySQL, MongoDB)
- Helm charts for Kubernetes
- CI/CD pipeline examples
- Monitoring and observability examples
- Performance optimization tutorials

## 📝 Learning Resources

### Docker & Containers
- [Docker Official Tutorial](https://docs.docker.com/get-started/)
- [Docker Best Practices](https://docs.docker.com/develop/best-practices/)

### Kubernetes
- [Kubernetes Basics](https://kubernetes.io/docs/tutorials/kubernetes-basics/)
- [Kubernetes Examples](https://github.com/kubernetes/examples)

### Django in Production
- [Django Deployment Checklist](https://docs.djangoproject.com/en/stable/howto/deployment/checklist/)
- [12-Factor App Methodology](https://12factor.net/)

## 📄 License

This project is licensed under the MIT License - perfect for educational use and modification.

## 👨‍💻 Author

**Prince Kumar**
- **GitHub:** [@kprince28](https://github.com/kprince28)
- **Docker Hub:** [deskpkumar](https://hub.docker.com/u/deskpkumar)
- **Focus:** Python backend development & DevOps learning

---

⭐ **Star this repo** if it helped you learn Docker & Kubernetes with Django!

🐳 **Quick Start:** `docker run -p 8000:8000 deskpkumar/django-sample-app:latest`

🚀 **Happy Learning!**