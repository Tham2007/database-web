-- ============================================================
-- FILE 1: TẠO CẤU TRÚC CSDL - WEBSITE ĐẶT TOUR
-- PostgreSQL
-- Tổng hợp từ migration gốc + invariants + hardening của repo
-- ============================================================

-- Cần cho gen_random_uuid() dùng ở file 03
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ============================================================
-- 1. ENUM
-- ============================================================

CREATE TYPE "Role" AS ENUM ('CUSTOMER', 'OPERATIONS', 'ADMIN');

CREATE TYPE "TourStatus" AS ENUM ('DRAFT', 'ACTIVE', 'INACTIVE');

CREATE TYPE "ScheduleStatus" AS ENUM ('OPEN', 'CLOSED');

CREATE TYPE "BookingStatus" AS ENUM (
    'PENDING_PAYMENT',
    'PAID',
    'CONFIRMED',
    'COMPLETED',
    'CANCELLED'
);

CREATE TYPE "TravelerKind" AS ENUM ('ADULT', 'CHILD');

CREATE TYPE "PaymentProvider" AS ENUM ('VNPAY', 'MOMO', 'ZALOPAY');

CREATE TYPE "PaymentStatus" AS ENUM (
    'INITIATED',
    'SUCCEEDED',
    'FAILED',
    'REFUND_REQUIRED',
    'REFUNDED'
);

-- ============================================================
-- 2. BẢNG NGUOI_DUNG
-- ============================================================

CREATE TABLE "NGUOI_DUNG" (
    "id" UUID NOT NULL,
    "email" VARCHAR(254) NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "passwordHash" TEXT NOT NULL,
    "role" "Role" NOT NULL DEFAULT 'CUSTOMER',
    "isActive" BOOLEAN NOT NULL DEFAULT TRUE,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "NGUOI_DUNG_pkey" PRIMARY KEY ("id")
);

-- ============================================================
-- 3. BẢNG REFRESH SESSION
-- ============================================================

CREATE TABLE "RefreshSession" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "tokenHash" TEXT NOT NULL,
    "familyId" UUID NOT NULL,
    "expiresAt" TIMESTAMPTZ(3) NOT NULL,
    "revokedAt" TIMESTAMPTZ(3),
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "RefreshSession_pkey" PRIMARY KEY ("id")
);

-- ============================================================
-- 4. BẢNG TOUR
-- ============================================================

CREATE TABLE "TOUR" (
    "id" UUID NOT NULL,
    "slug" VARCHAR(150) NOT NULL,
    "title" VARCHAR(150) NOT NULL,
    "description" TEXT NOT NULL,
    "destination" VARCHAR(100) NOT NULL,
    "countryCode" CHAR(2) NOT NULL DEFAULT 'VN',
    "durationDays" INTEGER NOT NULL,
    "status" "TourStatus" NOT NULL DEFAULT 'DRAFT',
    "deletedAt" TIMESTAMPTZ(3),
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "TOUR_pkey" PRIMARY KEY ("id")
);

-- ============================================================
-- 5. BẢNG LỊCH KHỞI HÀNH
-- ============================================================

CREATE TABLE "LICH_KHOI_HANH" (
    "id" UUID NOT NULL,
    "tourId" UUID NOT NULL,
    "departureAt" TIMESTAMPTZ(3) NOT NULL,
    "totalSeats" INTEGER NOT NULL,
    "reservedSeats" INTEGER NOT NULL DEFAULT 0,
    "adultPrice" BIGINT NOT NULL,
    "childPrice" BIGINT NOT NULL,
    "status" "ScheduleStatus" NOT NULL DEFAULT 'OPEN',

    CONSTRAINT "LICH_KHOI_HANH_pkey" PRIMARY KEY ("id")
);

-- ============================================================
-- 6. BẢNG ĐƠN ĐẶT TOUR
-- ============================================================

CREATE TABLE "DON_DAT_TOUR" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "scheduleId" UUID NOT NULL,
    "idempotencyKey" UUID NOT NULL,
    "requestHash" TEXT NOT NULL,
    "status" "BookingStatus" NOT NULL DEFAULT 'PENDING_PAYMENT',
    "adults" INTEGER NOT NULL,
    "children" INTEGER NOT NULL,
    "totalAmount" BIGINT NOT NULL,
    "currency" CHAR(3) NOT NULL DEFAULT 'VND',
    "tourTitle" TEXT NOT NULL,
    "contactName" TEXT NOT NULL,
    "contactEmail" TEXT NOT NULL,
    "contactPhone" TEXT NOT NULL,
    "expiresAt" TIMESTAMPTZ(3) NOT NULL,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "paidAt" TIMESTAMPTZ(3),
    "cancelledAt" TIMESTAMPTZ(3),
    "cancelReason" TEXT,
    "seatsReleasedAt" TIMESTAMPTZ(3),
    "timeoutEnqueuedAt" TIMESTAMPTZ(3),

    CONSTRAINT "DON_DAT_TOUR_pkey" PRIMARY KEY ("id")
);

