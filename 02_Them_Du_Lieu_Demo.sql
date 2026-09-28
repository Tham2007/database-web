-- ============================================================
-- FILE 2: THÊM DỮ LIỆU DEMO
-- PostgreSQL
-- 3 tour + 3 lịch + 1 admin + 10 khách + 10 đơn
-- kèm chi tiết đơn, thanh toán và audit log
-- ============================================================

-- ------------------------------------------------------------
-- A. TOUR MẪU
-- ------------------------------------------------------------

INSERT INTO "TOUR" (
    "id", "slug", "title", "description", "destination",
    "countryCode", "durationDays", "status", "createdAt", "updatedAt"
)
VALUES
(
    '01000000-0000-4000-8000-000000000001',
    'da-nang-hoi-an',
    'Đà Nẵng và Hội An',
    'Hành trình khám phá Đà Nẵng và Hội An. Dữ liệu minh họa cho đồ án.',
    'Đà Nẵng', 'VN', 3, 'ACTIVE', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
),
(
    '01000000-0000-4000-8000-000000000002',
    'ninh-binh-trang-an',
    'Ninh Bình và Tràng An',
    'Hành trình khám phá Ninh Bình và Tràng An. Dữ liệu minh họa cho đồ án.',
    'Ninh Bình', 'VN', 2, 'ACTIVE', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
),
(
    '01000000-0000-4000-8000-000000000003',
    'phu-quoc-bien-xanh',
    'Phú Quốc biển xanh',
    'Hành trình nghỉ dưỡng Phú Quốc. Dữ liệu minh họa cho đồ án.',
    'Phú Quốc', 'VN', 4, 'ACTIVE', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
)
ON CONFLICT ("slug") DO NOTHING;

-- ------------------------------------------------------------
-- B. 3 LỊCH KHỞI HÀNH MẪU
-- ------------------------------------------------------------

INSERT INTO "LICH_KHOI_HANH" (
    "id", "tourId", "departureAt", "totalSeats", "reservedSeats",
    "adultPrice", "childPrice", "status"
)
SELECT
    '02000000-0000-4000-8000-000000000001'::UUID,
    t."id",
    CURRENT_TIMESTAMP + INTERVAL '30 days',
    30, 0, 3990000, 2490000, 'OPEN'
FROM "TOUR" t
WHERE t."slug" = 'da-nang-hoi-an'
ON CONFLICT ("id") DO NOTHING;

INSERT INTO "LICH_KHOI_HANH" (
    "id", "tourId", "departureAt", "totalSeats", "reservedSeats",
    "adultPrice", "childPrice", "status"
)
SELECT
    '02000000-0000-4000-8000-000000000002'::UUID,
    t."id",
    CURRENT_TIMESTAMP + INTERVAL '45 days',
    35, 0, 1990000, 1190000, 'OPEN'
FROM "TOUR" t
WHERE t."slug" = 'ninh-binh-trang-an'
ON CONFLICT ("id") DO NOTHING;

INSERT INTO "LICH_KHOI_HANH" (
    "id", "tourId", "departureAt", "totalSeats", "reservedSeats",
    "adultPrice", "childPrice", "status"
)
SELECT
    '02000000-0000-4000-8000-000000000003'::UUID,
    t."id",
    CURRENT_TIMESTAMP + INTERVAL '60 days',
    40, 0, 5990000, 3490000, 'OPEN'
FROM "TOUR" t
WHERE t."slug" = 'phu-quoc-bien-xanh'
ON CONFLICT ("id") DO NOTHING;

-- ------------------------------------------------------------
-- C. 1 ADMIN MẪU
-- passwordHash chỉ là dữ liệu DB demo, không dùng để đăng nhập app
-- ------------------------------------------------------------

INSERT INTO "NGUOI_DUNG" (
    "id", "email", "name", "passwordHash", "role", "isActive", "createdAt"
)
VALUES (
    '00000000-0000-4000-8000-000000000001',
    'admin@tour.local',
    'Quản trị demo',
    'DEMO_HASH_ONLY_NOT_FOR_LOGIN',
    'ADMIN',
    TRUE,
    CURRENT_TIMESTAMP
)
ON CONFLICT ("email") DO NOTHING;

