-- ============================================================
-- FILE 3: VIEW + STORED PROCEDURE + TRIGGER + TRUY VẤN
-- PostgreSQL
-- Chạy sau FILE 1 (01_Tao_CSDL_Bang.sql) và FILE 2 (02_Them_Du_Lieu_Demo.sql)
-- Bao gồm đầy đủ:
--   1. Định nghĩa và THỰC THI 4 Views báo cáo & nghiệp vụ
--   2. Định nghĩa và THỰC THI (CALL + kiểm tra) 3 Stored Procedures
--   3. Định nghĩa và THỰC THI (UPDATE + kiểm tra) 3 Triggers tự động
--   4. THỰC THI 10 câu truy vấn nghiệp vụ phân tích số liệu
-- ============================================================

-- ============================================================
-- PHẦN 1: TẠO VÀ THỰC THI CÁC KHUNG NHÌN (VIEWS)
-- ============================================================

-- ------------------------------------------------------------
-- 1.1. View 1: Danh sách các tour đang mở hoạt động công khai
-- Dành riêng cho trang chủ và trang danh mục tour của Frontend
-- ------------------------------------------------------------
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

-- ------------------------------------------------------------
-- 1.2. View 2: Lịch khởi hành trong tương lai còn chỗ mở bán
-- Phục vụ khách hàng tìm kiếm chuyến đi phù hợp
-- ------------------------------------------------------------
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

-- ------------------------------------------------------------
-- 1.3. View 3: Toàn bộ thông tin đơn đặt tour kèm khách và thanh toán
-- View tổng hợp phục vụ nhân viên vận hành và chăm sóc khách hàng
-- ------------------------------------------------------------
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

-- ------------------------------------------------------------
-- 1.4. View 4: Tổng hợp doanh thu thực thu theo từng tour
-- Chỉ tính các đơn đã thanh toán/hoàn thành với thanh toán thành công
-- ------------------------------------------------------------
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

-- ------------------------------------------------------------
-- 1.5. THỰC HIỆN KIỂM TRA DỮ LIỆU TỪ 4 VIEWS
-- ------------------------------------------------------------

-- Thực thi View 1: Danh sách các tour đang hoạt động
SELECT '--- KẾT QUẢ VIEW 1: vw_TourActive ---' AS "Thực hiện";
SELECT "id", "slug", "title", "destination", "durationDays", "status"
FROM "vw_TourActive"
ORDER BY "title";

-- Thực thi View 2: Lịch khởi hành còn chỗ
SELECT '--- KẾT QUẢ VIEW 2: vw_ScheduleAvailable ---' AS "Thực hiện";
SELECT "id", "tourTitle", "destination", "departureAt", "totalSeats", "reservedSeats", "availableSeats", "adultPrice"
FROM "vw_ScheduleAvailable"
ORDER BY "departureAt";

-- Thực thi View 3: Danh sách đơn hàng tổng hợp
SELECT '--- KẾT QUẢ VIEW 3: vw_BookingInfo ---' AS "Thực hiện";
SELECT "bookingId", "contactName", "tourCurrentTitle", "totalTravelers", "totalAmount", "bookingStatus", "paymentStatus"
FROM "vw_BookingInfo"
ORDER BY "bookingCreatedAt" DESC;

-- Thực thi View 4: Doanh thu thực thu theo tour
SELECT '--- KẾT QUẢ VIEW 4: vw_TourRevenue ---' AS "Thực hiện";
SELECT "tourTitle", "destination", "paidBookingCount", "revenue"
FROM "vw_TourRevenue"
ORDER BY "revenue" DESC;


-- ============================================================
-- PHẦN 2: TẠO VÀ THỰC THI THỦ TỤC LƯU TRỮ (STORED PROCEDURES)
-- ============================================================

-- ------------------------------------------------------------
-- 2.1. Procedure 1: Khóa tài khoản người dùng vi phạm
-- ------------------------------------------------------------
CREATE OR REPLACE PROCEDURE "sp_DeactivateUser"(p_user_id UUID)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE "NGUOI_DUNG"
    SET "isActive" = FALSE
    WHERE "id" = p_user_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Không tìm thấy người dùng có mã: %', p_user_id;
    END IF;
END;
$$;

