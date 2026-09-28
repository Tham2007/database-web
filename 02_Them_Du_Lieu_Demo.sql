-- ============================================================
-- FILE 2: THÊM DỮ LIỆU DEMO
-- PostgreSQL
-- Đồng bộ hoàn toàn với cấu trúc CSDL trong FILE 1 (01_Tao_CSDL_Bang.sql)
-- Yêu cầu: Nạp chính xác 10 bản ghi mẫu cho MỖI BẢNG (8 bảng x 10 = 80 bản ghi)
-- ============================================================

-- ============================================================
-- 1. BẢNG NGUOI_DUNG (10 người dùng: 1 Admin, 2 Operations, 7 Customers)
-- Email bắt buộc là chữ thường để thỏa mãn CHECK "user_email_lowercase"
-- ============================================================

INSERT INTO "NGUOI_DUNG" (
    "id", "email", "name", "passwordHash", "role", "isActive", "createdAt"
)
VALUES
('00000000-0000-4000-8000-000000000001', 'admin@tour.local',       'Nguyễn Văn Admin',    '$2b$12$hash_admin_placeholder',       'ADMIN',      TRUE,  CURRENT_TIMESTAMP - INTERVAL '60 days'),
('00000000-0000-4000-8000-000000000002', 'ops.minh@tour.local',    'Trần Quốc Minh',      '$2b$12$hash_ops_minh_placeholder',    'OPERATIONS', TRUE,  CURRENT_TIMESTAMP - INTERVAL '55 days'),
('00000000-0000-4000-8000-000000000003', 'ops.hoa@tour.local',     'Lê Thị Hoa',          '$2b$12$hash_ops_hoa_placeholder',     'OPERATIONS', TRUE,  CURRENT_TIMESTAMP - INTERVAL '55 days'),
('11000000-0000-4000-8000-000000000001', 'customer01@demo.local', 'Nguyễn Minh Anh',    '$2b$12$hash_khach01_placeholder',     'CUSTOMER',   TRUE,  CURRENT_TIMESTAMP - INTERVAL '40 days'),
('11000000-0000-4000-8000-000000000002', 'customer02@demo.local', 'Trần Ngọc Mai',      '$2b$12$hash_khach02_placeholder',     'CUSTOMER',   TRUE,  CURRENT_TIMESTAMP - INTERVAL '35 days'),
('11000000-0000-4000-8000-000000000003', 'customer03@demo.local', 'Lê Hoàng Nam',       '$2b$12$hash_khach03_placeholder',     'CUSTOMER',   TRUE,  CURRENT_TIMESTAMP - INTERVAL '30 days'),
('11000000-0000-4000-8000-000000000004', 'customer04@demo.local', 'Phạm Thu Hà',        '$2b$12$hash_khach04_placeholder',     'CUSTOMER',   TRUE,  CURRENT_TIMESTAMP - INTERVAL '25 days'),
('11000000-0000-4000-8000-000000000005', 'customer05@demo.local', 'Đỗ Quốc Huy',        '$2b$12$hash_khach05_placeholder',     'CUSTOMER',   TRUE,  CURRENT_TIMESTAMP - INTERVAL '20 days'),
('11000000-0000-4000-8000-000000000006', 'customer06@demo.local', 'Vũ Khánh Linh',      '$2b$12$hash_khach06_placeholder',     'CUSTOMER',   TRUE,  CURRENT_TIMESTAMP - INTERVAL '15 days'),
('11000000-0000-4000-8000-000000000007', 'customer07@demo.local', 'Bùi Gia Bảo',        '$2b$12$hash_khach07_placeholder',     'CUSTOMER',   FALSE, CURRENT_TIMESTAMP - INTERVAL '10 days')
ON CONFLICT ("id") DO NOTHING;

-- ============================================================
-- 2. BẢNG RefreshSession (10 phiên đăng nhập mẫu)
-- ============================================================