-- ------------------------------------------------------------
-- D. 10 KHÁCH HÀNG DEMO
-- ------------------------------------------------------------

INSERT INTO "NGUOI_DUNG" (
    "id", "email", "name", "passwordHash", "role", "isActive", "createdAt"
)
VALUES
('11000000-0000-4000-8000-000000000001', 'customer01@demo.local', 'Nguyễn Minh Anh', 'DEMO_HASH_ONLY_NOT_FOR_LOGIN', 'CUSTOMER', TRUE, CURRENT_TIMESTAMP),
('11000000-0000-4000-8000-000000000002', 'customer02@demo.local', 'Trần Ngọc Mai', 'DEMO_HASH_ONLY_NOT_FOR_LOGIN', 'CUSTOMER', TRUE, CURRENT_TIMESTAMP),
('11000000-0000-4000-8000-000000000003', 'customer03@demo.local', 'Lê Hoàng Nam', 'DEMO_HASH_ONLY_NOT_FOR_LOGIN', 'CUSTOMER', TRUE, CURRENT_TIMESTAMP),
('11000000-0000-4000-8000-000000000004', 'customer04@demo.local', 'Phạm Thu Hà', 'DEMO_HASH_ONLY_NOT_FOR_LOGIN', 'CUSTOMER', TRUE, CURRENT_TIMESTAMP),
('11000000-0000-4000-8000-000000000005', 'customer05@demo.local', 'Đỗ Quốc Huy', 'DEMO_HASH_ONLY_NOT_FOR_LOGIN', 'CUSTOMER', TRUE, CURRENT_TIMESTAMP),
('11000000-0000-4000-8000-000000000006', 'customer06@demo.local', 'Vũ Khánh Linh', 'DEMO_HASH_ONLY_NOT_FOR_LOGIN', 'CUSTOMER', TRUE, CURRENT_TIMESTAMP),
('11000000-0000-4000-8000-000000000007', 'customer07@demo.local', 'Bùi Gia Bảo', 'DEMO_HASH_ONLY_NOT_FOR_LOGIN', 'CUSTOMER', TRUE, CURRENT_TIMESTAMP),
('11000000-0000-4000-8000-000000000008', 'customer08@demo.local', 'Hoàng Thu Trang', 'DEMO_HASH_ONLY_NOT_FOR_LOGIN', 'CUSTOMER', TRUE, CURRENT_TIMESTAMP),
('11000000-0000-4000-8000-000000000009', 'customer09@demo.local', 'Ngô Đức Anh', 'DEMO_HASH_ONLY_NOT_FOR_LOGIN', 'CUSTOMER', TRUE, CURRENT_TIMESTAMP),
('11000000-0000-4000-8000-000000000010', 'customer10@demo.local', 'Phan Ngọc Anh', 'DEMO_HASH_ONLY_NOT_FOR_LOGIN', 'CUSTOMER', TRUE, CURRENT_TIMESTAMP)
ON CONFLICT ("email") DO NOTHING;

-- ------------------------------------------------------------
-- E. 10 ĐƠN ĐẶT TOUR DEMO
-- 8 đơn đã thanh toán/hoàn thành, 1 đang chờ thanh toán, 1 đã hủy
-- ------------------------------------------------------------

