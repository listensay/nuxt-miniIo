# MinIO 风格文件管理系统 - API 设计文档

## 概述

本文档描述了基于 MinIO 对象存储系统设计的 RESTful API 接口。API 设计遵循 S3 兼容标准，支持标准的对象存储操作。

## 认证方式

### 1. Access Key 认证

```http
Authorization: AWS4-HMAC-SHA256 Credential=AKIAIOSFODNN7EXAMPLE/20230716/us-east-1/s3/aws4_request, SignedHeaders=host;range;x-amz-date, Signature=fe5f80f77d5fa3beca038a248ff027d0445342fe2855ddc963176630326f1024
```

### 2. Bearer Token 认证

```http
Authorization: Bearer <jwt_token>
```

## API 端点

### 基础 URL

```
https://api.example.com/v1
```

## 用户管理 API

### 1. 用户注册

```http
POST /auth/register
Content-Type: application/json

{
  "username": "john_doe",
  "email": "john@example.com",
  "password": "secure_password",
  "displayName": "John Doe"
}
```

**响应**:
```json
{
  "success": true,
  "data": {
    "id": "user_123",
    "username": "john_doe",
    "email": "john@example.com",
    "displayName": "John Doe",
    "isActive": true,
    "createdAt": "2025-07-16T10:00:00Z"
  }
}
```

### 2. 用户登录

```http
POST /auth/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "secure_password"
}
```

**响应**:
```json
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": "user_123",
      "username": "john_doe",
      "email": "john@example.com"
    }
  }
}
```

### 3. 获取用户信息

```http
GET /users/me
Authorization: Bearer <token>
```

## 访问密钥管理 API

### 1. 创建访问密钥

```http
POST /access-keys
Authorization: Bearer <token>
Content-Type: application/json

{
  "description": "API access for mobile app"
}
```

**响应**:
```json
{
  "success": true,
  "data": {
    "id": "key_123",
    "accessKey": "AKIAIOSFODNN7EXAMPLE",
    "secretKey": "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY",
    "description": "API access for mobile app",
    "isActive": true,
    "createdAt": "2025-07-16T10:00:00Z"
  }
}
```

### 2. 列出访问密钥

```http
GET /access-keys
Authorization: Bearer <token>
```

### 3. 删除访问密钥

```http
DELETE /access-keys/{keyId}
Authorization: Bearer <token>
```

## 存储桶管理 API

### 1. 创建存储桶

```http
PUT /buckets/{bucketName}
Authorization: AWS4-HMAC-SHA256 ...
Content-Type: application/json

{
  "displayName": "My Documents",
  "description": "Personal document storage",
  "region": "us-east-1",
  "versioning": true,
  "encryption": false,
  "isPublic": false
}
```

**响应**:
```json
{
  "success": true,
  "data": {
    "id": "bucket_123",
    "name": "my-documents",
    "displayName": "My Documents",
    "region": "us-east-1",
    "versioning": true,
    "createdAt": "2025-07-16T10:00:00Z"
  }
}
```

### 2. 列出存储桶

```http
GET /buckets
Authorization: AWS4-HMAC-SHA256 ...
```

**响应**:
```json
{
  "success": true,
  "data": {
    "buckets": [
      {
        "name": "my-documents",
        "createdAt": "2025-07-16T10:00:00Z"
      }
    ]
  }
}
```

### 3. 获取存储桶信息

```http
HEAD /buckets/{bucketName}
Authorization: AWS4-HMAC-SHA256 ...
```

### 4. 删除存储桶

```http
DELETE /buckets/{bucketName}
Authorization: AWS4-HMAC-SHA256 ...
```

### 5. 设置存储桶策略

```http
PUT /buckets/{bucketName}/policy
Authorization: AWS4-HMAC-SHA256 ...
Content-Type: application/json

{
  "effect": "Allow",
  "actions": ["s3:GetObject"],
  "resources": ["my-documents/*"],
  "condition": {
    "IpAddress": {
      "aws:SourceIp": "192.168.1.0/24"
    }
  }
}
```

### 6. 获取存储桶策略

```http
GET /buckets/{bucketName}/policy
Authorization: AWS4-HMAC-SHA256 ...
```

## 对象管理 API

### 1. 上传对象

```http
PUT /buckets/{bucketName}/objects/{objectKey}
Authorization: AWS4-HMAC-SHA256 ...
Content-Type: image/jpeg
Content-Length: 1024
x-amz-meta-author: John Doe

[binary data]
```

**响应**:
```json
{
  "success": true,
  "data": {
    "etag": "d41d8cd98f00b204e9800998ecf8427e",
    "versionId": "version_123"
  }
}
```

### 2. 下载对象