INSERT INTO "RefreshSession" (
    "id", "userId", "tokenHash", "familyId", "expiresAt", "revokedAt", "createdAt"
)
VALUES
('b0000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000001', 'token_hash_session_01', 'f0000000-0000-4000-8000-000000000001', CURRENT_TIMESTAMP + INTERVAL '7 days', NULL,                                  CURRENT_TIMESTAMP - INTERVAL '2 days'),
('b0000000-0000-4000-8000-000000000002', '00000000-0000-4000-8000-000000000002', 'token_hash_session_02', 'f0000000-0000-4000-8000-000000000002', CURRENT_TIMESTAMP + INTERVAL '7 days', NULL,                                  CURRENT_TIMESTAMP - INTERVAL '2 days'),
('b0000000-0000-4000-8000-000000000003', '00000000-0000-4000-8000-000000000003', 'token_hash_session_03', 'f0000000-0000-4000-8000-000000000003', CURRENT_TIMESTAMP + INTERVAL '7 days', CURRENT_TIMESTAMP - INTERVAL '1 day',   CURRENT_TIMESTAMP - INTERVAL '3 days'),
('b0000000-0000-4000-8000-000000000004', '11000000-0000-4000-8000-000000000001', 'token_hash_session_04', 'f0000000-0000-4000-8000-000000000004', CURRENT_TIMESTAMP + INTERVAL '7 days', NULL,                                  CURRENT_TIMESTAMP - INTERVAL '1 day'),
('b0000000-0000-4000-8000-000000000005', '11000000-0000-4000-8000-000000000002', 'token_hash_session_05', 'f0000000-0000-4000-8000-000000000005', CURRENT_TIMESTAMP + INTERVAL '7 days', NULL,                                  CURRENT_TIMESTAMP - INTERVAL '1 day'),
('b0000000-0000-4000-8000-000000000006', '11000000-0000-4000-8000-000000000003', 'token_hash_session_06', 'f0000000-0000-4000-8000-000000000006', CURRENT_TIMESTAMP + INTERVAL '7 days', NULL,                                  CURRENT_TIMESTAMP - INTERVAL '12 hours'),
('b0000000-0000-4000-8000-000000000007', '11000000-0000-4000-8000-000000000004', 'token_hash_session_07', 'f0000000-0000-4000-8000-000000000007', CURRENT_TIMESTAMP + INTERVAL '7 days', NULL,                                  CURRENT_TIMESTAMP - INTERVAL '8 hours'),
('b0000000-0000-4000-8000-000000000008', '11000000-0000-4000-8000-000000000005', 'token_hash_session_08', 'f0000000-0000-4000-8000-000000000008', CURRENT_TIMESTAMP + INTERVAL '7 days', CURRENT_TIMESTAMP - INTERVAL '2 hours',  CURRENT_TIMESTAMP - INTERVAL '6 hours'),
('b0000000-0000-4000-8000-000000000009', '11000000-0000-4000-8000-000000000006', 'token_hash_session_09', 'f0000000-0000-4000-8000-000000000009', CURRENT_TIMESTAMP + INTERVAL '7 days', NULL,                                  CURRENT_TIMESTAMP - INTERVAL '3 hours'),
('b0000000-0000-4000-8000-000000000010', '11000000-0000-4000-8000-000000000007', 'token_hash_session_10', 'f0000000-0000-4000-8000-000000000010', CURRENT_TIMESTAMP + INTERVAL '7 days', NULL,                                  CURRENT_TIMESTAMP - INTERVAL '1 hour')
ON CONFLICT ("id") DO NOTHING;

-- ============================================================
-- 3. BẢNG TOUR (10 tour du lịch nội địa Việt Nam)
-- countryCode = 'VN', durationDays từ 1 đến 60
-- ============================================================