-- ============================================================
-- 7. BẢNG CHI TIẾT ĐẶT TOUR
-- ============================================================

CREATE TABLE "CHI_TIET_DAT_TOUR" (
    "id" UUID NOT NULL,
    "bookingId" UUID NOT NULL,
    "kind" "TravelerKind" NOT NULL,
    "quantity" INTEGER NOT NULL,
    "unitPrice" BIGINT NOT NULL,
    "lineTotal" BIGINT NOT NULL,

    CONSTRAINT "CHI_TIET_DAT_TOUR_pkey" PRIMARY KEY ("id")
);

-- ============================================================
-- 8. BẢNG THANH TOÁN
-- ============================================================

CREATE TABLE "THANH_TOAN" (
    "id" UUID NOT NULL,
    "bookingId" UUID NOT NULL,
    "provider" "PaymentProvider" NOT NULL,
    "providerReference" TEXT NOT NULL,
    "transactionId" TEXT,
    "amount" BIGINT NOT NULL,
    "currency" CHAR(3) NOT NULL DEFAULT 'VND',
    "status" "PaymentStatus" NOT NULL DEFAULT 'INITIATED',
    "checkoutUrl" TEXT,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,
    "refundedAt" TIMESTAMPTZ(3),
    "refundReference" TEXT,

    CONSTRAINT "THANH_TOAN_pkey" PRIMARY KEY ("id")
);

-- ============================================================
-- 9. BẢNG AUDIT LOG
-- ============================================================

CREATE TABLE "AuditLog" (
    "id" UUID NOT NULL,
    "actorId" UUID,
    "action" TEXT NOT NULL,
    "entityId" TEXT NOT NULL,
    "metadata" JSONB NOT NULL DEFAULT '{}',
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "AuditLog_pkey" PRIMARY KEY ("id")
);

-- ============================================================
-- 10. INDEX / UNIQUE
-- ============================================================

CREATE UNIQUE INDEX "NGUOI_DUNG_email_key"
    ON "NGUOI_DUNG"("email");

CREATE UNIQUE INDEX "RefreshSession_tokenHash_key"
    ON "RefreshSession"("tokenHash");

CREATE INDEX "RefreshSession_userId_familyId_idx"
    ON "RefreshSession"("userId", "familyId");

CREATE UNIQUE INDEX "TOUR_slug_key"
    ON "TOUR"("slug");

CREATE INDEX "TOUR_status_destination_idx"
    ON "TOUR"("status", "destination");

CREATE INDEX "LICH_KHOI_HANH_tourId_departureAt_idx"
    ON "LICH_KHOI_HANH"("tourId", "departureAt");

CREATE INDEX "DON_DAT_TOUR_status_expiresAt_idx"
    ON "DON_DAT_TOUR"("status", "expiresAt");

CREATE INDEX "DON_DAT_TOUR_scheduleId_status_idx"
    ON "DON_DAT_TOUR"("scheduleId", "status");

CREATE UNIQUE INDEX "DON_DAT_TOUR_userId_idempotencyKey_key"
    ON "DON_DAT_TOUR"("userId", "idempotencyKey");

CREATE UNIQUE INDEX "CHI_TIET_DAT_TOUR_bookingId_kind_key"
    ON "CHI_TIET_DAT_TOUR"("bookingId", "kind");

CREATE UNIQUE INDEX "THANH_TOAN_bookingId_key"
    ON "THANH_TOAN"("bookingId");

CREATE UNIQUE INDEX "THANH_TOAN_providerReference_key"
    ON "THANH_TOAN"("providerReference");

CREATE UNIQUE INDEX "THANH_TOAN_provider_transactionId_key"
    ON "THANH_TOAN"("provider", "transactionId");

CREATE INDEX "AuditLog_entityId_createdAt_idx"
    ON "AuditLog"("entityId", "createdAt");

-- Hardening indexes
CREATE INDEX "TOUR_status_countryCode_deletedAt_createdAt_id_idx"
    ON "TOUR"("status", "countryCode", "deletedAt", "createdAt", "id");

CREATE INDEX "LICH_KHOI_HANH_tourId_status_departureAt_id_idx"
    ON "LICH_KHOI_HANH"("tourId", "status", "departureAt", "id");

CREATE INDEX "DON_DAT_TOUR_userId_createdAt_id_idx"
    ON "DON_DAT_TOUR"("userId", "createdAt", "id");

CREATE INDEX "DON_DAT_TOUR_createdAt_id_idx"
    ON "DON_DAT_TOUR"("createdAt", "id");

CREATE INDEX "THANH_TOAN_status_createdAt_id_idx"
    ON "THANH_TOAN"("status", "createdAt", "id");

CREATE INDEX "THANH_TOAN_createdAt_id_idx"
    ON "THANH_TOAN"("createdAt", "id");

CREATE INDEX "AuditLog_createdAt_id_idx"
    ON "AuditLog"("createdAt", "id");

-- ============================================================
-- 11. RÀNG BUỘC FOREIGN KEY
-- ============================================================

