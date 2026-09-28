-- ============================================================
-- FILE 3: VIEW + STORED PROCEDURE + TRIGGER + TRUY VẤN CƠ BẢN
-- PostgreSQL
-- Chạy sau FILE 1 và FILE 2
-- ============================================================

-- ============================================================
-- 1. VIEW
-- ============================================================

-- View 1: Tour đang hoạt động
CREATE OR REPLACE VIEW "vw_TourActive" AS
SELECT
    t."id",
    t."slug",
    t."title",
    t."description",
    t."destination",
    t."countryCode",
    t."durationDays",
    t."status",
    t."createdAt",
    t."updatedAt"
FROM "TOUR" t
WHERE t."status" = 'ACTIVE'
  AND t."deletedAt" IS NULL;

-- View 2: Lịch khởi hành còn chỗ
CREATE OR REPLACE VIEW "vw_ScheduleAvailable" AS
SELECT
    s."id",
    s."tourId",
    t."title" AS "tourTitle",
    t."destination",
    s."departureAt",
    s."totalSeats",
    s."reservedSeats",
    (s."totalSeats" - s."reservedSeats") AS "availableSeats",
    s."adultPrice",
    s."childPrice",
    s."status"
FROM "LICH_KHOI_HANH" s
JOIN "TOUR" t
    ON t."id" = s."tourId"
WHERE s."status" = 'OPEN'
  AND s."departureAt" > CURRENT_TIMESTAMP
  AND t."status" = 'ACTIVE'
  AND t."deletedAt" IS NULL
  AND s."reservedSeats" < s."totalSeats";

-- View 3: Chi tiết đơn đặt tour
CREATE OR REPLACE VIEW "vw_BookingInfo" AS
SELECT
    b."id" AS "bookingId",
    b."status" AS "bookingStatus",
    b."createdAt" AS "bookingCreatedAt",
    b."expiresAt",
    b."adults",
    b."children",
    (b."adults" + b."children") AS "totalTravelers",
    b."totalAmount",
    b."currency",
    b."contactName",
    b."contactEmail",
    b."contactPhone",
    u."id" AS "userId",
    u."name" AS "userName",
    u."email" AS "userEmail",
    t."id" AS "tourId",
    t."title" AS "tourCurrentTitle",
    s."id" AS "scheduleId",
    s."departureAt",
    p."id" AS "paymentId",
    p."provider",
    p."providerReference",
    p."transactionId",
    p."status" AS "paymentStatus",
    p."amount" AS "paymentAmount",
    p."createdAt" AS "paymentCreatedAt"
FROM "DON_DAT_TOUR" b
JOIN "NGUOI_DUNG" u
    ON u."id" = b."userId"
JOIN "LICH_KHOI_HANH" s
    ON s."id" = b."scheduleId"
JOIN "TOUR" t
    ON t."id" = s."tourId"
LEFT JOIN "THANH_TOAN" p
    ON p."bookingId" = b."id";

-- View 4: Tổng hợp doanh thu theo tour
CREATE OR REPLACE VIEW "vw_TourRevenue" AS
SELECT
    t."id" AS "tourId",
    t."title" AS "tourTitle",
    t."destination",
    COUNT(DISTINCT b."id") AS "paidBookingCount",
    COALESCE(SUM(p."amount"), 0) AS "revenue"
FROM "TOUR" t
JOIN "LICH_KHOI_HANH" s
    ON s."tourId" = t."id"
JOIN "DON_DAT_TOUR" b
    ON b."scheduleId" = s."id"
JOIN "THANH_TOAN" p
    ON p."bookingId" = b."id"
WHERE b."status" IN ('PAID', 'CONFIRMED', 'COMPLETED')
  AND p."status" = 'SUCCEEDED'
GROUP BY
    t."id",
    t."title",
    t."destination";

-- ============================================================
-- 2. STORED PROCEDURE
-- ============================================================

-- Procedure 1: Khóa tài khoản
CREATE OR REPLACE PROCEDURE "sp_DeactivateUser"(p_user_id UUID)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE "NGUOI_DUNG"
    SET "isActive" = FALSE
    WHERE "id" = p_user_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Không tìm thấy người dùng: %', p_user_id;
    END IF;
END;
$$;

-- Procedure 2: Đóng lịch khởi hành
CREATE OR REPLACE PROCEDURE "sp_CloseSchedule"(p_schedule_id UUID)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE "LICH_KHOI_HANH"
    SET "status" = 'CLOSED'
    WHERE "id" = p_schedule_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Không tìm thấy lịch khởi hành: %', p_schedule_id;
    END IF;
END;
$$;

-- Procedure 3: Archive tour bằng soft delete
CREATE OR REPLACE PROCEDURE "sp_ArchiveTour"(p_tour_id UUID)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE "TOUR"
    SET
        "status" = 'INACTIVE',
        "deletedAt" = COALESCE("deletedAt", CURRENT_TIMESTAMP)
    WHERE "id" = p_tour_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Không tìm thấy tour: %', p_tour_id;
    END IF;
END;
$$;

-- ============================================================
-- 3. TRIGGER
-- ============================================================

-- Trigger 1: Tự cập nhật TOUR.updatedAt
CREATE OR REPLACE FUNCTION "fn_TouchTourUpdatedAt"()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW."updatedAt" = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS "trg_TouchTourUpdatedAt" ON "TOUR";

CREATE TRIGGER "trg_TouchTourUpdatedAt"
BEFORE UPDATE ON "TOUR"
FOR EACH ROW
EXECUTE FUNCTION "fn_TouchTourUpdatedAt"();