INSERT INTO "TOUR" (
    "id", "slug", "title", "description", "destination",
    "countryCode", "durationDays", "status", "deletedAt", "createdAt", "updatedAt"
)
VALUES
('01000000-0000-4000-8000-000000000001', 'ha-long-bay-3-ngay',        'Vịnh Hạ Long 3 Ngày 2 Đêm',          'Khám phá kỳ quan thế giới Vịnh Hạ Long, hang Sửng Sốt, chèo thuyền kayak.',                              'Quảng Ninh',        'VN', 3, 'ACTIVE',   NULL, CURRENT_TIMESTAMP - INTERVAL '50 days', CURRENT_TIMESTAMP - INTERVAL '50 days'),
('01000000-0000-4000-8000-000000000002', 'sapa-trekking-4-ngay',      'Sapa Trekking 4 Ngày 3 Đêm',         'Trekking qua các bản Tả Van, Mường Hoa, chinh phục đỉnh Fansipan bằng cáp treo.',                        'Lào Cai',           'VN', 4, 'ACTIVE',   NULL, CURRENT_TIMESTAMP - INTERVAL '48 days', CURRENT_TIMESTAMP - INTERVAL '48 days'),
('01000000-0000-4000-8000-000000000003', 'da-nang-hoi-an-5-ngay',     'Đà Nẵng - Hội An 5 Ngày 4 Đêm',     'Tham quan Bà Nà Hills, Cầu Vàng, phố cổ Hội An lung linh đèn lồng.',                                    'Đà Nẵng',           'VN', 5, 'ACTIVE',   NULL, CURRENT_TIMESTAMP - INTERVAL '45 days', CURRENT_TIMESTAMP - INTERVAL '45 days'),
('01000000-0000-4000-8000-000000000004', 'phu-quoc-resort-4-ngay',    'Phú Quốc Resort 4 Ngày 3 Đêm',      'Nghỉ dưỡng resort 5 sao Phú Quốc, lặn ngắm san hô, ngắm hoàng hôn Sunset Sanato.',                       'Kiên Giang',        'VN', 4, 'ACTIVE',   NULL, CURRENT_TIMESTAMP - INTERVAL '42 days', CURRENT_TIMESTAMP - INTERVAL '42 days'),
('01000000-0000-4000-8000-000000000005', 'dalat-langbiang-3-ngay',    'Đà Lạt - Langbiang 3 Ngày 2 Đêm',   'Chinh phục đỉnh Langbiang, Thung Lũng Tình Yêu, trải nghiệm cà phê view mây ngàn.',                     'Lâm Đồng',          'VN', 3, 'ACTIVE',   NULL, CURRENT_TIMESTAMP - INTERVAL '40 days', CURRENT_TIMESTAMP - INTERVAL '40 days'),
('01000000-0000-4000-8000-000000000006', 'ninh-binh-trang-an-2-ngay', 'Ninh Bình - Tràng An 2 Ngày 1 Đêm', 'Chèo thuyền ngắm danh thắng Tràng An di sản thế giới, viếng chùa Bái Đính nguy nga.',                 'Ninh Bình',         'VN', 2, 'ACTIVE',   NULL, CURRENT_TIMESTAMP - INTERVAL '38 days', CURRENT_TIMESTAMP - INTERVAL '38 days'),
('01000000-0000-4000-8000-000000000007', 'quy-nhon-phu-yen-5-ngay',   'Quy Nhơn - Phú Yên 5 Ngày 4 Đêm',  'Khám phá Eo Gió, Kỳ Co nước trong vắt, gành Đá Đĩa và hải đăng Mũi Điện đón bình minh.',                 'Bình Định',         'VN', 5, 'ACTIVE',   NULL, CURRENT_TIMESTAMP - INTERVAL '35 days', CURRENT_TIMESTAMP - INTERVAL '35 days'),
('01000000-0000-4000-8000-000000000008', 'ha-giang-loop-4-ngay',      'Hà Giang Loop 4 Ngày 3 Đêm',        'Cung đường đèo Mã Pí Lèng huyền thoại, dòng sông Nho Quế xanh ngọc và cao nguyên đá Đồng Văn.',        'Hà Giang',          'VN', 4, 'DRAFT',    NULL, CURRENT_TIMESTAMP - INTERVAL '20 days', CURRENT_TIMESTAMP - INTERVAL '20 days'),
('01000000-0000-4000-8000-000000000009', 'con-dao-4-ngay',            'Côn Đảo Huyền Thoại 4 Ngày 3 Đêm',  'Tham quan di tích lịch sử nhà tù Côn Đảo, nghĩa trang Hàng Dương, tắm biển Đầm Trầu hoang sơ.',        'Bà Rịa-Vũng Tàu',   'VN', 4, 'INACTIVE', NULL, CURRENT_TIMESTAMP - INTERVAL '30 days', CURRENT_TIMESTAMP - INTERVAL '10 days'),
('01000000-0000-4000-8000-000000000010', 'mekong-delta-3-ngay',       'Miền Tây Sông Nước 3 Ngày 2 Đêm',   'Trải nghiệm chợ nổi Cái Răng tấp nập, miệt vườn trái cây trĩu quả, nghe đờn ca tài tử.',                'Cần Thơ',           'VN', 3, 'ACTIVE',   NULL, CURRENT_TIMESTAMP - INTERVAL '25 days', CURRENT_TIMESTAMP - INTERVAL '25 days')
ON CONFLICT ("id") DO NOTHING;

-- ============================================================
-- 4. BẢNG LICH_KHOI_HANH (10 lịch khởi hành mẫu)
-- Ràng buộc: totalSeats BETWEEN 1 AND 10000, reservedSeats <= totalSeats
-- ============================================================

INSERT INTO "LICH_KHOI_HANH" (
    "id", "tourId", "departureAt", "totalSeats", "reservedSeats",
    "adultPrice", "childPrice", "status"
)
VALUES
('02000000-0000-4000-8000-000000000001', '01000000-0000-4000-8000-000000000001', CURRENT_TIMESTAMP + INTERVAL '15 days', 30, 3, 4500000, 3200000, 'OPEN'),
('02000000-0000-4000-8000-000000000002', '01000000-0000-4000-8000-000000000001', CURRENT_TIMESTAMP + INTERVAL '30 days', 30, 0, 4500000, 3200000, 'OPEN'),
('02000000-0000-4000-8000-000000000003', '01000000-0000-4000-8000-000000000002', CURRENT_TIMESTAMP + INTERVAL '20 days', 25, 5, 5200000, 3800000, 'OPEN'),
('02000000-0000-4000-8000-000000000004', '01000000-0000-4000-8000-000000000003', CURRENT_TIMESTAMP + INTERVAL '25 days', 40, 2, 6800000, 4500000, 'OPEN'),
('02000000-0000-4000-8000-000000000005', '01000000-0000-4000-8000-000000000004', CURRENT_TIMESTAMP + INTERVAL '40 days', 25, 0, 7500000, 5000000, 'OPEN'),
('02000000-0000-4000-8000-000000000006', '01000000-0000-4000-8000-000000000005', CURRENT_TIMESTAMP + INTERVAL '18 days', 35, 1, 3800000, 2500000, 'OPEN'),
('02000000-0000-4000-8000-000000000007', '01000000-0000-4000-8000-000000000006', CURRENT_TIMESTAMP + INTERVAL '12 days', 45, 6, 2500000, 1800000, 'OPEN'),
('02000000-0000-4000-8000-000000000008', '01000000-0000-4000-8000-000000000007', CURRENT_TIMESTAMP + INTERVAL '35 days', 30, 3, 8500000, 6000000, 'OPEN'),
('02000000-0000-4000-8000-000000000009', '01000000-0000-4000-8000-000000000010', CURRENT_TIMESTAMP + INTERVAL '28 days', 35, 4, 3200000, 2200000, 'OPEN'),
('02000000-0000-4000-8000-000000000010', '01000000-0000-4000-8000-000000000001', CURRENT_TIMESTAMP - INTERVAL '10 days', 30, 1, 4200000, 3000000, 'CLOSED')
ON CONFLICT ("id") DO NOTHING;