-- ------------------------------------------------------------
-- 2.2. Procedure 2: Đóng lịch khởi hành khi đã chốt danh sách đoàn
-- ------------------------------------------------------------
CREATE OR REPLACE PROCEDURE "sp_CloseSchedule"(p_schedule_id UUID)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE "LICH_KHOI_HANH"
    SET "status" = 'CLOSED'
    WHERE "id" = p_schedule_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Không tìm thấy lịch khởi hành có mã: %', p_schedule_id;
    END IF;
END;
$$;

-- ------------------------------------------------------------
-- 2.3. Procedure 3: Lưu trữ / ngừng kinh doanh tour bằng xóa mềm
-- ------------------------------------------------------------
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
        RAISE EXCEPTION 'Không tìm thấy tour có mã: %', p_tour_id;
    END IF;
END;
$$;

-- ------------------------------------------------------------
-- 2.4. THỰC HIỆN GỌI VÀ KIỂM TRA KẾT QUẢ CỦA 3 STORED PROCEDURES
-- ------------------------------------------------------------

-- THỰC HIỆN THỦ TỤC 1: Khóa tài khoản khách hàng Customer 06 (Vũ Khánh Linh)
SELECT '--- THỰC THI THỦ TỤC 1: sp_DeactivateUser ---' AS "Thực hiện";

-- Kiểm tra trước khi khóa:
SELECT "id", "name", "email", "isActive"
FROM "NGUOI_DUNG"
WHERE "id" = '11000000-0000-4000-8000-000000000006'::UUID;

-- Gọi thủ tục khóa tài khoản:
CALL "sp_DeactivateUser"('11000000-0000-4000-8000-000000000006'::UUID);

-- Kiểm tra sau khi khóa (isActive đã chuyển thành FALSE):
SELECT "id", "name", "email", "isActive" AS "isActive_SauKhiKhoa"
FROM "NGUOI_DUNG"
WHERE "id" = '11000000-0000-4000-8000-000000000006'::UUID;


-- THỰC HIỆN THỦ TỤC 2: Đóng lịch khởi hành số 9 (Tour Miền Tây)
SELECT '--- THỰC THI THỦ TỤC 2: sp_CloseSchedule ---' AS "Thực hiện";

-- Kiểm tra trước khi đóng:
SELECT "id", "tourId", "departureAt", "status"
FROM "LICH_KHOI_HANH"
WHERE "id" = '02000000-0000-4000-8000-000000000009'::UUID;

-- Gọi thủ tục đóng lịch:
CALL "sp_CloseSchedule"('02000000-0000-4000-8000-000000000009'::UUID);

-- Kiểm tra sau khi đóng (status đã chuyển thành 'CLOSED'):
SELECT "id", "tourId", "departureAt", "status" AS "status_SauKhiDong"
FROM "LICH_KHOI_HANH"
WHERE "id" = '02000000-0000-4000-8000-000000000009'::UUID;


-- THỰC HIỆN THỦ TỤC 3: Lưu trữ tour số 8 (Hà Giang Loop)
SELECT '--- THỰC THI THỦ TỤC 3: sp_ArchiveTour ---' AS "Thực hiện";

-- Kiểm tra trước khi lưu trữ:
SELECT "id", "title", "status", "deletedAt"
FROM "TOUR"
WHERE "id" = '01000000-0000-4000-8000-000000000008'::UUID;

-- Gọi thủ tục xóa mềm / lưu trữ tour:
CALL "sp_ArchiveTour"('01000000-0000-4000-8000-000000000008'::UUID);

-- Kiểm tra sau khi lưu trữ (status = 'INACTIVE' và deletedAt đã được gán):
SELECT "id", "title", "status" AS "status_SauKhiArchive", "deletedAt"
FROM "TOUR"
WHERE "id" = '01000000-0000-4000-8000-000000000008'::UUID;


-- ============================================================
-- PHẦN 3: TẠO VÀ THỰC THI CÁC BỘ KÍCH HOẠT TỰ ĐỘNG (TRIGGERS)
-- ============================================================

-- ------------------------------------------------------------
-- 3.1. Trigger 1: Tự động cập nhật TOUR.updatedAt khi sửa thông tin tour
-- ------------------------------------------------------------
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

-- ------------------------------------------------------------
-- 3.2. Trigger 2: Tự động cập nhật THANH_TOAN.updatedAt khi sửa thanh toán
-- ------------------------------------------------------------
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