WITH demo AS (
    SELECT * FROM (VALUES
        (1, 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa1'::UUID, 'PAID'::"BookingStatus",       2, 1, '02000000-0000-4000-8000-000000000001'::UUID, CURRENT_TIMESTAMP - INTERVAL '2 days'),
        (2, 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa2'::UUID, 'CONFIRMED'::"BookingStatus",   1, 0, '02000000-0000-4000-8000-000000000001'::UUID, CURRENT_TIMESTAMP - INTERVAL '3 days'),
        (3, 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa3'::UUID, 'COMPLETED'::"BookingStatus",   2, 0, '02000000-0000-4000-8000-000000000002'::UUID, CURRENT_TIMESTAMP - INTERVAL '4 days'),
        (4, 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa4'::UUID, 'PAID'::"BookingStatus",        1, 1, '02000000-0000-4000-8000-000000000002'::UUID, CURRENT_TIMESTAMP - INTERVAL '5 days'),
        (5, 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa5'::UUID, 'CONFIRMED'::"BookingStatus",   3, 0, '02000000-0000-4000-8000-000000000003'::UUID, CURRENT_TIMESTAMP - INTERVAL '6 days'),
        (6, 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa6'::UUID, 'COMPLETED'::"BookingStatus",   2, 1, '02000000-0000-4000-8000-000000000003'::UUID, CURRENT_TIMESTAMP - INTERVAL '7 days'),
        (7, 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa7'::UUID, 'PAID'::"BookingStatus",        1, 0, '02000000-0000-4000-8000-000000000001'::UUID, CURRENT_TIMESTAMP - INTERVAL '8 days'),
        (8, 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa8'::UUID, 'PENDING_PAYMENT'::"BookingStatus", 2, 2, '02000000-0000-4000-8000-000000000002'::UUID, CURRENT_TIMESTAMP - INTERVAL '5 minutes'),
        (9, 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa9'::UUID, 'CANCELLED'::"BookingStatus",    1, 1, '02000000-0000-4000-8000-000000000003'::UUID, CURRENT_TIMESTAMP - INTERVAL '10 days'),
        (10,'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaa10'::UUID, 'CONFIRMED'::"BookingStatus",    2, 0, '02000000-0000-4000-8000-000000000003'::UUID, CURRENT_TIMESTAMP - INTERVAL '9 days')
    ) AS v(rn, bookingId, status, adults, children, scheduleId, createdAt)
),
customers AS (
    SELECT
        u."id",
        ROW_NUMBER() OVER (ORDER BY u."email") AS rn
    FROM "NGUOI_DUNG" u
    WHERE u."email" LIKE 'customer%@demo.local'
),
schedules AS (
    SELECT
        s."id",
        s."adultPrice",
        s."childPrice",
        t."title" AS "tourTitle"
    FROM "LICH_KHOI_HANH" s
    JOIN "TOUR" t ON t."id" = s."tourId"
)
INSERT INTO "DON_DAT_TOUR" (
    "id", "userId", "scheduleId", "idempotencyKey", "requestHash",
    "status", "adults", "children", "totalAmount", "currency", "tourTitle",
    "contactName", "contactEmail", "contactPhone", "expiresAt", "createdAt",
    "paidAt", "cancelledAt", "cancelReason", "seatsReleasedAt"
)
SELECT
    d.bookingId,
    c."id",
    d.scheduleId,
    d.bookingId,
    md5(d.bookingId::TEXT || ':demo-request'),
    d.status,
    d.adults,
    d.children,
    (d.adults * s."adultPrice" + d.children * s."childPrice")::BIGINT,
    'VND',
    s."tourTitle",
    u."name",
    u."email",
    ('090' || LPAD((d.rn + 1000000)::TEXT, 7, '0')),
    d.createdAt + INTERVAL '15 minutes',
    d.createdAt,
    CASE
        WHEN d.status IN ('PAID', 'CONFIRMED', 'COMPLETED')
            THEN d.createdAt + INTERVAL '5 minutes'
    END,
    CASE
        WHEN d.status = 'CANCELLED'
            THEN d.createdAt + INTERVAL '10 minutes'
    END,
    CASE
        WHEN d.status = 'CANCELLED'
            THEN 'Khách yêu cầu hủy đơn demo'
    END,
    CASE
        WHEN d.status = 'CANCELLED'
            THEN d.createdAt + INTERVAL '10 minutes'
    END
FROM demo d
JOIN customers c ON c.rn = d.rn
JOIN schedules s ON s."id" = d.scheduleId
JOIN "NGUOI_DUNG" u ON u."id" = c."id"
ON CONFLICT ("id") DO NOTHING;

-- ------------------------------------------------------------
-- F. CHI TIẾT ĐƠN
-- Một số đơn có cả ADULT và CHILD để kiểm tra View.
-- ------------------------------------------------------------

WITH detail_data AS (
    SELECT * FROM (VALUES
        ('10000000-0000-4000-8000-000000000001'::UUID, 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa1'::UUID, 'ADULT'::"TravelerKind", 2),
        ('10000000-0000-4000-8000-000000000002'::UUID, 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa1'::UUID, 'CHILD'::"TravelerKind", 1),
        ('10000000-0000-4000-8000-000000000003'::UUID, 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa2'::UUID, 'ADULT'::"TravelerKind", 1),
        ('10000000-0000-4000-8000-000000000004'::UUID, 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa3'::UUID, 'ADULT'::"TravelerKind", 2),
        ('10000000-0000-4000-8000-000000000005'::UUID, 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa4'::UUID, 'ADULT'::"TravelerKind", 1),
        ('10000000-0000-4000-8000-000000000006'::UUID, 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa4'::UUID, 'CHILD'::"TravelerKind", 1),
        ('10000000-0000-4000-8000-000000000007'::UUID, 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa5'::UUID, 'ADULT'::"TravelerKind", 3),
        ('10000000-0000-4000-8000-000000000008'::UUID, 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa6'::UUID, 'ADULT'::"TravelerKind", 2),
        ('10000000-0000-4000-8000-000000000009'::UUID, 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa6'::UUID, 'CHILD'::"TravelerKind", 1),
        ('10000000-0000-4000-8000-000000000010'::UUID, 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa7'::UUID, 'ADULT'::"TravelerKind", 1),
        ('10000000-0000-4000-8000-000000000011'::UUID, 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa8'::UUID, 'ADULT'::"TravelerKind", 2),
        ('10000000-0000-4000-8000-000000000012'::UUID, 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa8'::UUID, 'CHILD'::"TravelerKind", 2),
        ('10000000-0000-4000-8000-000000000013'::UUID, 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa9'::UUID, 'ADULT'::"TravelerKind", 1),
        ('10000000-0000-4000-8000-000000000014'::UUID, 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa9'::UUID, 'CHILD'::"TravelerKind", 1),
        ('10000000-0000-4000-8000-000000000015'::UUID, 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaa10'::UUID, 'ADULT'::"TravelerKind", 2)
    ) AS v(detailId, bookingId, kind, quantity)
)
INSERT INTO "CHI_TIET_DAT_TOUR" (
    "id", "bookingId", "kind", "quantity", "unitPrice", "lineTotal"
)
SELECT
    d.detailId,
    d.bookingId,
    d.kind,
    d.quantity,
    CASE
        WHEN d.kind = 'ADULT' THEN s."adultPrice"
        ELSE s."childPrice"
    END,
    d.quantity * CASE
        WHEN d.kind = 'ADULT' THEN s."adultPrice"
        ELSE s."childPrice"
    END
FROM detail_data d
JOIN "DON_DAT_TOUR" b ON b."id" = d.bookingId
JOIN "LICH_KHOI_HANH" s ON s."id" = b."scheduleId"
ON CONFLICT ("id") DO NOTHING;

-- ------------------------------------------------------------
-- G. 10 THANH TOÁN DEMO
-- ------------------------------------------------------------

WITH payment_data AS (
    SELECT * FROM (VALUES
        ('50000000-0000-4000-8000-000000000001'::UUID, 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa1'::UUID, 'VNPAY'::"PaymentProvider", 'DEMO-VNPAY-001', 'TXN-DEMO-001', 'SUCCEEDED'::"PaymentStatus"),
        ('50000000-0000-4000-8000-000000000002'::UUID, 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa2'::UUID, 'MOMO'::"PaymentProvider", 'DEMO-MOMO-002', 'TXN-DEMO-002', 'SUCCEEDED'::"PaymentStatus"),
        ('50000000-0000-4000-8000-000000000003'::UUID, 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa3'::UUID, 'ZALOPAY'::"PaymentProvider", 'DEMO-ZALO-003', 'TXN-DEMO-003', 'SUCCEEDED'::"PaymentStatus"),
        ('50000000-0000-4000-8000-000000000004'::UUID, 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa4'::UUID, 'VNPAY'::"PaymentProvider", 'DEMO-VNPAY-004', 'TXN-DEMO-004', 'SUCCEEDED'::"PaymentStatus"),
        ('50000000-0000-4000-8000-000000000005'::UUID, 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa5'::UUID, 'MOMO'::"PaymentProvider", 'DEMO-MOMO-005', 'TXN-DEMO-005', 'SUCCEEDED'::"PaymentStatus"),
        ('50000000-0000-4000-8000-000000000006'::UUID, 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa6'::UUID, 'ZALOPAY'::"PaymentProvider", 'DEMO-ZALO-006', 'TXN-DEMO-006', 'SUCCEEDED'::"PaymentStatus"),
        ('50000000-0000-4000-8000-000000000007'::UUID, 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa7'::UUID, 'VNPAY'::"PaymentProvider", 'DEMO-VNPAY-007', 'TXN-DEMO-007', 'SUCCEEDED'::"PaymentStatus"),
        ('50000000-0000-4000-8000-000000000008'::UUID, 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa8'::UUID, 'MOMO'::"PaymentProvider", 'DEMO-MOMO-008', NULL, 'INITIATED'::"PaymentStatus"),
        ('50000000-0000-4000-8000-000000000009'::UUID, 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa9'::UUID, 'ZALOPAY'::"PaymentProvider", 'DEMO-ZALO-009', NULL, 'FAILED'::"PaymentStatus"),
        ('50000000-0000-4000-8000-000000000010'::UUID, 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaa10'::UUID, 'VNPAY'::"PaymentProvider", 'DEMO-VNPAY-010', 'TXN-DEMO-010', 'SUCCEEDED'::"PaymentStatus")
    ) AS v(paymentId, bookingId, provider, providerReference, transactionId, status)
)
INSERT INTO "THANH_TOAN" (
    "id", "bookingId", "provider", "providerReference", "transactionId",
    "amount", "currency", "status", "checkoutUrl", "createdAt", "updatedAt"
)
SELECT
    p.paymentId,
    p.bookingId,
    p.provider,
    p.providerReference,
    p.transactionId,
    b."totalAmount",
    'VND',
    p.status,
    NULL,
    b."createdAt",
    b."createdAt"
FROM payment_data p
JOIN "DON_DAT_TOUR" b ON b."id" = p.bookingId
ON CONFLICT ("id") DO NOTHING;

-- ------------------------------------------------------------
-- H. 10 AUDIT LOG DEMO
-- ------------------------------------------------------------

INSERT INTO "AuditLog" (
    "id", "actorId", "action", "entityId", "metadata", "createdAt"
)
VALUES
(
    '60000000-0000-4000-8000-000000000001',
    (SELECT "id" FROM "NGUOI_DUNG" WHERE "email" = 'admin@tour.local'),
    'CREATE_BOOKING',
    'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa1',
    jsonb_build_object('source', 'demo-sql', 'status', 'PAID'), CURRENT_TIMESTAMP
),
(
    '60000000-0000-4000-8000-000000000002',
    (SELECT "id" FROM "NGUOI_DUNG" WHERE "email" = 'admin@tour.local'),
    'PAYMENT_SUCCEEDED',
    '50000000-0000-4000-8000-000000000001',
    jsonb_build_object('provider', 'VNPAY', 'source', 'demo-sql'), CURRENT_TIMESTAMP
),
(
    '60000000-0000-4000-8000-000000000003',
    (SELECT "id" FROM "NGUOI_DUNG" WHERE "email" = 'admin@tour.local'),
    'CREATE_BOOKING',
    'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa2',
    jsonb_build_object('source', 'demo-sql', 'status', 'CONFIRMED'), CURRENT_TIMESTAMP
),
(
    '60000000-0000-4000-8000-000000000004',
    (SELECT "id" FROM "NGUOI_DUNG" WHERE "email" = 'admin@tour.local'),
    'PAYMENT_SUCCEEDED',
    '50000000-0000-4000-8000-000000000002',
    jsonb_build_object('provider', 'MOMO', 'source', 'demo-sql'), CURRENT_TIMESTAMP
),
(
    '60000000-0000-4000-8000-000000000005',
    (SELECT "id" FROM "NGUOI_DUNG" WHERE "email" = 'admin@tour.local'),
    'CREATE_BOOKING',
    'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa3',
    jsonb_build_object('source', 'demo-sql', 'status', 'COMPLETED'), CURRENT_TIMESTAMP
),
(
    '60000000-0000-4000-8000-000000000006',
    (SELECT "id" FROM "NGUOI_DUNG" WHERE "email" = 'admin@tour.local'),
    'CREATE_BOOKING',
    'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa4',
    jsonb_build_object('source', 'demo-sql', 'status', 'PAID'), CURRENT_TIMESTAMP
),
(
    '60000000-0000-4000-8000-000000000007',
    (SELECT "id" FROM "NGUOI_DUNG" WHERE "email" = 'admin@tour.local'),
    'CREATE_BOOKING',
    'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa5',
    jsonb_build_object('source', 'demo-sql', 'status', 'CONFIRMED'), CURRENT_TIMESTAMP
),
(
    '60000000-0000-4000-8000-000000000008',
    (SELECT "id" FROM "NGUOI_DUNG" WHERE "email" = 'admin@tour.local'),
    'BOOKING_PENDING_PAYMENT',
    'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa8',
    jsonb_build_object('expiresInMinutes', 10), CURRENT_TIMESTAMP
),
(
    '60000000-0000-4000-8000-000000000009',
    (SELECT "id" FROM "NGUOI_DUNG" WHERE "email" = 'admin@tour.local'),
    'BOOKING_CANCELLED',
    'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa9',
    jsonb_build_object('reason', 'Khách yêu cầu hủy đơn demo'), CURRENT_TIMESTAMP
),
(
    '60000000-0000-4000-8000-000000000010',
    (SELECT "id" FROM "NGUOI_DUNG" WHERE "email" = 'admin@tour.local'),
    'PAYMENT_SUCCEEDED',
    '50000000-0000-4000-8000-000000000010',
    jsonb_build_object('provider', 'VNPAY', 'source', 'demo-sql'), CURRENT_TIMESTAMP
)
ON CONFLICT ("id") DO NOTHING;

-- ------------------------------------------------------------
-- I. ĐỒNG BỘ RESERVED SEATS CHO 3 LỊCH DEMO
-- ------------------------------------------------------------

UPDATE "LICH_KHOI_HANH" s
SET "reservedSeats" = COALESCE(x."usedSeats", 0)
FROM (
    SELECT
        b."scheduleId",
        SUM(b."adults" + b."children")::INT AS "usedSeats"
    FROM "DON_DAT_TOUR" b
    WHERE (
        b."status" IN ('PAID', 'CONFIRMED', 'COMPLETED')
        OR (
            b."status" = 'PENDING_PAYMENT'
            AND b."expiresAt" > CURRENT_TIMESTAMP
        )
    )
    GROUP BY b."scheduleId"
) x
WHERE s."id" = x."scheduleId";

-- ------------------------------------------------------------
-- J. KIỂM TRA NHANH
-- ------------------------------------------------------------

SELECT 'TOUR' AS "table", COUNT(*) AS "count" FROM "TOUR"
UNION ALL
SELECT 'LICH_KHOI_HANH', COUNT(*) FROM "LICH_KHOI_HANH"
UNION ALL
SELECT 'NGUOI_DUNG', COUNT(*) FROM "NGUOI_DUNG"
UNION ALL
SELECT 'DON_DAT_TOUR', COUNT(*) FROM "DON_DAT_TOUR"
UNION ALL
SELECT 'CHI_TIET_DAT_TOUR', COUNT(*) FROM "CHI_TIET_DAT_TOUR"
UNION ALL
SELECT 'THANH_TOAN', COUNT(*) FROM "THANH_TOAN"
UNION ALL
SELECT 'AuditLog', COUNT(*) FROM "AuditLog";

-- ============================================================
-- FILE 2 KẾT THÚC
-- ============================================================