-- ============================================================
-- 5. BẢNG DON_DAT_TOUR (10 đơn đặt tour mẫu)
-- Ràng buộc:
-- - expiresAt = createdAt + INTERVAL '15 minutes' (exact_hold)
-- - (status = 'CANCELLED') = (seatsReleasedAt IS NOT NULL) (release_matches_cancel)
-- - CANCELLED phải có đủ cancelledAt, cancelReason, seatsReleasedAt (cancel_fields_match_status)
-- ============================================================

INSERT INTO "DON_DAT_TOUR" (
    "id", "userId", "scheduleId", "idempotencyKey", "requestHash",
    "status", "adults", "children", "totalAmount", "currency", "tourTitle",
    "contactName", "contactEmail", "contactPhone", "expiresAt", "createdAt",
    "paidAt", "cancelledAt", "cancelReason", "seatsReleasedAt"
)
VALUES
-- Đơn 1: PAID - Nguyễn Minh Anh đặt Hạ Long
(
    'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa1',
    '11000000-0000-4000-8000-000000000001',
    '02000000-0000-4000-8000-000000000001',
    'e1111111-0000-4000-8000-000000000001',
    'reqhash01_sha256_placeholder',
    'PAID', 2, 1, 12200000, 'VND', 'Vịnh Hạ Long 3 Ngày 2 Đêm',
    'Nguyễn Minh Anh', 'customer01@demo.local', '0901234567',
    CURRENT_TIMESTAMP - INTERVAL '3 days' + INTERVAL '15 minutes',
    CURRENT_TIMESTAMP - INTERVAL '3 days',
    CURRENT_TIMESTAMP - INTERVAL '3 days' + INTERVAL '10 minutes',
    NULL, NULL, NULL
),
-- Đơn 2: CONFIRMED - Trần Ngọc Mai đặt Sapa
(
    'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa2',
    '11000000-0000-4000-8000-000000000002',
    '02000000-0000-4000-8000-000000000003',
    'e1111111-0000-4000-8000-000000000002',
    'reqhash02_sha256_placeholder',
    'CONFIRMED', 3, 2, 23200000, 'VND', 'Sapa Trekking 4 Ngày 3 Đêm',
    'Trần Ngọc Mai', 'customer02@demo.local', '0912345678',
    CURRENT_TIMESTAMP - INTERVAL '4 days' + INTERVAL '15 minutes',
    CURRENT_TIMESTAMP - INTERVAL '4 days',
    CURRENT_TIMESTAMP - INTERVAL '4 days' + INTERVAL '5 minutes',
    NULL, NULL, NULL
),
-- Đơn 3: COMPLETED - Lê Hoàng Nam đặt Đà Nẵng
(
    'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa3',
    '11000000-0000-4000-8000-000000000003',
    '02000000-0000-4000-8000-000000000004',
    'e1111111-0000-4000-8000-000000000003',
    'reqhash03_sha256_placeholder',
    'COMPLETED', 2, 0, 13600000, 'VND', 'Đà Nẵng - Hội An 5 Ngày 4 Đêm',
    'Lê Hoàng Nam', 'customer03@demo.local', '0923456789',
    CURRENT_TIMESTAMP - INTERVAL '5 days' + INTERVAL '15 minutes',
    CURRENT_TIMESTAMP - INTERVAL '5 days',
    CURRENT_TIMESTAMP - INTERVAL '5 days' + INTERVAL '8 minutes',
    NULL, NULL, NULL
),
-- Đơn 4: CANCELLED - Phạm Thu Hà hủy đặt Phú Quốc
(
    'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa4',
    '11000000-0000-4000-8000-000000000004',
    '02000000-0000-4000-8000-000000000005',
    'e1111111-0000-4000-8000-000000000004',
    'reqhash04_sha256_placeholder',
    'CANCELLED', 2, 1, 20000000, 'VND', 'Phú Quốc Resort 4 Ngày 3 Đêm',
    'Phạm Thu Hà', 'customer04@demo.local', '0934567890',
    CURRENT_TIMESTAMP - INTERVAL '6 days' + INTERVAL '15 minutes',
    CURRENT_TIMESTAMP - INTERVAL '6 days',
    NULL,
    CURRENT_TIMESTAMP - INTERVAL '6 days' + INTERVAL '10 minutes',
    'Khách hủy vì thay đổi kế hoạch cá nhân',
    CURRENT_TIMESTAMP - INTERVAL '6 days' + INTERVAL '10 minutes'
),
-- Đơn 5: PENDING_PAYMENT - Đỗ Quốc Huy đặt Đà Lạt
(
    'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa5',
    '11000000-0000-4000-8000-000000000005',
    '02000000-0000-4000-8000-000000000006',
    'e1111111-0000-4000-8000-000000000005',
    'reqhash05_sha256_placeholder',
    'PENDING_PAYMENT', 1, 0, 3800000, 'VND', 'Đà Lạt - Langbiang 3 Ngày 2 Đêm',
    'Đỗ Quốc Huy', 'customer05@demo.local', '0945678901',
    CURRENT_TIMESTAMP - INTERVAL '5 minutes' + INTERVAL '15 minutes',
    CURRENT_TIMESTAMP - INTERVAL '5 minutes',
    NULL, NULL, NULL, NULL
),
-- Đơn 6: PAID - Vũ Khánh Linh đặt Ninh Bình
(
    'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa6',
    '11000000-0000-4000-8000-000000000006',
    '02000000-0000-4000-8000-000000000007',
    'e1111111-0000-4000-8000-000000000006',
    'reqhash06_sha256_placeholder',
    'PAID', 4, 2, 13600000, 'VND', 'Ninh Bình - Tràng An 2 Ngày 1 Đêm',
    'Vũ Khánh Linh', 'customer06@demo.local', '0956789012',
    CURRENT_TIMESTAMP - INTERVAL '7 days' + INTERVAL '15 minutes',
    CURRENT_TIMESTAMP - INTERVAL '7 days',
    CURRENT_TIMESTAMP - INTERVAL '7 days' + INTERVAL '12 minutes',
    NULL, NULL, NULL
),
-- Đơn 7: CONFIRMED - Nguyễn Minh Anh đặt Quy Nhơn
(
    'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa7',
    '11000000-0000-4000-8000-000000000001',
    '02000000-0000-4000-8000-000000000008',
    'e1111111-0000-4000-8000-000000000007',
    'reqhash07_sha256_placeholder',
    'CONFIRMED', 2, 1, 23000000, 'VND', 'Quy Nhơn - Phú Yên 5 Ngày 4 Đêm',
    'Nguyễn Minh Anh', 'customer01@demo.local', '0901234567',
    CURRENT_TIMESTAMP - INTERVAL '8 days' + INTERVAL '15 minutes',
    CURRENT_TIMESTAMP - INTERVAL '8 days',
    CURRENT_TIMESTAMP - INTERVAL '8 days' + INTERVAL '7 minutes',
    NULL, NULL, NULL
),
-- Đơn 8: PAID - Trần Ngọc Mai đặt Miền Tây
(
    'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa8',
    '11000000-0000-4000-8000-000000000002',
    '02000000-0000-4000-8000-000000000009',
    'e1111111-0000-4000-8000-000000000008',
    'reqhash08_sha256_placeholder',
    'PAID', 2, 2, 10800000, 'VND', 'Miền Tây Sông Nước 3 Ngày 2 Đêm',
    'Trần Ngọc Mai', 'customer02@demo.local', '0912345678',
    CURRENT_TIMESTAMP - INTERVAL '9 days' + INTERVAL '15 minutes',
    CURRENT_TIMESTAMP - INTERVAL '9 days',
    CURRENT_TIMESTAMP - INTERVAL '9 days' + INTERVAL '11 minutes',
    NULL, NULL, NULL
),
-- Đơn 9: COMPLETED - Lê Hoàng Nam đặt Hạ Long (đã xong)
(
    'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa9',
    '11000000-0000-4000-8000-000000000003',
    '02000000-0000-4000-8000-000000000010',
    'e1111111-0000-4000-8000-000000000009',
    'reqhash09_sha256_placeholder',
    'COMPLETED', 1, 0, 4200000, 'VND', 'Vịnh Hạ Long 3 Ngày 2 Đêm',
    'Lê Hoàng Nam', 'customer03@demo.local', '0923456789',
    CURRENT_TIMESTAMP - INTERVAL '15 days' + INTERVAL '15 minutes',
    CURRENT_TIMESTAMP - INTERVAL '15 days',
    CURRENT_TIMESTAMP - INTERVAL '15 days' + INTERVAL '9 minutes',
    NULL, NULL, NULL
),
-- Đơn 10: CANCELLED - Bùi Gia Bảo hủy đặt Hạ Long
(
    'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaa10',
    '11000000-0000-4000-8000-000000000007',
    '02000000-0000-4000-8000-000000000002',
    'e1111111-0000-4000-8000-000000000010',
    'reqhash10_sha256_placeholder',
    'CANCELLED', 1, 1, 7700000, 'VND', 'Vịnh Hạ Long 3 Ngày 2 Đêm',
    'Bùi Gia Bảo', 'customer07@demo.local', '0967890123',
    CURRENT_TIMESTAMP - INTERVAL '12 days' + INTERVAL '15 minutes',
    CURRENT_TIMESTAMP - INTERVAL '12 days',
    NULL,
    CURRENT_TIMESTAMP - INTERVAL '12 days' + INTERVAL '12 minutes',
    'Khách bận việc đột xuất yêu cầu hủy đơn',
    CURRENT_TIMESTAMP - INTERVAL '12 days' + INTERVAL '12 minutes'
)
ON CONFLICT ("id") DO NOTHING;

