/*
  Warnings:

  - You are about to drop the `Post` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `User` table. If the table is not empty, all the data it contains will be lost.

*/
-- DropTable
PRAGMA foreign_keys=off;
DROP TABLE "Post";
PRAGMA foreign_keys=on;

-- DropTable
PRAGMA foreign_keys=off;
DROP TABLE "User";
PRAGMA foreign_keys=on;

-- CreateTable
CREATE TABLE "users" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "username" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "password" TEXT NOT NULL,
    "displayName" TEXT,
    "avatar" TEXT,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "isAdmin" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);

-- CreateTable
CREATE TABLE "access_keys" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "accessKey" TEXT NOT NULL,
    "secretKey" TEXT NOT NULL,
    "description" TEXT,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "expiresAt" DATETIME,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    "userId" TEXT NOT NULL,
    CONSTRAINT "access_keys_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "buckets" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL,
    "displayName" TEXT,
    "description" TEXT,
    "region" TEXT NOT NULL DEFAULT 'us-east-1',
    "versioning" BOOLEAN NOT NULL DEFAULT false,
    "encryption" BOOLEAN NOT NULL DEFAULT false,
    "isPublic" BOOLEAN NOT NULL DEFAULT false,
    "maxSize" BIGINT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    "ownerId" TEXT NOT NULL,
    CONSTRAINT "buckets_ownerId_fkey" FOREIGN KEY ("ownerId") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "bucket_tags" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "key" TEXT NOT NULL,
    "value" TEXT NOT NULL,
    "bucketId" TEXT NOT NULL,
    CONSTRAINT "bucket_tags_bucketId_fkey" FOREIGN KEY ("bucketId") REFERENCES "buckets" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "objects" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "key" TEXT NOT NULL,
    "originalName" TEXT NOT NULL,
    "mimeType" TEXT NOT NULL,
    "size" BIGINT NOT NULL,
    "etag" TEXT NOT NULL,
    "storageClass" TEXT NOT NULL DEFAULT 'STANDARD',
    "isDirectory" BOOLEAN NOT NULL DEFAULT false,
    "metadata" JSONB,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    "bucketId" TEXT NOT NULL,
    "uploaderId" TEXT NOT NULL,
    CONSTRAINT "objects_bucketId_fkey" FOREIGN KEY ("bucketId") REFERENCES "buckets" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "objects_uploaderId_fkey" FOREIGN KEY ("uploaderId") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "object_versions" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "versionId" TEXT NOT NULL,
    "size" BIGINT NOT NULL,
    "etag" TEXT NOT NULL,
    "storageClass" TEXT NOT NULL DEFAULT 'STANDARD',
    "isLatest" BOOLEAN NOT NULL DEFAULT false,
    "isDeleted" BOOLEAN NOT NULL DEFAULT false,
    "metadata" JSONB,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "objectId" TEXT NOT NULL,
    CONSTRAINT "object_versions_objectId_fkey" FOREIGN KEY ("objectId") REFERENCES "objects" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "object_tags" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "key" TEXT NOT NULL,
    "value" TEXT NOT NULL,
    "objectId" TEXT NOT NULL,
    CONSTRAINT "object_tags_objectId_fkey" FOREIGN KEY ("objectId") REFERENCES "objects" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "bucket_policies" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "effect" TEXT NOT NULL,
    "actions" JSONB NOT NULL,
    "resources" JSONB NOT NULL,
    "condition" JSONB,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    "bucketId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    CONSTRAINT "bucket_policies_bucketId_fkey" FOREIGN KEY ("bucketId") REFERENCES "buckets" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "bucket_policies_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "upload_sessions" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "uploadId" TEXT NOT NULL,
    "objectKey" TEXT NOT NULL,
    "totalSize" BIGINT,
    "uploadedSize" BIGINT NOT NULL DEFAULT 0,
    "partCount" INTEGER NOT NULL DEFAULT 0,
    "isCompleted" BOOLEAN NOT NULL DEFAULT false,
    "expiresAt" DATETIME NOT NULL,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    "bucketId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    CONSTRAINT "upload_sessions_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "upload_parts" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "partNumber" INTEGER NOT NULL,
    "size" BIGINT NOT NULL,
    "etag" TEXT NOT NULL,
    "uploadedAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "sessionId" TEXT NOT NULL,
    CONSTRAINT "upload_parts_sessionId_fkey" FOREIGN KEY ("sessionId") REFERENCES "upload_sessions" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "activity_logs" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "action" TEXT NOT NULL,
    "resource" TEXT NOT NULL,
    "resourceId" TEXT NOT NULL,
    "details" JSONB,
    "ipAddress" TEXT,
    "userAgent" TEXT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "userId" TEXT
);

-- CreateIndex
CREATE UNIQUE INDEX "users_username_key" ON "users"("username");

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE UNIQUE INDEX "access_keys_accessKey_key" ON "access_keys"("accessKey");

-- CreateIndex
CREATE UNIQUE INDEX "buckets_name_key" ON "buckets"("name");

-- CreateIndex
CREATE UNIQUE INDEX "bucket_tags_bucketId_key_key" ON "bucket_tags"("bucketId", "key");

-- CreateIndex
CREATE UNIQUE INDEX "objects_bucketId_key_key" ON "objects"("bucketId", "key");

-- CreateIndex
CREATE UNIQUE INDEX "object_versions_versionId_key" ON "object_versions"("versionId");

-- CreateIndex
CREATE UNIQUE INDEX "object_tags_objectId_key_key" ON "object_tags"("objectId", "key");

-- CreateIndex
CREATE UNIQUE INDEX "upload_sessions_uploadId_key" ON "upload_sessions"("uploadId");

-- CreateIndex
CREATE UNIQUE INDEX "upload_parts_sessionId_partNumber_key" ON "upload_parts"("sessionId", "partNumber");