-- Trigger 2: Tự cập nhật THANH_TOAN.updatedAt
CREATE OR REPLACE FUNCTION "fn_TouchPaymentUpdatedAt"()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW."updatedAt" = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS "trg_TouchPaymentUpdatedAt" ON "THANH_TOAN";

CREATE TRIGGER "trg_TouchPaymentUpdatedAt"
BEFORE UPDATE ON "THANH_TOAN"
FOR EACH ROW
EXECUTE FUNCTION "fn_TouchPaymentUpdatedAt"();

-- Trigger 3: Ghi AuditLog khi trạng thái thanh toán thay đổi
CREATE OR REPLACE FUNCTION "fn_AuditPaymentStatusChange"()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW."status" IS DISTINCT FROM OLD."status" THEN
        INSERT INTO "AuditLog" (
            "id",
            "actorId",
            "action",
            "entityId",
            "metadata",
            "createdAt"
        )
        VALUES (
            gen_random_uuid(),
            NULL,
            'PAYMENT_STATUS_CHANGED',
            NEW."id"::TEXT,
            jsonb_build_object(
                'bookingId', NEW."bookingId"::TEXT,
                'oldStatus', OLD."status"::TEXT,
                'newStatus', NEW."status"::TEXT,
                'provider', NEW."provider"::TEXT,
                'amount', NEW."amount"::TEXT,
                'currency', NEW."currency"
            ),
            CURRENT_TIMESTAMP
        );
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS "trg_AuditPaymentStatusChange" ON "THANH_TOAN";

CREATE TRIGGER "trg_AuditPaymentStatusChange"
AFTER UPDATE ON "THANH_TOAN"
FOR EACH ROW
EXECUTE FUNCTION "fn_AuditPaymentStatusChange"();

-- ============================================================
-- 4. MỘT SỐ TRUY VẤN CƠ BẢN
-- ============================================================

-- 4.1. Xem tất cả tour
SELECT *
FROM "TOUR"
ORDER BY "createdAt" DESC;

-- 4.2. Xem tour đang hoạt động
SELECT *
FROM "vw_TourActive"
ORDER BY "title";

-- 4.3. Xem lịch khởi hành còn chỗ
SELECT *
FROM "vw_ScheduleAvailable"
ORDER BY "departureAt";

-- 4.4. Xem danh sách đơn + người đặt + thanh toán
SELECT *
FROM "vw_BookingInfo"
ORDER BY "bookingCreatedAt" DESC;

-- 4.5. Tìm các đơn đã thanh toán
SELECT
    b."id" AS "bookingId",
    u."name" AS "customerName",
    b."totalAmount",
    b."status"
FROM "DON_DAT_TOUR" b
JOIN "NGUOI_DUNG" u ON u."id" = b."userId"
WHERE b."status" IN ('PAID', 'CONFIRMED', 'COMPLETED')
ORDER BY b."createdAt" DESC;

-- 4.6. Đếm số đơn theo trạng thái
SELECT
    "status",
    COUNT(*) AS "soDon"
FROM "DON_DAT_TOUR"
GROUP BY "status"
ORDER BY "soDon" DESC;

-- 4.7. Tổng số tiền theo khách hàng
SELECT
    u."id",
    u."name",
    u."email",
    COUNT(b."id") AS "soDon",
    COALESCE(SUM(
        CASE
            WHEN b."status" IN ('PAID', 'CONFIRMED', 'COMPLETED')
                THEN b."totalAmount"
            ELSE 0
        END
    ), 0) AS "tongTien"
FROM "NGUOI_DUNG" u
LEFT JOIN "DON_DAT_TOUR" b
    ON b."userId" = u."id"
WHERE u."role" = 'CUSTOMER'
GROUP BY u."id", u."name", u."email"
ORDER BY "tongTien" DESC;

-- 4.8. Doanh thu theo tour
SELECT *
FROM "vw_TourRevenue"
ORDER BY "revenue" DESC;

-- 4.9. Kiểm tra số chỗ còn lại
SELECT
    s."id",
    t."title",
    s."totalSeats",
    s."reservedSeats",
    (s."totalSeats" - s."reservedSeats") AS "availableSeats"
FROM "LICH_KHOI_HANH" s
JOIN "TOUR" t ON t."id" = s."tourId"
ORDER BY s."departureAt";

-- 4.10. Kiểm tra các đơn đã hủy
SELECT
    b."id",
    u."name" AS "customerName",
    b."cancelledAt",
    b."cancelReason",
    b."seatsReleasedAt"
FROM "DON_DAT_TOUR" b
JOIN "NGUOI_DUNG" u ON u."id" = b."userId"
WHERE b."status" = 'CANCELLED'
ORDER BY b."cancelledAt" DESC;

-- ============================================================
-- 5. VÍ DỤ GỌI PROCEDURE - ĐỂ COMMENT, CHỈ CHẠY KHI MUỐN TEST
-- ============================================================

-- CALL "sp_DeactivateUser"('11000000-0000-4000-8000-000000000010');
-- CALL "sp_CloseSchedule"('02000000-0000-4000-8000-000000000003');
-- CALL "sp_ArchiveTour"('01000000-0000-4000-8000-000000000003');

-- Ví dụ test Trigger 3:
-- UPDATE "THANH_TOAN"
-- SET "status" = 'FAILED'
-- WHERE "id" = '50000000-0000-4000-8000-000000000008';
-- Sau UPDATE, AuditLog sẽ tự thêm 1 bản ghi PAYMENT_STATUS_CHANGED.

-- ============================================================
-- FILE 3 KẾT THÚC
-- ============================================================