```http
GET /buckets/{bucketName}/objects/{objectKey}
Authorization: AWS4-HMAC-SHA256 ...
```

**响应头**:
```http
Content-Type: image/jpeg
Content-Length: 1024
ETag: "d41d8cd98f00b204e9800998ecf8427e"
Last-Modified: Tue, 16 Jul 2025 10:00:00 GMT
x-amz-meta-author: John Doe
```

### 3. 列出对象

```http
GET /buckets/{bucketName}/objects
Authorization: AWS4-HMAC-SHA256 ...
?prefix=documents/
&delimiter=/
&max-keys=1000
&marker=documents/file1.txt
```

**响应**:
```json
{
  "success": true,
  "data": {
    "name": "my-documents",
    "prefix": "documents/",
    "marker": "",
    "maxKeys": 1000,
    "isTruncated": false,
    "contents": [
      {
        "key": "documents/file1.txt",
        "lastModified": "2025-07-16T10:00:00Z",
        "etag": "d41d8cd98f00b204e9800998ecf8427e",
        "size": 1024,
        "storageClass": "STANDARD"
      }
    ],
    "commonPrefixes": [
      {
        "prefix": "documents/images/"
      }
    ]
  }
}
```

### 4. 获取对象元数据

```http
HEAD /buckets/{bucketName}/objects/{objectKey}
Authorization: AWS4-HMAC-SHA256 ...
```

### 5. 删除对象

```http
DELETE /buckets/{bucketName}/objects/{objectKey}
Authorization: AWS4-HMAC-SHA256 ...
```

### 6. 复制对象

```http
PUT /buckets/{destBucket}/objects/{destKey}
Authorization: AWS4-HMAC-SHA256 ...
x-amz-copy-source: /source-bucket/source-key
```

## 分片上传 API

### 1. 初始化分片上传

```http
POST /buckets/{bucketName}/objects/{objectKey}?uploads
Authorization: AWS4-HMAC-SHA256 ...
Content-Type: video/mp4
```

**响应**:
```json
{
  "success": true,
  "data": {
    "uploadId": "upload_123",
    "bucket": "my-videos",
    "key": "movie.mp4"
  }
}
```

### 2. 上传分片

```http
PUT /buckets/{bucketName}/objects/{objectKey}?partNumber=1&uploadId=upload_123
Authorization: AWS4-HMAC-SHA256 ...
Content-Length: 5242880

[binary data]
```

**响应**:
```json
{
  "success": true,
  "data": {
    "etag": "d41d8cd98f00b204e9800998ecf8427e"
  }
}
```

### 3. 完成分片上传

```http
POST /buckets/{bucketName}/objects/{objectKey}?uploadId=upload_123
Authorization: AWS4-HMAC-SHA256 ...
Content-Type: application/xml

<CompleteMultipartUpload>
  <Part>
    <PartNumber>1</PartNumber>
    <ETag>d41d8cd98f00b204e9800998ecf8427e</ETag>
  </Part>
  <Part>
    <PartNumber>2</PartNumber>
    <ETag>e2fc714c4727ee9395f324cd2e7f331f</ETag>
  </Part>
</CompleteMultipartUpload>
```

### 4. 取消分片上传

```http
DELETE /buckets/{bucketName}/objects/{objectKey}?uploadId=upload_123
Authorization: AWS4-HMAC-SHA256 ...
```

### 5. 列出分片

```http
GET /buckets/{bucketName}/objects/{objectKey}?uploadId=upload_123
Authorization: AWS4-HMAC-SHA256 ...
```

## 版本控制 API

### 1. 列出对象版本

```http
GET /buckets/{bucketName}/objects/{objectKey}?versions
Authorization: AWS4-HMAC-SHA256 ...
```

**响应**:
```json
{
  "success": true,
  "data": {
    "versions": [
      {
        "versionId": "version_123",
        "isLatest": true,
        "lastModified": "2025-07-16T10:00:00Z",
        "etag": "d41d8cd98f00b204e9800998ecf8427e",
        "size": 1024
      }
    ]
  }
}
```

### 2. 获取特定版本

```http
GET /buckets/{bucketName}/objects/{objectKey}?versionId=version_123
Authorization: AWS4-HMAC-SHA256 ...
```

### 3. 删除特定版本

```http
DELETE /buckets/{bucketName}/objects/{objectKey}?versionId=version_123
Authorization: AWS4-HMAC-SHA256 ...
```

## 标签管理 API

### 1. 设置对象标签

```http
PUT /buckets/{bucketName}/objects/{objectKey}?tagging
Authorization: AWS4-HMAC-SHA256 ...
Content-Type: application/xml

<Tagging>
  <TagSet>
    <Tag>
      <Key>Department</Key>
      <Value>Engineering</Value>
    </Tag>
    <Tag>
      <Key>Project</Key>
      <Value>WebApp</Value>
    </Tag>
  </TagSet>
</Tagging>
```