-- ------------------------------------------------------------
-- 3.3. Trigger 3: Tự động ghi nhật ký vào AuditLog khi trạng thái thanh toán thay đổi
-- ------------------------------------------------------------
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

-- ------------------------------------------------------------
-- 3.4. THỰC HIỆN KIỂM TRA HOẠT ĐỘNG CỦA 3 TRIGGERS
-- ------------------------------------------------------------

-- THỰC HIỆN TRIGGER 1: Cập nhật thông tin Tour 1 để kiểm tra tự động gán updatedAt
SELECT '--- THỰC THI TRIGGER 1: trg_TouchTourUpdatedAt ---' AS "Thực hiện";

-- Cập nhật mô tả tour số 1:
UPDATE "TOUR"
SET "description" = 'Khám phá Vịnh Hạ Long di sản thiên nhiên thế giới, chèo thuyền kayak và du thuyền 5 sao sang trọng.'
WHERE "id" = '01000000-0000-4000-8000-000000000001'::UUID;

-- Kiểm tra kết quả: cột updatedAt đã tự động nhận thời điểm hiện tại:
SELECT "id", "title", "createdAt", "updatedAt"
FROM "TOUR"
WHERE "id" = '01000000-0000-4000-8000-000000000001'::UUID;


-- THỰC HIỆN TRIGGER 2 & 3: Cập nhật trạng thái thanh toán đơn số 5
-- (Chuyển từ INITIATED sang FAILED)
SELECT '--- THỰC THI TRIGGER 2 & 3: trg_TouchPaymentUpdatedAt & trg_AuditPaymentStatusChange ---' AS "Thực hiện";

-- Thực hiện lệnh UPDATE trên bảng THANH_TOAN:
UPDATE "THANH_TOAN"
SET "status" = 'FAILED'
WHERE "id" = '50000000-0000-4000-8000-000000000005'::UUID;

-- Kiểm tra Trigger 2: updatedAt của THANH_TOAN đã được tự động cập nhật:
SELECT "id", "provider", "amount", "status", "updatedAt"
FROM "THANH_TOAN"
WHERE "id" = '50000000-0000-4000-8000-000000000005'::UUID;

-- Kiểm tra Trigger 3: Bản ghi mới trong bảng AuditLog đã được tự động sinh ra:
SELECT "id", "action", "entityId", "metadata", "createdAt"
FROM "AuditLog"
WHERE "action" = 'PAYMENT_STATUS_CHANGED'
ORDER BY "createdAt" DESC
LIMIT 1;


-- ============================================================
-- PHẦN 4: THỰC THI 10 CÂU TRUY VẤN NGHIỆP VỤ BÁO CÁO QUAN TRỌNG
-- ============================================================

-- 4.1. Xem danh sách tất cả các tour du lịch hiện có
SELECT '--- TRUY VẤN 4.1: Danh sách tất cả tour ---' AS "Truy Vấn";
SELECT
    "id",
    "title",
    "destination",
    "durationDays",
    "status",
    "createdAt"
FROM "TOUR"
ORDER BY "createdAt" DESC;

-- 4.2. Xem danh sách các tour du lịch đang hoạt động (ACTIVE)
SELECT '--- TRUY VẤN 4.2: Các tour đang hoạt động ---' AS "Truy Vấn";
SELECT
    "id",
    "slug",
    "title",
    "destination",
    "durationDays"
FROM "vw_TourActive"
ORDER BY "destination";

-- 4.3. Xem các lịch khởi hành trong tương lai còn nhận khách
SELECT '--- TRUY VẤN 4.3: Lịch khởi hành còn chỗ ---' AS "Truy Vấn";
SELECT
    "id" AS "scheduleId",
    "tourTitle",
    "departureAt",
    "totalSeats",
    "reservedSeats",
    "availableSeats",
    "adultPrice"
FROM "vw_ScheduleAvailable"
ORDER BY "departureAt" ASC;

-- 4.4. Xem danh sách đơn đặt tour kèm thông tin khách và thanh toán
SELECT '--- TRUY VẤN 4.4: Chi tiết danh sách đơn đặt tour ---' AS "Truy Vấn";
SELECT
    "bookingId",
    "contactName",
    "contactPhone",
    "tourCurrentTitle",
    "totalTravelers",
    "totalAmount",
    "bookingStatus",
    "provider" AS "paymentProvider",
    "paymentStatus"
