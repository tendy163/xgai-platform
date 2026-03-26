# XG-AI Platform - TypeScript Monorepo

## 🚀 项目概述
XG-AI是一个基于TypeScript的智能量化分析平台，采用微服务架构设计。

## 📁 项目结构
```
xgai-platform/
├── packages/              # 微服务包
│   ├── api-gateway/      # API网关服务
│   ├── auth-service/     # 认证服务
│   ├── chat-service/     # 对话服务
│   ├── quant-service/    # 量化分析服务
│   ├── client-service/   # 客户端服务
│   └── notify-service/   # 通知服务
├── docker-compose.yml    # Docker编排配置
├── database_schema.prisma # 数据库Schema
├── deploy.sh            # 部署脚本
├── openapi_spec_complete_v1.0.yaml # OpenAPI规范
└── README.md            # 项目文档
```

## 🛠️ 技术栈
- **语言**: TypeScript 5.0+
- **运行时**: Node.js 18+
- **框架**: Hono (轻量级Web框架)
- **数据库**: PostgreSQL + Redis
- **消息队列**: RabbitMQ
- **容器化**: Docker + Docker Compose
- **API规范**: OpenAPI 3.0.3

## 🔧 快速开始
```bash
# 安装依赖
npm install

# 启动开发环境
docker-compose up -d

# 运行所有服务
npm run dev
```

## 📄 API文档
完整API规范见 `openapi_spec_complete_v1.0.yaml`

## 🤝 贡献指南
1. Fork仓库
2. 创建功能分支
3. 提交更改
4. 发起Pull Request

## 📝 许可证
MIT License