### 2. 获取对象标签

```http
GET /buckets/{bucketName}/objects/{objectKey}?tagging
Authorization: AWS4-HMAC-SHA256 ...
```

### 3. 删除对象标签

```http
DELETE /buckets/{bucketName}/objects/{objectKey}?tagging
Authorization: AWS4-HMAC-SHA256 ...
```

## 预签名 URL API

### 1. 生成预签名上传 URL

```http
POST /presigned-urls/upload
Authorization: Bearer <token>
Content-Type: application/json

{
  "bucket": "my-documents",
  "key": "document.pdf",
  "contentType": "application/pdf",
  "expiresIn": 3600
}
```

**响应**:
```json
{
  "success": true,
  "data": {
    "url": "https://api.example.com/buckets/my-documents/objects/document.pdf?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=...",
    "fields": {
      "key": "document.pdf",
      "Content-Type": "application/pdf"
    },
    "expiresAt": "2025-07-16T11:00:00Z"
  }
}
```

### 2. 生成预签名下载 URL

```http
POST /presigned-urls/download
Authorization: Bearer <token>
Content-Type: application/json

{
  "bucket": "my-documents",
  "key": "document.pdf",
  "expiresIn": 3600
}
```

## 统计和监控 API

### 1. 获取存储桶统计

```http
GET /buckets/{bucketName}/stats
Authorization: Bearer <token>
```

**响应**:
```json
{
  "success": true,
  "data": {
    "objectCount": 1250,
    "totalSize": 1073741824,
    "lastModified": "2025-07-16T10:00:00Z",
    "storageClasses": {
      "STANDARD": 1000,
      "GLACIER": 250
    }
  }
}
```

### 2. 获取用户配额

```http
GET /users/me/quota
Authorization: Bearer <token>
```

**响应**:
```json
{
  "success": true,
  "data": {
    "used": 5368709120,
    "limit": 10737418240,
    "bucketCount": 5,
    "bucketLimit": 100
  }
}
```

## 操作日志 API

### 1. 获取操作日志

```http
GET /activity-logs
Authorization: Bearer <token>
?startDate=2025-07-01T00:00:00Z
&endDate=2025-07-16T23:59:59Z
&action=CREATE
&resource=OBJECT
&limit=100
&offset=0
```

**响应**:
```json
{
  "success": true,
  "data": {
    "logs": [
      {
        "id": "log_123",
        "action": "CREATE",
        "resource": "OBJECT",
        "resourceId": "object_456",
        "details": {
          "bucket": "my-documents",
          "key": "document.pdf",
          "size": 1024
        },
        "ipAddress": "192.168.1.100",
        "userAgent": "Mozilla/5.0...",
        "createdAt": "2025-07-16T10:00:00Z",
        "userId": "user_123"
      }
    ],
    "total": 1,
    "limit": 100,
    "offset": 0
  }
}
```

## 错误响应格式

### 标准错误响应

```json
{
  "success": false,
  "error": {
    "code": "BUCKET_NOT_FOUND",
    "message": "The specified bucket does not exist",
    "details": {
      "bucket": "non-existent-bucket"
    }
  }
}
```

### 常见错误代码

| 错误代码 | HTTP 状态码 | 描述 |
|----------|-------------|------|
| INVALID_REQUEST | 400 | 请求参数无效 |
| UNAUTHORIZED | 401 | 未授权访问 |
| FORBIDDEN | 403 | 权限不足 |
| NOT_FOUND | 404 | 资源不存在 |
| CONFLICT | 409 | 资源冲突 |
| PAYLOAD_TOO_LARGE | 413 | 文件过大 |
| QUOTA_EXCEEDED | 429 | 配额超限 |
| INTERNAL_ERROR | 500 | 服务器内部错误 |

## 限流和配额

### 1. API 限流

- 每个用户每分钟最多 1000 次请求
- 每个 IP 每分钟最多 5000 次请求
- 上传操作每分钟最多 100 次

### 2. 存储配额

- 免费用户：10GB 存储空间，100 个存储桶
- 付费用户：根据订阅计划确定

## 安全考虑

### 1. HTTPS 强制

所有 API 请求必须使用 HTTPS 协议。

### 2. 请求签名

支持 AWS Signature Version 4 签名算法。

### 3. 跨域资源共享 (CORS)

```http
Access-Control-Allow-Origin: https://app.example.com
Access-Control-Allow-Methods: GET, POST, PUT, DELETE, HEAD
Access-Control-Allow-Headers: Authorization, Content-Type, x-amz-*
```

---

**文档版本**: 1.0
**创建日期**: 2025-07-16
**最后更新**: 2025-07-16