FROM "vw_BookingInfo"
ORDER BY "bookingCreatedAt" DESC;

-- 4.5. Lọc các đơn đặt tour đã thanh toán thành công
SELECT '--- TRUY VẤN 4.5: Các đơn đặt tour đã thanh toán thành công ---' AS "Truy Vấn";
SELECT
    b."id" AS "bookingId",
    u."name" AS "customerName",
    b."tourTitle",
    b."totalAmount",
    b."status" AS "bookingStatus",
    b."paidAt"
FROM "DON_DAT_TOUR" b
JOIN "NGUOI_DUNG" u ON u."id" = b."userId"
WHERE b."status" IN ('PAID', 'CONFIRMED', 'COMPLETED')
ORDER BY b."paidAt" DESC;

-- 4.6. Thống kê số lượng đơn đặt tour theo từng trạng thái
SELECT '--- TRUY VẤN 4.6: Số lượng đơn theo trạng thái ---' AS "Truy Vấn";
SELECT
    "status",
    COUNT(*) AS "soLuongDon",
    SUM("totalAmount") AS "tongGiaTriVND"
FROM "DON_DAT_TOUR"
GROUP BY "status"
ORDER BY "soLuongDon" DESC;

-- 4.7. Thống kê tổng số tiền chi tiêu theo từng khách hàng
SELECT '--- TRUY VẤN 4.7: Thống kê chi tiêu của khách hàng ---' AS "Truy Vấn";
SELECT
    u."id" AS "userId",
    u."name" AS "hoTen",
    u."email",
    COUNT(b."id") AS "soDonDaDat",
    COALESCE(SUM(
        CASE
            WHEN b."status" IN ('PAID', 'CONFIRMED', 'COMPLETED')
                THEN b."totalAmount"
            ELSE 0
        END
    ), 0) AS "tongChiTieuThanhCongVND"
FROM "NGUOI_DUNG" u
LEFT JOIN "DON_DAT_TOUR" b
    ON b."userId" = u."id"
WHERE u."role" = 'CUSTOMER'
GROUP BY u."id", u."name", u."email"
ORDER BY "tongChiTieuThanhCongVND" DESC;

-- 4.8. Báo cáo doanh thu thực thu theo chương trình tour
SELECT '--- TRUY VẤN 4.8: Doanh thu thực thu theo tour ---' AS "Truy Vấn";
SELECT
    "tourTitle",
    "destination",
    "paidBookingCount",
    "revenue" AS "doanhThuThucThuVND"
FROM "vw_TourRevenue"
ORDER BY "revenue" DESC;

-- 4.9. Kiểm tra công suất và số chỗ trống thực tế của từng lịch khởi hành
SELECT '--- TRUY VẤN 4.9: Tình trạng chỗ của các chuyến đi ---' AS "Truy Vấn";
SELECT
    s."id" AS "scheduleId",
    t."title" AS "tourTitle",
    s."departureAt",
    s."totalSeats" AS "tongCho",
    s."reservedSeats" AS "daGiuCho",
    (s."totalSeats" - s."reservedSeats") AS "choConTrong",
    ROUND((s."reservedSeats"::NUMERIC / s."totalSeats") * 100, 2) AS "tyLeLapDayPercent",
    s."status"
FROM "LICH_KHOI_HANH" s
JOIN "TOUR" t ON t."id" = s."tourId"
ORDER BY s."departureAt" ASC;

-- 4.10. Thống kê chi tiết các đơn đặt tour đã bị hủy và lý do hủy
SELECT '--- TRUY VẤN 4.10: Danh sách đơn bị hủy và lý do ---' AS "Truy Vấn";
SELECT
    b."id" AS "bookingId",
    u."name" AS "customerName",
    b."tourTitle",
    b."totalAmount",
    b."cancelledAt",
    b."cancelReason",
    b."seatsReleasedAt"
FROM "DON_DAT_TOUR" b
JOIN "NGUOI_DUNG" u ON u."id" = b."userId"
WHERE b."status" = 'CANCELLED'
ORDER BY b."cancelledAt" DESC;

-- ============================================================
-- FILE 3 KẾT THÚC
-- ============================================================
