#!/bin/bash
# XG-AI Platform Deployment Script
# Version: 1.0.0
# Usage: ./deploy.sh [--all|--service SERVICE_NAME]

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
NETWORK_NAME="xgai-network"
COMPOSE_FILE="docker-compose.yml"

# Function to print colored messages
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check dependencies
check_dependencies() {
    log_info "Checking dependencies..."
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    # Check Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        # Try docker compose (v2)
        if ! docker compose version &> /dev/null; then
            log_error "Docker Compose is not installed. Please install Docker Compose first."
            exit 1
        fi
        COMPOSE_CMD="docker compose"
    else
        COMPOSE_CMD="docker-compose"
    fi
    
    log_info "Dependencies check passed"
}

# Create Docker network
create_network() {
    log_info "Creating Docker network: $NETWORK_NAME"
    
    if docker network ls | grep -q "$NETWORK_NAME"; then
        log_warn "Network $NETWORK_NAME already exists"
    else
        docker network create "$NETWORK_NAME" || {
            log_error "Failed to create network $NETWORK_NAME"
            exit 1
        }
        log_info "Network $NETWORK_NAME created successfully"
    fi
}

# Start all services
start_all() {
    log_info "Starting all services..."
    
    check_dependencies
    create_network
    
    log_info "Building and starting services with Docker Compose..."
    $COMPOSE_CMD -f "$COMPOSE_FILE" up --build -d
    
    if [ $? -eq 0 ]; then
        log_info "All services started successfully"
        show_service_status
    else
        log_error "Failed to start services"
        exit 1
    fi
}

# Stop all services
stop_all() {
    log_info "Stopping all services..."
    
    $COMPOSE_CMD -f "$COMPOSE_FILE" down
    
    log_info "All services stopped"
}

# Restart all services
restart_all() {
    log_info "Restarting all services..."
    
    stop_all
    start_all
}

# Show service status
show_service_status() {
    log_info "Service Status:"
    echo ""
    
    # Check each service
    services=("postgres" "redis" "rabbitmq" "api-gateway" "auth-service" "chat-service" "quant-service" "client-service" "notify-service")
    
    for service in "${services[@]}"; do
        container_id=$($COMPOSE_CMD -f "$COMPOSE_FILE" ps -q "$service" 2>/dev/null)
        
        if [ -n "$container_id" ]; then
            status=$(docker inspect -f '{{.State.Status}}' "$container_id" 2>/dev/null)
            health=$(docker inspect -f '{{.State.Health.Status}}' "$container_id" 2>/dev/null 2>/dev/null || echo "N/A")
            
            if [ "$status" = "running" ]; then
                if [ "$health" = "healthy" ] || [ "$health" = "N/A" ]; then
                    echo -e "  ${GREEN}✓${NC} $service: Running ($health)"
                else
                    echo -e "  ${YELLOW}⚠${NC} $service: Running ($health)"
                fi
            else
                echo -e "  ${RED}✗${NC} $service: $status"
            fi
        else
            echo -e "  ${RED}✗${NC} $service: Not running"
        fi
    done
    
    echo ""
    log_info "API Gateway: http://localhost:3011"
    log_info "Auth Service: http://localhost:3006"
    log_info "PostgreSQL: localhost:5432"
    log_info "Redis: localhost:6379"
    log_info "RabbitMQ Management: http://localhost:15672 (guest/guest)"
}

# Clean up (remove containers, networks, volumes)
cleanup() {
    log_warn "This will remove ALL containers, networks, and volumes. Are you sure? (y/N)"
    read -r confirmation
    
    if [ "$confirmation" = "y" ] || [ "$confirmation" = "Y" ]; then
        log_info "Cleaning up all Docker resources..."
        $COMPOSE_CMD -f "$COMPOSE_FILE" down -v --rmi all
        
        # Remove network
        if docker network ls | grep -q "$NETWORK_NAME"; then
            docker network rm "$NETWORK_NAME"
        fi
        
        log_info "Cleanup completed"
    else
        log_info "Cleanup cancelled"
    fi
}

# Help message
show_help() {
    cat << EOF
Usage: $0 [OPTION]

XG-AI Platform Deployment Script

Options:
  --all           Start all services (default)
  --stop          Stop all services
  --restart       Restart all services
  --status        Show service status
  --cleanup       Remove all containers, networks, and volumes
  --help          Show this help message

Examples:
  $0 --all        # Start all services
  $0 --status     # Show service status
  $0 --restart    # Restart all services

Environment:
  Make sure Docker and Docker Compose are installed before running this script.
EOF
}

# Main script logic
main() {
    case "${1:---all}" in
        --all)
            start_all
            ;;
        --stop)
            stop_all
            ;;
        --restart)
            restart_all
            ;;
        --status)
            show_service_status
            ;;
        --cleanup)
            cleanup
            ;;
        --help|-h)
            show_help
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"