-- ============================================================
-- 6. BẢNG CHI_TIET_DAT_TOUR (10 bản ghi chi tiết: ADULT + CHILD)
-- Ràng buộc: quantity > 0, unitPrice >= 0, lineTotal = quantity * unitPrice
-- ============================================================

INSERT INTO "CHI_TIET_DAT_TOUR" (
    "id", "bookingId", "kind", "quantity", "unitPrice", "lineTotal"
)
VALUES
-- Đơn 1: 2 người lớn (4.500.000) + 1 trẻ em (3.200.000) = 12.200.000
('10000000-0000-4000-8000-000000000001', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa1', 'ADULT', 2, 4500000, 9000000),
('10000000-0000-4000-8000-000000000002', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa1', 'CHILD', 1, 3200000, 3200000),

-- Đơn 2: 3 người lớn (5.200.000) + 2 trẻ em (3.800.000) = 23.200.000
('10000000-0000-4000-8000-000000000003', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa2', 'ADULT', 3, 5200000, 15600000),
('10000000-0000-4000-8000-000000000004', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa2', 'CHILD', 2, 3800000, 7600000),

-- Đơn 3: 2 người lớn (6.800.000) = 13.600.000
('10000000-0000-4000-8000-000000000005', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa3', 'ADULT', 2, 6800000, 13600000),

-- Đơn 5: 1 người lớn (3.800.000) = 3.800.000
('10000000-0000-4000-8000-000000000006', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa5', 'ADULT', 1, 3800000, 3800000),

-- Đơn 6: 4 người lớn (2.500.000) + 2 trẻ em (1.800.000) = 13.600.000
('10000000-0000-4000-8000-000000000007', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa6', 'ADULT', 4, 2500000, 10000000),
('10000000-0000-4000-8000-000000000008', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa6', 'CHILD', 2, 1800000, 3600000),

-- Đơn 8: 2 người lớn (3.200.000) + 2 trẻ em (2.200.000) = 10.800.000
('10000000-0000-4000-8000-000000000009', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa8', 'ADULT', 2, 3200000, 6400000),
('10000000-0000-4000-8000-000000000010', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa8', 'CHILD', 2, 2200000, 4400000)
ON CONFLICT ("id") DO NOTHING;

-- ============================================================
-- 7. BẢNG THANH_TOAN (10 giao dịch thanh toán mẫu)
-- Ràng buộc:
-- - status = 'REFUNDED' => refundedAt và refundReference không được NULL
-- - status <> 'REFUNDED' => refundedAt và refundReference phải là NULL
-- ============================================================

INSERT INTO "THANH_TOAN" (
    "id", "bookingId", "provider", "providerReference", "transactionId",
    "amount", "currency", "status", "checkoutUrl", "createdAt", "updatedAt",
    "refundedAt", "refundReference"
)
VALUES
-- Đơn 1: VNPAY thành công
('50000000-0000-4000-8000-000000000001', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa1', 'VNPAY',   'VNPAY-REF-001', 'TXN-VNPAY-001', 12200000, 'VND', 'SUCCEEDED', 'https://sandbox.vnpayment.vn/checkout/001', CURRENT_TIMESTAMP - INTERVAL '3 days' + INTERVAL '5 minutes', CURRENT_TIMESTAMP - INTERVAL '3 days' + INTERVAL '10 minutes', NULL, NULL),

-- Đơn 2: MOMO thành công
('50000000-0000-4000-8000-000000000002', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa2', 'MOMO',    'MOMO-REF-002',  'TXN-MOMO-002',  23200000, 'VND', 'SUCCEEDED', 'https://test-payment.momo.vn/checkout/002',  CURRENT_TIMESTAMP - INTERVAL '4 days' + INTERVAL '2 minutes', CURRENT_TIMESTAMP - INTERVAL '4 days' + INTERVAL '5 minutes',  NULL, NULL),

-- Đơn 3: ZALOPAY thành công
('50000000-0000-4000-8000-000000000003', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa3', 'ZALOPAY', 'ZALO-REF-003',  'TXN-ZALO-003',  13600000, 'VND', 'SUCCEEDED', 'https://sandbox.zalopay.vn/checkout/003',    CURRENT_TIMESTAMP - INTERVAL '5 days' + INTERVAL '3 minutes', CURRENT_TIMESTAMP - INTERVAL '5 days' + INTERVAL '8 minutes',  NULL, NULL),

-- Đơn 4: VNPAY đã hoàn tiền (đơn đã hủy)
('50000000-0000-4000-8000-000000000004', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa4', 'VNPAY',   'VNPAY-REF-004', 'TXN-VNPAY-004', 20000000, 'VND', 'REFUNDED',  'https://sandbox.vnpayment.vn/checkout/004', CURRENT_TIMESTAMP - INTERVAL '6 days' + INTERVAL '2 minutes', CURRENT_TIMESTAMP - INTERVAL '6 days' + INTERVAL '2 hours',    CURRENT_TIMESTAMP - INTERVAL '6 days' + INTERVAL '2 hours', 'REFUND-VNPAY-004'),

-- Đơn 5: MOMO đang chờ thanh toán
('50000000-0000-4000-8000-000000000005', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa5', 'MOMO',    'MOMO-REF-005',  NULL,             3800000,  'VND', 'INITIATED', 'https://test-payment.momo.vn/checkout/005',  CURRENT_TIMESTAMP - INTERVAL '3 minutes',                    CURRENT_TIMESTAMP - INTERVAL '3 minutes',                    NULL, NULL),

-- Đơn 6: VNPAY thành công
('50000000-0000-4000-8000-000000000006', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa6', 'VNPAY',   'VNPAY-REF-006', 'TXN-VNPAY-006', 13600000, 'VND', 'SUCCEEDED', 'https://sandbox.vnpayment.vn/checkout/006', CURRENT_TIMESTAMP - INTERVAL '7 days' + INTERVAL '3 minutes', CURRENT_TIMESTAMP - INTERVAL '7 days' + INTERVAL '12 minutes', NULL, NULL),

-- Đơn 7: ZALOPAY thành công
('50000000-0000-4000-8000-000000000007', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa7', 'ZALOPAY', 'ZALO-REF-007',  'TXN-ZALO-007',  23000000, 'VND', 'SUCCEEDED', 'https://sandbox.zalopay.vn/checkout/007',    CURRENT_TIMESTAMP - INTERVAL '8 days' + INTERVAL '3 minutes', CURRENT_TIMESTAMP - INTERVAL '8 days' + INTERVAL '7 minutes',  NULL, NULL),

-- Đơn 8: MOMO thành công
('50000000-0000-4000-8000-000000000008', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa8', 'MOMO',    'MOMO-REF-008',  'TXN-MOMO-008',  10800000, 'VND', 'SUCCEEDED', 'https://test-payment.momo.vn/checkout/008',  CURRENT_TIMESTAMP - INTERVAL '9 days' + INTERVAL '3 minutes', CURRENT_TIMESTAMP - INTERVAL '9 days' + INTERVAL '11 minutes', NULL, NULL),

-- Đơn 9: VNPAY thành công
('50000000-0000-4000-8000-000000000009', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa9', 'VNPAY',   'VNPAY-REF-009', 'TXN-VNPAY-009', 4200000,  'VND', 'SUCCEEDED', 'https://sandbox.vnpayment.vn/checkout/009', CURRENT_TIMESTAMP - INTERVAL '15 days' + INTERVAL '3 minutes',CURRENT_TIMESTAMP - INTERVAL '15 days' + INTERVAL '9 minutes',NULL, NULL),

-- Đơn 10: ZALOPAY đã hoàn tiền (đơn đã hủy)
('50000000-0000-4000-8000-000000000010', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaa10', 'ZALOPAY', 'ZALO-REF-010',  'TXN-ZALO-010',  7700000,  'VND', 'REFUNDED',  'https://sandbox.zalopay.vn/checkout/010',    CURRENT_TIMESTAMP - INTERVAL '12 days' + INTERVAL '3 minutes',CURRENT_TIMESTAMP - INTERVAL '12 days' + INTERVAL '2 hours',   CURRENT_TIMESTAMP - INTERVAL '12 days' + INTERVAL '2 hours', 'REFUND-ZALO-010')
ON CONFLICT ("id") DO NOTHING;

-- ============================================================
-- 8. BẢNG AuditLog (10 bản ghi nhật ký kiểm toán)
-- ============================================================

INSERT INTO "AuditLog" (
    "id", "actorId", "action", "entityId", "metadata", "createdAt"
)
VALUES
('60000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000001', 'TOUR_CREATED',        '01000000-0000-4000-8000-000000000001', '{"title": "Vịnh Hạ Long 3 Ngày 2 Đêm"}'::JSONB,                                                 CURRENT_TIMESTAMP - INTERVAL '50 days'),
('60000000-0000-4000-8000-000000000002', '00000000-0000-4000-8000-000000000001', 'TOUR_ACTIVATED',      '01000000-0000-4000-8000-000000000003', '{"title": "Đà Nẵng - Hội An 5 Ngày 4 Đêm", "oldStatus": "DRAFT"}'::JSONB,                       CURRENT_TIMESTAMP - INTERVAL '45 days'),
('60000000-0000-4000-8000-000000000003', '00000000-0000-4000-8000-000000000002', 'SCHEDULE_CREATED',    '02000000-0000-4000-8000-000000000001', '{"tourId": "01000000-0000-4000-8000-000000000001", "totalSeats": 30}'::JSONB,                          CURRENT_TIMESTAMP - INTERVAL '30 days'),
('60000000-0000-4000-8000-000000000004', '11000000-0000-4000-8000-000000000001', 'BOOKING_CREATED',     'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa1', '{"scheduleId": "02000000-0000-4000-8000-000000000001", "totalAmount": 12200000}'::JSONB,              CURRENT_TIMESTAMP - INTERVAL '3 days'),
('60000000-0000-4000-8000-000000000005', NULL,                                   'PAYMENT_SUCCEEDED',   '50000000-0000-4000-8000-000000000001', '{"provider": "VNPAY", "amount": 12200000}'::JSONB,                                             CURRENT_TIMESTAMP - INTERVAL '3 days' + INTERVAL '10 minutes'),
('60000000-0000-4000-8000-000000000006', '11000000-0000-4000-8000-000000000004', 'BOOKING_CANCELLED',   'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa4', '{"reason": "Khách hủy vì thay đổi kế hoạch cá nhân"}'::JSONB,                                         CURRENT_TIMESTAMP - INTERVAL '6 days' + INTERVAL '10 minutes'),
('60000000-0000-4000-8000-000000000007', '00000000-0000-4000-8000-000000000001', 'PAYMENT_REFUNDED',    '50000000-0000-4000-8000-000000000004', '{"refundRef": "REFUND-VNPAY-004", "amount": 20000000}'::JSONB,                                 CURRENT_TIMESTAMP - INTERVAL '6 days' + INTERVAL '2 hours'),
('60000000-0000-4000-8000-000000000008', '00000000-0000-4000-8000-000000000001', 'USER_DEACTIVATED',    '11000000-0000-4000-8000-000000000007', '{"email": "customer07@demo.local", "reason": "Tài khoản có dấu hiệu bất thường"}'::JSONB,              CURRENT_TIMESTAMP - INTERVAL '10 days'),
('60000000-0000-4000-8000-000000000009', '00000000-0000-4000-8000-000000000002', 'SCHEDULE_CLOSED',     '02000000-0000-4000-8000-000000000010', '{"tourId": "01000000-0000-4000-8000-000000000001", "reason": "Hết hạn bán vé"}'::JSONB,                 CURRENT_TIMESTAMP - INTERVAL '10 days'),
('60000000-0000-4000-8000-000000000010', '00000000-0000-4000-8000-000000000003', 'TOUR_STATUS_CHANGED', '01000000-0000-4000-8000-000000000009', '{"title": "Côn Đảo Huyền Thoại 4 Ngày 3 Đêm", "oldStatus": "ACTIVE", "newStatus": "INACTIVE"}'::JSONB, CURRENT_TIMESTAMP - INTERVAL '10 days')
ON CONFLICT ("id") DO NOTHING;

-- ============================================================
-- 9. ĐỒNG BỘ CHÍNH XÁC SỐ CHỖ ĐÃ GIỮ (reservedSeats) CHO CÁC LỊCH
-- ============================================================

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

-- Đảm bảo các lịch không có đơn thì reservedSeats = 0
UPDATE "LICH_KHOI_HANH"
SET "reservedSeats" = 0
WHERE "id" NOT IN (
    SELECT DISTINCT b."scheduleId"
    FROM "DON_DAT_TOUR" b
    WHERE (
        b."status" IN ('PAID', 'CONFIRMED', 'COMPLETED')
        OR (
            b."status" = 'PENDING_PAYMENT'
            AND b."expiresAt" > CURRENT_TIMESTAMP
        )
    )
);

-- ============================================================
-- 10. KIỂM TRA SỐ LƯỢNG BẢN GHI DEMO CỦA CẢ 8 BẢNG (ĐỀU ĐẠT 10 DÒNG)
-- ============================================================

SELECT 'NGUOI_DUNG'        AS "Bảng", COUNT(*) AS "Số dòng demo" FROM "NGUOI_DUNG"
UNION ALL
SELECT 'RefreshSession',              COUNT(*)                   FROM "RefreshSession"
UNION ALL
SELECT 'TOUR',                        COUNT(*)                   FROM "TOUR"
UNION ALL
SELECT 'LICH_KHOI_HANH',              COUNT(*)                   FROM "LICH_KHOI_HANH"
UNION ALL
SELECT 'DON_DAT_TOUR',                COUNT(*)                   FROM "DON_DAT_TOUR"
UNION ALL
SELECT 'CHI_TIET_DAT_TOUR',           COUNT(*)                   FROM "CHI_TIET_DAT_TOUR"
UNION ALL
SELECT 'THANH_TOAN',                  COUNT(*)                   FROM "THANH_TOAN"
UNION ALL
SELECT 'AuditLog',                    COUNT(*)                   FROM "AuditLog";

-- ============================================================
-- FILE 2 KẾT THÚC
-- ============================================================