ALTER TABLE "RefreshSession"
    ADD CONSTRAINT "RefreshSession_userId_fkey"
    FOREIGN KEY ("userId")
    REFERENCES "NGUOI_DUNG"("id")
    ON DELETE CASCADE
    ON UPDATE CASCADE;

ALTER TABLE "LICH_KHOI_HANH"
    ADD CONSTRAINT "LICH_KHOI_HANH_tourId_fkey"
    FOREIGN KEY ("tourId")
    REFERENCES "TOUR"("id")
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

ALTER TABLE "DON_DAT_TOUR"
    ADD CONSTRAINT "DON_DAT_TOUR_userId_fkey"
    FOREIGN KEY ("userId")
    REFERENCES "NGUOI_DUNG"("id")
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

ALTER TABLE "DON_DAT_TOUR"
    ADD CONSTRAINT "DON_DAT_TOUR_scheduleId_fkey"
    FOREIGN KEY ("scheduleId")
    REFERENCES "LICH_KHOI_HANH"("id")
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

ALTER TABLE "CHI_TIET_DAT_TOUR"
    ADD CONSTRAINT "CHI_TIET_DAT_TOUR_bookingId_fkey"
    FOREIGN KEY ("bookingId")
    REFERENCES "DON_DAT_TOUR"("id")
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

ALTER TABLE "THANH_TOAN"
    ADD CONSTRAINT "THANH_TOAN_bookingId_fkey"
    FOREIGN KEY ("bookingId")
    REFERENCES "DON_DAT_TOUR"("id")
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

ALTER TABLE "AuditLog"
    ADD CONSTRAINT "AuditLog_actorId_fkey"
    FOREIGN KEY ("actorId")
    REFERENCES "NGUOI_DUNG"("id")
    ON DELETE SET NULL
    ON UPDATE CASCADE;

-- ============================================================
-- 12. CHECK NGHIỆP VỤ
-- ============================================================

ALTER TABLE "TOUR"
    ADD CONSTRAINT "tour_domestic"
    CHECK ("countryCode" = 'VN');

ALTER TABLE "TOUR"
    ADD CONSTRAINT "tour_duration"
    CHECK ("durationDays" BETWEEN 1 AND 60);

ALTER TABLE "LICH_KHOI_HANH"
    ADD CONSTRAINT "valid_inventory"
    CHECK (
        "totalSeats" BETWEEN 1 AND 10000
        AND "reservedSeats" >= 0
        AND "reservedSeats" <= "totalSeats"
    );

ALTER TABLE "LICH_KHOI_HANH"
    ADD CONSTRAINT "valid_prices"
    CHECK (
        "adultPrice" BETWEEN 0 AND 99999999
        AND "childPrice" BETWEEN 0 AND 99999999
    );

ALTER TABLE "DON_DAT_TOUR"
    ADD CONSTRAINT "valid_party"
    CHECK (
        "adults" BETWEEN 1 AND 100
        AND "children" BETWEEN 0 AND 100
    );

ALTER TABLE "DON_DAT_TOUR"
    ADD CONSTRAINT "valid_total"
    CHECK (
        "totalAmount" BETWEEN 0 AND 9999999999
        AND "currency" = 'VND'
    );

ALTER TABLE "DON_DAT_TOUR"
    ADD CONSTRAINT "exact_hold"
    CHECK ("expiresAt" = "createdAt" + INTERVAL '15 minutes');

ALTER TABLE "DON_DAT_TOUR"
    ADD CONSTRAINT "release_matches_cancel"
    CHECK (
        ("status" = 'CANCELLED') = ("seatsReleasedAt" IS NOT NULL)
    );

ALTER TABLE "DON_DAT_TOUR"
    ADD CONSTRAINT "cancel_fields_match_status"
    CHECK (
        ("status" = 'CANCELLED') = (
            "cancelledAt" IS NOT NULL
            AND "cancelReason" IS NOT NULL
            AND "seatsReleasedAt" IS NOT NULL
        )
    );

ALTER TABLE "CHI_TIET_DAT_TOUR"
    ADD CONSTRAINT "valid_detail"
    CHECK (
        "quantity" > 0
        AND "unitPrice" >= 0
        AND "lineTotal" = "quantity" * "unitPrice"
    );

ALTER TABLE "THANH_TOAN"
    ADD CONSTRAINT "valid_payment_amount"
    CHECK (
        "amount" BETWEEN 0 AND 9999999999
        AND "currency" = 'VND'
    );

ALTER TABLE "THANH_TOAN"
    ADD CONSTRAINT "refund_fields_match_status"
    CHECK (
        ("status" = 'REFUNDED') = (
            "refundedAt" IS NOT NULL
            AND "refundReference" IS NOT NULL
        )
    );

ALTER TABLE "NGUOI_DUNG"
    ADD CONSTRAINT "user_email_lowercase"
    CHECK ("email" = lower("email"));

-- ============================================================
-- FILE 1 KẾT THÚC
-- ============================================================
