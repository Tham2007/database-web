-- ============================================================
-- DATABASE: QUẢNG BÁ VÀ ĐẶT TOUR DU LỊCH TRỰC TUYẾN
-- Tác giả: Hồng Thắm
-- Ngày tạo: 23/09/2026
-- Mô tả: Script tạo đầy đủ CSDL gồm 8 bảng, ràng buộc,
--         chỉ mục và dữ liệu demo (10 dòng/bảng)
-- DBMS: SQL Server (T-SQL)
-- ============================================================

-- ============================================================
-- PHẦN 0: TẠO DATABASE
-- ============================================================
USE master;
GO

IF DB_ID('TourBookingDB') IS NOT NULL
BEGIN
    ALTER DATABASE TourBookingDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE TourBookingDB;
END
GO

CREATE DATABASE TourBookingDB;
GO

USE TourBookingDB;
GO


-- ============================================================
-- PHẦN 1: TẠO BẢNG VÀ RÀNG BUỘC
-- SQL Server không có ENUM, dùng CHECK constraint thay thế
-- SQL Server không có UUID native, dùng UNIQUEIDENTIFIER
-- ============================================================

-- ----------------------------------------------------------
-- 1.1 NGUOI_DUNG (User)
-- ----------------------------------------------------------
CREATE TABLE NGUOI_DUNG (
    id              UNIQUEIDENTIFIER    NOT NULL DEFAULT NEWID(),
    email           NVARCHAR(254)       NOT NULL,
    [name]          NVARCHAR(100)       NOT NULL,
    passwordHash    NVARCHAR(MAX)       NOT NULL,
    [role]          NVARCHAR(20)        NOT NULL DEFAULT 'CUSTOMER',
    isActive        BIT                 NOT NULL DEFAULT 1,
    createdAt       DATETIME2(3)        NOT NULL DEFAULT SYSDATETIME(),

    -- Khóa chính
    CONSTRAINT PK_NGUOI_DUNG PRIMARY KEY (id),

    -- Email phải duy nhất
    CONSTRAINT UQ_NGUOI_DUNG_email UNIQUE (email),

    -- Email phải là chữ thường
    CONSTRAINT CK_NGUOI_DUNG_email_lower CHECK (email = LOWER(email) COLLATE Latin1_General_BIN),

    -- Vai trò hợp lệ (thay ENUM)
    CONSTRAINT CK_NGUOI_DUNG_role CHECK ([role] IN ('CUSTOMER', 'OPERATIONS', 'ADMIN'))
);
GO

-- ----------------------------------------------------------
-- 1.2 RefreshSession
-- ----------------------------------------------------------
CREATE TABLE RefreshSession (
    id              UNIQUEIDENTIFIER    NOT NULL DEFAULT NEWID(),
    userId          UNIQUEIDENTIFIER    NOT NULL,
    tokenHash       NVARCHAR(MAX)       NOT NULL,
    familyId        UNIQUEIDENTIFIER    NOT NULL,
    expiresAt       DATETIME2(3)        NOT NULL,
    revokedAt       DATETIME2(3)        NULL,
    createdAt       DATETIME2(3)        NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT PK_RefreshSession PRIMARY KEY (id),

    -- FK: xóa user → xóa luôn session
    CONSTRAINT FK_Refresh_User FOREIGN KEY (userId)
        REFERENCES NGUOI_DUNG (id) ON DELETE CASCADE ON UPDATE CASCADE
);
GO

-- Index tìm phiên theo user
CREATE INDEX IX_Refresh_User_Family ON RefreshSession (userId, familyId);
GO

-- ----------------------------------------------------------
-- 1.3 TOUR
-- ----------------------------------------------------------
CREATE TABLE TOUR (
    id              UNIQUEIDENTIFIER    NOT NULL DEFAULT NEWID(),
    slug            NVARCHAR(150)       NOT NULL,
    title           NVARCHAR(150)       NOT NULL,
    [description]   NVARCHAR(MAX)       NOT NULL,
    destination     NVARCHAR(100)       NOT NULL,
    countryCode     NCHAR(2)            NOT NULL DEFAULT N'VN',
    durationDays    INT                 NOT NULL,
    [status]        NVARCHAR(20)        NOT NULL DEFAULT 'DRAFT',
    deletedAt       DATETIME2(3)        NULL,
    createdAt       DATETIME2(3)        NOT NULL DEFAULT SYSDATETIME(),
    updatedAt       DATETIME2(3)        NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT PK_TOUR PRIMARY KEY (id),

    -- Slug duy nhất
    CONSTRAINT UQ_TOUR_slug UNIQUE (slug),

    -- Chỉ tour nội địa Việt Nam
    CONSTRAINT CK_TOUR_country_vn CHECK (countryCode = N'VN'),

    -- Thời lượng 1–60 ngày
    CONSTRAINT CK_TOUR_duration CHECK (durationDays BETWEEN 1 AND 60),

    -- Trạng thái hợp lệ (thay ENUM)
    CONSTRAINT CK_TOUR_status CHECK ([status] IN ('DRAFT', 'ACTIVE', 'INACTIVE'))
);
GO

-- Index danh sách tour công khai
CREATE INDEX IX_TOUR_listing ON TOUR ([status], countryCode, deletedAt, createdAt, id);
GO

-- ----------------------------------------------------------
-- 1.4 LICH_KHOI_HANH (Schedule)
-- ----------------------------------------------------------
CREATE TABLE LICH_KHOI_HANH (
    id              UNIQUEIDENTIFIER    NOT NULL DEFAULT NEWID(),
    tourId          UNIQUEIDENTIFIER    NOT NULL,
    departureAt     DATETIME2(3)        NOT NULL,
    totalSeats      INT                 NOT NULL,
    reservedSeats   INT                 NOT NULL DEFAULT 0,
    adultPrice      BIGINT              NOT NULL,
    childPrice      BIGINT              NOT NULL,
    [status]        NVARCHAR(10)        NOT NULL DEFAULT 'OPEN',

    CONSTRAINT PK_LICH_KHOI_HANH PRIMARY KEY (id),

    -- FK: không cho xóa tour khi còn lịch
    CONSTRAINT FK_Schedule_Tour FOREIGN KEY (tourId)
        REFERENCES TOUR (id) ON DELETE NO ACTION ON UPDATE CASCADE,

    -- Kho chỗ hợp lệ
    CONSTRAINT CK_Schedule_seats CHECK (
        reservedSeats >= 0
        AND reservedSeats <= totalSeats
        AND totalSeats <= 10000
    ),

    -- Giá không âm, giới hạn VND
    CONSTRAINT CK_Schedule_adultPrice CHECK (adultPrice BETWEEN 0 AND 99999999),
    CONSTRAINT CK_Schedule_childPrice CHECK (childPrice BETWEEN 0 AND 99999999),

    -- Trạng thái hợp lệ (thay ENUM)
    CONSTRAINT CK_Schedule_status CHECK ([status] IN ('OPEN', 'CLOSED'))
);
GO

-- Index lịch theo tour và thời gian
CREATE INDEX IX_Schedule_Tour_Departure
    ON LICH_KHOI_HANH (tourId, [status], departureAt, id);
GO

-- ----------------------------------------------------------
-- 1.5 DON_DAT_TOUR (Booking)
-- ----------------------------------------------------------
CREATE TABLE DON_DAT_TOUR (
    id                  UNIQUEIDENTIFIER    NOT NULL DEFAULT NEWID(),
    userId              UNIQUEIDENTIFIER    NOT NULL,
    scheduleId          UNIQUEIDENTIFIER    NOT NULL,
    idempotencyKey      UNIQUEIDENTIFIER    NOT NULL,
    requestHash         NVARCHAR(MAX)       NOT NULL,
    [status]            NVARCHAR(20)        NOT NULL DEFAULT 'PENDING_PAYMENT',
    adults              INT                 NOT NULL,
    children            INT                 NOT NULL DEFAULT 0,
    totalAmount         BIGINT              NOT NULL,
    currency            NCHAR(3)            NOT NULL DEFAULT N'VND',
    tourTitle           NVARCHAR(MAX)       NOT NULL,
    contactName         NVARCHAR(200)       NOT NULL,
    contactEmail        NVARCHAR(254)       NOT NULL,
    contactPhone        NVARCHAR(20)        NOT NULL,
    expiresAt           DATETIME2(3)        NOT NULL,
    createdAt           DATETIME2(3)        NOT NULL DEFAULT SYSDATETIME(),
    paidAt              DATETIME2(3)        NULL,
    cancelledAt         DATETIME2(3)        NULL,
    cancelReason        NVARCHAR(MAX)       NULL,
    seatsReleasedAt     DATETIME2(3)        NULL,
    timeoutEnqueuedAt   DATETIME2(3)        NULL,

    CONSTRAINT PK_DON_DAT_TOUR PRIMARY KEY (id),

    -- FK: không cho xóa user/lịch khi còn đơn
    CONSTRAINT FK_Booking_User FOREIGN KEY (userId)
        REFERENCES NGUOI_DUNG (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT FK_Booking_Schedule FOREIGN KEY (scheduleId)
        REFERENCES LICH_KHOI_HANH (id) ON DELETE NO ACTION ON UPDATE NO ACTION,

    -- Chống tạo đơn trùng
    CONSTRAINT UQ_Booking_Idempotency UNIQUE (userId, idempotencyKey),

    -- Số người hợp lệ
    CONSTRAINT CK_Booking_adults CHECK (adults >= 1 AND adults <= 100),
    CONSTRAINT CK_Booking_children CHECK (children >= 0 AND children <= 100),

    -- Tiền hợp lệ
    CONSTRAINT CK_Booking_totalAmount CHECK (totalAmount BETWEEN 0 AND 9999999999),
    CONSTRAINT CK_Booking_currency CHECK (currency = N'VND'),

    -- Trạng thái hợp lệ (thay ENUM)
    CONSTRAINT CK_Booking_status CHECK ([status] IN (
        'PENDING_PAYMENT', 'PAID', 'CONFIRMED', 'COMPLETED', 'CANCELLED'
    )),

    -- Hold đúng 15 phút
    CONSTRAINT CK_Booking_expires CHECK (
        expiresAt = DATEADD(MINUTE, 15, createdAt)
    ),

    -- CANCELLED phải có đủ thông tin audit; ngược lại phải null
    CONSTRAINT CK_Booking_cancel_consistency CHECK (
        ([status] = 'CANCELLED' AND cancelledAt IS NOT NULL
            AND cancelReason IS NOT NULL AND seatsReleasedAt IS NOT NULL)
        OR
        ([status] <> 'CANCELLED' AND cancelledAt IS NULL
            AND cancelReason IS NULL AND seatsReleasedAt IS NULL)
    )
);
GO

-- Index phục vụ sweep timeout
CREATE INDEX IX_Booking_Sweep ON DON_DAT_TOUR ([status], expiresAt);
GO

-- Index reclaim/đếm theo lịch
CREATE INDEX IX_Booking_Schedule_Status ON DON_DAT_TOUR (scheduleId, [status]);
GO

-- Index lịch sử đơn của khách
CREATE INDEX IX_Booking_User_History ON DON_DAT_TOUR (userId, createdAt, id);
GO

-- Index danh sách admin
CREATE INDEX IX_Booking_Admin_List ON DON_DAT_TOUR (createdAt, id);
GO

-- ----------------------------------------------------------
-- 1.6 CHI_TIET_DAT_TOUR (BookingDetail)
-- ----------------------------------------------------------
CREATE TABLE CHI_TIET_DAT_TOUR (
    id              UNIQUEIDENTIFIER    NOT NULL DEFAULT NEWID(),
    bookingId       UNIQUEIDENTIFIER    NOT NULL,
    kind            NVARCHAR(10)        NOT NULL,
    quantity        INT                 NOT NULL,
    unitPrice       BIGINT              NOT NULL,
    lineTotal       BIGINT              NOT NULL,

    CONSTRAINT PK_CHI_TIET_DAT_TOUR PRIMARY KEY (id),

    -- FK: không cho xóa đơn khi còn chi tiết
    CONSTRAINT FK_Detail_Booking FOREIGN KEY (bookingId)
        REFERENCES DON_DAT_TOUR (id) ON DELETE NO ACTION ON UPDATE NO ACTION,

    -- Mỗi loại khách chỉ một dòng trên một đơn
    CONSTRAINT UQ_Detail_Booking_Kind UNIQUE (bookingId, kind),

    -- Loại khách hợp lệ (thay ENUM)
    CONSTRAINT CK_Detail_kind CHECK (kind IN ('ADULT', 'CHILD')),

    -- Số lượng > 0
    CONSTRAINT CK_Detail_quantity CHECK (quantity > 0),

    -- Đơn giá >= 0
    CONSTRAINT CK_Detail_unitPrice CHECK (unitPrice >= 0),

    -- lineTotal = quantity * unitPrice
    CONSTRAINT CK_Detail_lineTotal CHECK (lineTotal = quantity * unitPrice)
);
GO

-- ----------------------------------------------------------
-- 1.7 THANH_TOAN (Payment)
-- ----------------------------------------------------------
CREATE TABLE THANH_TOAN (
    id                  UNIQUEIDENTIFIER    NOT NULL DEFAULT NEWID(),
    bookingId           UNIQUEIDENTIFIER    NOT NULL,
    provider            NVARCHAR(10)        NOT NULL,
    providerReference   NVARCHAR(200)       NOT NULL,
    transactionId       NVARCHAR(200)       NULL,
    amount              BIGINT              NOT NULL,
    currency            NCHAR(3)            NOT NULL DEFAULT N'VND',
    [status]            NVARCHAR(20)        NOT NULL DEFAULT 'INITIATED',
    checkoutUrl         NVARCHAR(MAX)       NULL,
    createdAt           DATETIME2(3)        NOT NULL DEFAULT SYSDATETIME(),
    updatedAt           DATETIME2(3)        NOT NULL DEFAULT SYSDATETIME(),
    refundedAt          DATETIME2(3)        NULL,
    refundReference     NVARCHAR(200)       NULL,

    CONSTRAINT PK_THANH_TOAN PRIMARY KEY (id),

    -- Mỗi đơn tối đa một payment record
    CONSTRAINT UQ_Payment_Booking UNIQUE (bookingId),
    CONSTRAINT FK_Payment_Booking FOREIGN KEY (bookingId)
        REFERENCES DON_DAT_TOUR (id) ON DELETE NO ACTION ON UPDATE NO ACTION,

    -- Mã tham chiếu merchant duy nhất
    CONSTRAINT UQ_Payment_ProviderRef UNIQUE (providerReference),

    -- Cổng thanh toán hợp lệ (thay ENUM)
    CONSTRAINT CK_Payment_provider CHECK (provider IN ('VNPAY', 'MOMO', 'ZALOPAY')),

    -- Tiền hợp lệ
    CONSTRAINT CK_Payment_amount CHECK (amount BETWEEN 0 AND 9999999999),
    CONSTRAINT CK_Payment_currency CHECK (currency = N'VND'),

    -- Trạng thái hợp lệ (thay ENUM)
    CONSTRAINT CK_Payment_status CHECK ([status] IN (
        'INITIATED', 'SUCCEEDED', 'FAILED', 'REFUND_REQUIRED', 'REFUNDED'
    )),

    -- REFUNDED phải có refundedAt và refundReference
    CONSTRAINT CK_Payment_refund_consistency CHECK (
        ([status] = 'REFUNDED' AND refundedAt IS NOT NULL AND refundReference IS NOT NULL)
        OR
        ([status] <> 'REFUNDED' AND refundedAt IS NULL AND refundReference IS NULL)
    )
);
GO

-- Index refund queue
CREATE INDEX IX_Payment_Refund_Queue ON THANH_TOAN ([status], createdAt, id);
GO

-- Index danh sách admin
CREATE INDEX IX_Payment_Admin_List ON THANH_TOAN (createdAt, id);
GO

-- ----------------------------------------------------------
-- 1.8 AUDIT_LOG
-- ----------------------------------------------------------
CREATE TABLE AUDIT_LOG (
    id              UNIQUEIDENTIFIER    NOT NULL DEFAULT NEWID(),
    actorId         UNIQUEIDENTIFIER    NULL,
    [action]        NVARCHAR(100)       NOT NULL,
    entityId        NVARCHAR(200)       NOT NULL,
    metadata        NVARCHAR(MAX)       NOT NULL DEFAULT N'{}',
    createdAt       DATETIME2(3)        NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT PK_AUDIT_LOG PRIMARY KEY (id),

    -- FK mềm: xóa/disable user không mất lịch sử audit
    CONSTRAINT FK_Audit_Actor FOREIGN KEY (actorId)
        REFERENCES NGUOI_DUNG (id) ON DELETE SET NULL ON UPDATE NO ACTION
);
GO

-- Index lịch sử một thực thể
CREATE INDEX IX_Audit_Entity ON AUDIT_LOG (entityId, createdAt);
GO

-- Index màn hình audit toàn hệ thống
CREATE INDEX IX_Audit_Global ON AUDIT_LOG (createdAt, id);
GO


-- ============================================================
-- PHẦN 2: DỮ LIỆU DEMO (10 dòng mỗi bảng)
-- Chủ đề: Quảng bá và Đặt Tour Du lịch Nội địa Việt Nam
-- ============================================================

-- ----------------------------------------------------------
-- 2.1 NGUOI_DUNG – 10 người dùng
-- ----------------------------------------------------------
INSERT INTO NGUOI_DUNG (id, email, [name], passwordHash, [role], isActive, createdAt) VALUES
('A0000001-0000-0000-0000-000000000001', 'admin@tourvietnam.vn',       N'Nguyễn Văn Admin',    '$2b$12$hash_admin_placeholder',       'ADMIN',      1, '2026-01-01 00:00:00'),
('A0000001-0000-0000-0000-000000000002', 'ops.minh@tourvietnam.vn',    N'Trần Quốc Minh',      '$2b$12$hash_ops_minh_placeholder',    'OPERATIONS', 1, '2026-01-05 08:00:00'),
('A0000001-0000-0000-0000-000000000003', 'ops.hoa@tourvietnam.vn',     N'Lê Thị Hoa',          '$2b$12$hash_ops_hoa_placeholder',     'OPERATIONS', 1, '2026-01-05 08:30:00'),
('A0000001-0000-0000-0000-000000000004', 'khach.an@gmail.com',         N'Phạm Tuấn An',        '$2b$12$hash_khach_an_placeholder',    'CUSTOMER',   1, '2026-02-10 10:00:00'),
('A0000001-0000-0000-0000-000000000005', 'khach.linh@gmail.com',       N'Ngô Khánh Linh',      '$2b$12$hash_khach_linh_placeholder',  'CUSTOMER',   1, '2026-02-15 14:00:00'),
('A0000001-0000-0000-0000-000000000006', 'khach.duc@yahoo.com',        N'Hoàng Minh Đức',      '$2b$12$hash_khach_duc_placeholder',   'CUSTOMER',   1, '2026-03-01 09:00:00'),
('A0000001-0000-0000-0000-000000000007', 'khach.mai@outlook.com',      N'Vũ Thị Mai',          '$2b$12$hash_khach_mai_placeholder',   'CUSTOMER',   1, '2026-03-10 16:00:00'),
('A0000001-0000-0000-0000-000000000008', 'khach.hung@gmail.com',       N'Đặng Quốc Hùng',      '$2b$12$hash_khach_hung_placeholder',  'CUSTOMER',   1, '2026-04-01 07:00:00'),
('A0000001-0000-0000-0000-000000000009', 'khach.trang@gmail.com',      N'Bùi Thu Trang',        '$2b$12$hash_khach_trang_placeholder', 'CUSTOMER',   1, '2026-04-20 11:00:00'),
('A0000001-0000-0000-0000-000000000010', 'khach.huy@gmail.com',        N'Lý Gia Huy',          '$2b$12$hash_khach_huy_placeholder',   'CUSTOMER',   0, '2026-05-01 08:00:00');
GO

-- ----------------------------------------------------------
-- 2.2 RefreshSession – 10 phiên đăng nhập
-- ----------------------------------------------------------
INSERT INTO RefreshSession (id, userId, tokenHash, familyId, expiresAt, revokedAt, createdAt) VALUES
('B0000001-0000-0000-0000-000000000001', 'A0000001-0000-0000-0000-000000000001', 'hash_session_01', 'F0000001-0000-0000-0000-000000000001', '2026-01-08 00:00:00', NULL,                     '2026-01-01 00:00:00'),
('B0000001-0000-0000-0000-000000000002', 'A0000001-0000-0000-0000-000000000002', 'hash_session_02', 'F0000001-0000-0000-0000-000000000002', '2026-01-12 08:00:00', NULL,                     '2026-01-05 08:00:00'),
('B0000001-0000-0000-0000-000000000003', 'A0000001-0000-0000-0000-000000000003', 'hash_session_03', 'F0000001-0000-0000-0000-000000000003', '2026-01-12 08:30:00', '2026-01-10 10:00:00',    '2026-01-05 08:30:00'),
('B0000001-0000-0000-0000-000000000004', 'A0000001-0000-0000-0000-000000000004', 'hash_session_04', 'F0000001-0000-0000-0000-000000000004', '2026-02-17 10:00:00', NULL,                     '2026-02-10 10:00:00'),
('B0000001-0000-0000-0000-000000000005', 'A0000001-0000-0000-0000-000000000005', 'hash_session_05', 'F0000001-0000-0000-0000-000000000005', '2026-02-22 14:00:00', NULL,                     '2026-02-15 14:00:00'),
('B0000001-0000-0000-0000-000000000006', 'A0000001-0000-0000-0000-000000000006', 'hash_session_06', 'F0000001-0000-0000-0000-000000000006', '2026-03-08 09:00:00', NULL,                     '2026-03-01 09:00:00'),
('B0000001-0000-0000-0000-000000000007', 'A0000001-0000-0000-0000-000000000007', 'hash_session_07', 'F0000001-0000-0000-0000-000000000007', '2026-03-17 16:00:00', NULL,                     '2026-03-10 16:00:00'),
('B0000001-0000-0000-0000-000000000008', 'A0000001-0000-0000-0000-000000000008', 'hash_session_08', 'F0000001-0000-0000-0000-000000000008', '2026-04-08 07:00:00', '2026-04-05 12:00:00',    '2026-04-01 07:00:00'),
('B0000001-0000-0000-0000-000000000009', 'A0000001-0000-0000-0000-000000000009', 'hash_session_09', 'F0000001-0000-0000-0000-000000000009', '2026-04-27 11:00:00', NULL,                     '2026-04-20 11:00:00'),
('B0000001-0000-0000-0000-000000000010', 'A0000001-0000-0000-0000-000000000004', 'hash_session_10', 'F0000001-0000-0000-0000-000000000004', '2026-06-01 10:00:00', NULL,                     '2026-05-25 10:00:00');
GO

-- ----------------------------------------------------------
-- 2.3 TOUR – 10 tour du lịch nội địa Việt Nam
-- ----------------------------------------------------------
INSERT INTO TOUR (id, slug, title, [description], destination, countryCode, durationDays, [status], deletedAt, createdAt, updatedAt) VALUES
('C0000001-0000-0000-0000-000000000001', 'ha-long-bay-3-ngay',        N'Vịnh Hạ Long 3 Ngày 2 Đêm',          N'Khám phá kỳ quan thiên nhiên thế giới Vịnh Hạ Long. Tham quan hang Sửng Sốt, đảo Ti Tốp, chèo kayak và nghỉ đêm trên du thuyền 5 sao.',                                     N'Quảng Ninh',      'VN', 3,  'ACTIVE',   NULL, '2026-01-10 08:00:00', '2026-01-10 08:00:00'),
('C0000001-0000-0000-0000-000000000002', 'sapa-trekking-4-ngay',      N'Sapa Trekking 4 Ngày 3 Đêm',         N'Trekking qua các bản làng Tả Van, Tả Phìn. Ngắm ruộng bậc thang Mường Hoa, chinh phục đỉnh Fansipan bằng cáp treo và trải nghiệm homestay.',                                N'Lào Cai',         'VN', 4,  'ACTIVE',   NULL, '2026-01-15 09:00:00', '2026-01-15 09:00:00'),
('C0000001-0000-0000-0000-000000000003', 'da-nang-hoi-an-5-ngay',     N'Đà Nẵng – Hội An 5 Ngày 4 Đêm',     N'Tham quan Bà Nà Hills, cầu Vàng, bãi biển Mỹ Khê. Dạo phố cổ Hội An, thả đèn hoa đăng trên sông Hoài và thưởng thức ẩm thực miền Trung.',                                  N'Đà Nẵng',         'VN', 5,  'ACTIVE',   NULL, '2026-02-01 10:00:00', '2026-02-01 10:00:00'),
('C0000001-0000-0000-0000-000000000004', 'phu-quoc-resort-4-ngay',    N'Phú Quốc Resort 4 Ngày 3 Đêm',      N'Nghỉ dưỡng tại resort 5 sao Phú Quốc. Lặn ngắm san hô, tham quan vườn tiêu, nhà thùng nước mắm và ngắm hoàng hôn tại Sunset Town.',                                       N'Kiên Giang',      'VN', 4,  'ACTIVE',   NULL, '2026-02-10 11:00:00', '2026-02-10 11:00:00'),
('C0000001-0000-0000-0000-000000000005', 'dalat-langbiang-3-ngay',    N'Đà Lạt – Langbiang 3 Ngày 2 Đêm',   N'Chinh phục đỉnh Langbiang, tham quan Thung lũng Tình Yêu, hồ Tuyền Lâm. Thưởng thức cà phê chồn và dạo chợ đêm Đà Lạt.',                                                   N'Lâm Đồng',        'VN', 3,  'ACTIVE',   NULL, '2026-02-20 08:00:00', '2026-02-20 08:00:00'),
('C0000001-0000-0000-0000-000000000006', 'ninh-binh-trang-an-2-ngay', N'Ninh Bình – Tràng An 2 Ngày 1 Đêm', N'Chèo thuyền qua quần thể danh thắng Tràng An, tham quan cố đô Hoa Lư và chùa Bái Đính – ngôi chùa lớn nhất Đông Nam Á.',                                                   N'Ninh Bình',       'VN', 2,  'ACTIVE',   NULL, '2026-03-01 09:00:00', '2026-03-01 09:00:00'),
('C0000001-0000-0000-0000-000000000007', 'quy-nhon-phu-yen-5-ngay',   N'Quy Nhơn – Phú Yên 5 Ngày 4 Đêm',  N'Khám phá Eo Gió, Kỳ Co, Hòn Khô tại Quy Nhơn. Ghé thăm gành Đá Đĩa, bãi Xép và mũi Điện – điểm đón bình minh sớm nhất Việt Nam.',                                        N'Bình Định',       'VN', 5,  'ACTIVE',   NULL, '2026-03-15 10:00:00', '2026-03-15 10:00:00'),
('C0000001-0000-0000-0000-000000000008', 'ha-giang-loop-4-ngay',      N'Hà Giang Loop 4 Ngày 3 Đêm',        N'Hành trình cung đường Hà Giang huyền thoại qua đèo Mã Pí Lèng, sông Nho Quế, cao nguyên đá Đồng Văn và cột cờ Lũng Cú.',                                                  N'Hà Giang',        'VN', 4,  'DRAFT',    NULL, '2026-04-01 08:00:00', '2026-04-01 08:00:00'),
('C0000001-0000-0000-0000-000000000009', 'con-dao-4-ngay',            N'Côn Đảo Huyền Thoại 4 Ngày 3 Đêm',  N'Tham quan nhà tù Côn Đảo, nghĩa trang Hàng Dương. Lặn biển ngắm rùa biển, tắm biển Đầm Trầu và khám phá rừng nguyên sinh.',                                                N'Bà Rịa-Vũng Tàu','VN', 4,  'INACTIVE', NULL, '2026-04-15 09:00:00', '2026-06-01 10:00:00'),
('C0000001-0000-0000-0000-000000000010', 'mekong-delta-3-ngay',       N'Miền Tây Sông Nước 3 Ngày 2 Đêm',   N'Trải nghiệm chợ nổi Cái Răng, vườn trái cây Vĩnh Long, làng nghề bánh tráng. Đi xuồng ba lá trên kênh rạch và thưởng thức đờn ca tài tử.',                                 N'Cần Thơ',         'VN', 3,  'ACTIVE',   NULL, '2026-05-01 07:00:00', '2026-05-01 07:00:00');
GO

-- ----------------------------------------------------------
-- 2.4 LICH_KHOI_HANH – 10 lịch khởi hành
-- ----------------------------------------------------------
INSERT INTO LICH_KHOI_HANH (id, tourId, departureAt, totalSeats, reservedSeats, adultPrice, childPrice, [status]) VALUES
('D0000001-0000-0000-0000-000000000001', 'C0000001-0000-0000-0000-000000000001', '2026-10-15 06:00:00', 30, 5,  4500000, 3200000, 'OPEN'),
('D0000001-0000-0000-0000-000000000002', 'C0000001-0000-0000-0000-000000000001', '2026-11-01 06:00:00', 30, 0,  4500000, 3200000, 'OPEN'),
('D0000001-0000-0000-0000-000000000003', 'C0000001-0000-0000-0000-000000000002', '2026-10-20 05:00:00', 20, 8,  5200000, 3800000, 'OPEN'),
('D0000001-0000-0000-0000-000000000004', 'C0000001-0000-0000-0000-000000000003', '2026-10-25 07:00:00', 40, 12, 6800000, 4500000, 'OPEN'),
('D0000001-0000-0000-0000-000000000005', 'C0000001-0000-0000-0000-000000000004', '2026-11-10 08:00:00', 25, 3,  7500000, 5000000, 'OPEN'),
('D0000001-0000-0000-0000-000000000006', 'C0000001-0000-0000-0000-000000000005', '2026-10-18 06:30:00', 35, 15, 3800000, 2500000, 'OPEN'),
('D0000001-0000-0000-0000-000000000007', 'C0000001-0000-0000-0000-000000000006', '2026-10-12 05:30:00', 45, 20, 2500000, 1800000, 'OPEN'),
('D0000001-0000-0000-0000-000000000008', 'C0000001-0000-0000-0000-000000000007', '2026-11-05 06:00:00', 30, 10, 8500000, 6000000, 'OPEN'),
('D0000001-0000-0000-0000-000000000009', 'C0000001-0000-0000-0000-000000000010', '2026-10-28 07:00:00', 35, 7,  3200000, 2200000, 'OPEN'),
('D0000001-0000-0000-0000-000000000010', 'C0000001-0000-0000-0000-000000000001', '2026-09-01 06:00:00', 30, 30, 4200000, 3000000, 'CLOSED');
GO

-- ----------------------------------------------------------
-- 2.5 DON_DAT_TOUR – 10 đơn đặt tour
-- expiresAt = DATEADD(MINUTE, 15, createdAt) (ràng buộc CHECK)
-- ----------------------------------------------------------

-- Đơn 1: PAID – Phạm Tuấn An đặt Hạ Long
INSERT INTO DON_DAT_TOUR (id, userId, scheduleId, idempotencyKey, requestHash, [status], adults, children, totalAmount, currency, tourTitle, contactName, contactEmail, contactPhone, expiresAt, createdAt, paidAt, cancelledAt, cancelReason, seatsReleasedAt) VALUES
('E0000001-0000-0000-0000-000000000001', 'A0000001-0000-0000-0000-000000000004', 'D0000001-0000-0000-0000-000000000001', 'E1111111-0000-0000-0000-000000000001', 'reqhash01', 'PAID',
 2, 1, 12200000, N'VND', N'Vịnh Hạ Long 3 Ngày 2 Đêm',
 N'Phạm Tuấn An', 'khach.an@gmail.com', '0901234567',
 '2026-09-20 10:15:00', '2026-09-20 10:00:00', '2026-09-20 10:10:00',
 NULL, NULL, NULL);
GO

-- Đơn 2: CONFIRMED – Ngô Khánh Linh đặt Sapa
INSERT INTO DON_DAT_TOUR (id, userId, scheduleId, idempotencyKey, requestHash, [status], adults, children, totalAmount, currency, tourTitle, contactName, contactEmail, contactPhone, expiresAt, createdAt, paidAt, cancelledAt, cancelReason, seatsReleasedAt) VALUES
('E0000001-0000-0000-0000-000000000002', 'A0000001-0000-0000-0000-000000000005', 'D0000001-0000-0000-0000-000000000003', 'E1111111-0000-0000-0000-000000000002', 'reqhash02', 'CONFIRMED',
 3, 2, 23200000, N'VND', N'Sapa Trekking 4 Ngày 3 Đêm',
 N'Ngô Khánh Linh', 'khach.linh@gmail.com', '0912345678',
 '2026-09-21 14:15:00', '2026-09-21 14:00:00', '2026-09-21 14:05:00',
 NULL, NULL, NULL);
GO

-- Đơn 3: COMPLETED – Hoàng Minh Đức đặt Đà Nẵng
INSERT INTO DON_DAT_TOUR (id, userId, scheduleId, idempotencyKey, requestHash, [status], adults, children, totalAmount, currency, tourTitle, contactName, contactEmail, contactPhone, expiresAt, createdAt, paidAt, cancelledAt, cancelReason, seatsReleasedAt) VALUES
('E0000001-0000-0000-0000-000000000003', 'A0000001-0000-0000-0000-000000000006', 'D0000001-0000-0000-0000-000000000004', 'E1111111-0000-0000-0000-000000000003', 'reqhash03', 'COMPLETED',
 2, 0, 13600000, N'VND', N'Đà Nẵng – Hội An 5 Ngày 4 Đêm',
 N'Hoàng Minh Đức', 'khach.duc@yahoo.com', '0923456789',
 '2026-08-01 09:15:00', '2026-08-01 09:00:00', '2026-08-01 09:08:00',
 NULL, NULL, NULL);
GO

-- Đơn 4: CANCELLED – Vũ Thị Mai hủy đặt Phú Quốc
INSERT INTO DON_DAT_TOUR (id, userId, scheduleId, idempotencyKey, requestHash, [status], adults, children, totalAmount, currency, tourTitle, contactName, contactEmail, contactPhone, expiresAt, createdAt, paidAt, cancelledAt, cancelReason, seatsReleasedAt) VALUES
('E0000001-0000-0000-0000-000000000004', 'A0000001-0000-0000-0000-000000000007', 'D0000001-0000-0000-0000-000000000005', 'E1111111-0000-0000-0000-000000000004', 'reqhash04', 'CANCELLED',
 2, 1, 20000000, N'VND', N'Phú Quốc Resort 4 Ngày 3 Đêm',
 N'Vũ Thị Mai', 'khach.mai@outlook.com', '0934567890',
 '2026-09-10 16:15:00', '2026-09-10 16:00:00', NULL,
 '2026-09-10 17:00:00', N'Khách hủy vì thay đổi kế hoạch cá nhân', '2026-09-10 17:00:00');
GO

-- Đơn 5: PENDING_PAYMENT – Đặng Quốc Hùng chờ thanh toán Đà Lạt
INSERT INTO DON_DAT_TOUR (id, userId, scheduleId, idempotencyKey, requestHash, [status], adults, children, totalAmount, currency, tourTitle, contactName, contactEmail, contactPhone, expiresAt, createdAt, paidAt, cancelledAt, cancelReason, seatsReleasedAt) VALUES
('E0000001-0000-0000-0000-000000000005', 'A0000001-0000-0000-0000-000000000008', 'D0000001-0000-0000-0000-000000000006', 'E1111111-0000-0000-0000-000000000005', 'reqhash05', 'PENDING_PAYMENT',
 1, 0, 3800000, N'VND', N'Đà Lạt – Langbiang 3 Ngày 2 Đêm',
 N'Đặng Quốc Hùng', 'khach.hung@gmail.com', '0945678901',
 '2026-09-23 11:15:00', '2026-09-23 11:00:00', NULL,
 NULL, NULL, NULL);
GO

-- Đơn 6: PAID – Bùi Thu Trang đặt Ninh Bình
INSERT INTO DON_DAT_TOUR (id, userId, scheduleId, idempotencyKey, requestHash, [status], adults, children, totalAmount, currency, tourTitle, contactName, contactEmail, contactPhone, expiresAt, createdAt, paidAt, cancelledAt, cancelReason, seatsReleasedAt) VALUES
('E0000001-0000-0000-0000-000000000006', 'A0000001-0000-0000-0000-000000000009', 'D0000001-0000-0000-0000-000000000007', 'E1111111-0000-0000-0000-000000000006', 'reqhash06', 'PAID',
 4, 2, 13600000, N'VND', N'Ninh Bình – Tràng An 2 Ngày 1 Đêm',
 N'Bùi Thu Trang', 'khach.trang@gmail.com', '0956789012',
 '2026-09-22 08:15:00', '2026-09-22 08:00:00', '2026-09-22 08:12:00',
 NULL, NULL, NULL);
GO

-- Đơn 7: CONFIRMED – Phạm Tuấn An đặt Quy Nhơn
INSERT INTO DON_DAT_TOUR (id, userId, scheduleId, idempotencyKey, requestHash, [status], adults, children, totalAmount, currency, tourTitle, contactName, contactEmail, contactPhone, expiresAt, createdAt, paidAt, cancelledAt, cancelReason, seatsReleasedAt) VALUES
('E0000001-0000-0000-0000-000000000007', 'A0000001-0000-0000-0000-000000000004', 'D0000001-0000-0000-0000-000000000008', 'E1111111-0000-0000-0000-000000000007', 'reqhash07', 'CONFIRMED',
 2, 1, 23000000, N'VND', N'Quy Nhơn – Phú Yên 5 Ngày 4 Đêm',
 N'Phạm Tuấn An', 'khach.an@gmail.com', '0901234567',
 '2026-09-18 15:15:00', '2026-09-18 15:00:00', '2026-09-18 15:07:00',
 NULL, NULL, NULL);
GO

-- Đơn 8: PAID – Ngô Khánh Linh đặt Miền Tây
INSERT INTO DON_DAT_TOUR (id, userId, scheduleId, idempotencyKey, requestHash, [status], adults, children, totalAmount, currency, tourTitle, contactName, contactEmail, contactPhone, expiresAt, createdAt, paidAt, cancelledAt, cancelReason, seatsReleasedAt) VALUES
('E0000001-0000-0000-0000-000000000008', 'A0000001-0000-0000-0000-000000000005', 'D0000001-0000-0000-0000-000000000009', 'E1111111-0000-0000-0000-000000000008', 'reqhash08', 'PAID',
 2, 2, 10800000, N'VND', N'Miền Tây Sông Nước 3 Ngày 2 Đêm',
 N'Ngô Khánh Linh', 'khach.linh@gmail.com', '0912345678',
 '2026-09-19 09:15:00', '2026-09-19 09:00:00', '2026-09-19 09:11:00',
 NULL, NULL, NULL);
GO

-- Đơn 9: COMPLETED – Hoàng Minh Đức đặt Hạ Long (tour cũ đã xong)
INSERT INTO DON_DAT_TOUR (id, userId, scheduleId, idempotencyKey, requestHash, [status], adults, children, totalAmount, currency, tourTitle, contactName, contactEmail, contactPhone, expiresAt, createdAt, paidAt, cancelledAt, cancelReason, seatsReleasedAt) VALUES
('E0000001-0000-0000-0000-000000000009', 'A0000001-0000-0000-0000-000000000006', 'D0000001-0000-0000-0000-000000000010', 'E1111111-0000-0000-0000-000000000009', 'reqhash09', 'COMPLETED',
 1, 0, 4200000, N'VND', N'Vịnh Hạ Long 3 Ngày 2 Đêm',
 N'Hoàng Minh Đức', 'khach.duc@yahoo.com', '0923456789',
 '2026-08-15 07:15:00', '2026-08-15 07:00:00', '2026-08-15 07:09:00',
 NULL, NULL, NULL);
GO

-- Đơn 10: CANCELLED – Lý Gia Huy hủy đặt Hạ Long
INSERT INTO DON_DAT_TOUR (id, userId, scheduleId, idempotencyKey, requestHash, [status], adults, children, totalAmount, currency, tourTitle, contactName, contactEmail, contactPhone, expiresAt, createdAt, paidAt, cancelledAt, cancelReason, seatsReleasedAt) VALUES
('E0000001-0000-0000-0000-000000000010', 'A0000001-0000-0000-0000-000000000010', 'D0000001-0000-0000-0000-000000000002', 'E1111111-0000-0000-0000-000000000010', 'reqhash10', 'CANCELLED',
 1, 1, 7700000, N'VND', N'Vịnh Hạ Long 3 Ngày 2 Đêm',
 N'Lý Gia Huy', 'khach.huy@gmail.com', '0967890123',
 '2026-09-15 10:15:00', '2026-09-15 10:00:00', NULL,
 '2026-09-15 11:00:00', N'Hệ thống tự động hủy – tài khoản bị vô hiệu hóa', '2026-09-15 11:00:00');
GO

-- ----------------------------------------------------------
-- 2.6 CHI_TIET_DAT_TOUR – 10 chi tiết (ADULT + CHILD)
-- lineTotal = quantity * unitPrice
-- ----------------------------------------------------------
INSERT INTO CHI_TIET_DAT_TOUR (id, bookingId, kind, quantity, unitPrice, lineTotal) VALUES
-- Đơn 1: 2 adult + 1 child = 9,000,000 + 3,200,000 = 12,200,000
('G0000001-0000-0000-0000-000000000001', 'E0000001-0000-0000-0000-000000000001', 'ADULT', 2, 4500000, 9000000),
('G0000001-0000-0000-0000-000000000002', 'E0000001-0000-0000-0000-000000000001', 'CHILD', 1, 3200000, 3200000),

-- Đơn 2: 3 adult + 2 child = 15,600,000 + 7,600,000 = 23,200,000
('G0000001-0000-0000-0000-000000000003', 'E0000001-0000-0000-0000-000000000002', 'ADULT', 3, 5200000, 15600000),
('G0000001-0000-0000-0000-000000000004', 'E0000001-0000-0000-0000-000000000002', 'CHILD', 2, 3800000, 7600000),

-- Đơn 3: 2 adult = 13,600,000
('G0000001-0000-0000-0000-000000000005', 'E0000001-0000-0000-0000-000000000003', 'ADULT', 2, 6800000, 13600000),

-- Đơn 5: 1 adult = 3,800,000
('G0000001-0000-0000-0000-000000000006', 'E0000001-0000-0000-0000-000000000005', 'ADULT', 1, 3800000, 3800000),

-- Đơn 6: 4 adult + 2 child = 10,000,000 + 3,600,000 = 13,600,000
('G0000001-0000-0000-0000-000000000007', 'E0000001-0000-0000-0000-000000000006', 'ADULT', 4, 2500000, 10000000),
('G0000001-0000-0000-0000-000000000008', 'E0000001-0000-0000-0000-000000000006', 'CHILD', 2, 1800000, 3600000),

-- Đơn 8: 2 adult + 2 child = 6,400,000 + 4,400,000 = 10,800,000
('G0000001-0000-0000-0000-000000000009', 'E0000001-0000-0000-0000-000000000008', 'ADULT', 2, 3200000, 6400000),
('G0000001-0000-0000-0000-000000000010', 'E0000001-0000-0000-0000-000000000008', 'CHILD', 2, 2200000, 4400000);
GO

-- ----------------------------------------------------------
-- 2.7 THANH_TOAN – 10 giao dịch thanh toán
-- ----------------------------------------------------------
INSERT INTO THANH_TOAN (id, bookingId, provider, providerReference, transactionId, amount, currency, [status], checkoutUrl, createdAt, updatedAt, refundedAt, refundReference) VALUES
-- Thanh toán đơn 1: SUCCEEDED via VNPAY
('H0000001-0000-0000-0000-000000000001', 'E0000001-0000-0000-0000-000000000001', 'VNPAY',   'VNPAY-REF-001', 'TXN-VNPAY-001', 12200000, N'VND', 'SUCCEEDED',
 'https://sandbox.vnpayment.vn/checkout/001', '2026-09-20 10:05:00', '2026-09-20 10:10:00', NULL, NULL),

-- Thanh toán đơn 2: SUCCEEDED via MOMO
('H0000001-0000-0000-0000-000000000002', 'E0000001-0000-0000-0000-000000000002', 'MOMO',    'MOMO-REF-002',  'TXN-MOMO-002',  23200000, N'VND', 'SUCCEEDED',
 'https://test-payment.momo.vn/checkout/002', '2026-09-21 14:02:00', '2026-09-21 14:05:00', NULL, NULL),

-- Thanh toán đơn 3: SUCCEEDED via ZALOPAY
('H0000001-0000-0000-0000-000000000003', 'E0000001-0000-0000-0000-000000000003', 'ZALOPAY', 'ZALO-REF-003',  'TXN-ZALO-003',  13600000, N'VND', 'SUCCEEDED',
 'https://sandbox.zalopay.vn/checkout/003', '2026-08-01 09:03:00', '2026-08-01 09:08:00', NULL, NULL),

-- Thanh toán đơn 4: REFUNDED (đơn đã hủy)
('H0000001-0000-0000-0000-000000000004', 'E0000001-0000-0000-0000-000000000004', 'VNPAY',   'VNPAY-REF-004', 'TXN-VNPAY-004', 20000000, N'VND', 'REFUNDED',
 'https://sandbox.vnpayment.vn/checkout/004', '2026-09-10 16:02:00', '2026-09-10 18:00:00', '2026-09-10 18:00:00', 'REFUND-VNPAY-004'),

-- Thanh toán đơn 5: INITIATED (chờ khách thanh toán)
('H0000001-0000-0000-0000-000000000005', 'E0000001-0000-0000-0000-000000000005', 'MOMO',    'MOMO-REF-005',  NULL,             3800000,  N'VND', 'INITIATED',
 'https://test-payment.momo.vn/checkout/005', '2026-09-23 11:02:00', '2026-09-23 11:02:00', NULL, NULL),

-- Thanh toán đơn 6: SUCCEEDED via VNPAY
('H0000001-0000-0000-0000-000000000006', 'E0000001-0000-0000-0000-000000000006', 'VNPAY',   'VNPAY-REF-006', 'TXN-VNPAY-006', 13600000, N'VND', 'SUCCEEDED',
 'https://sandbox.vnpayment.vn/checkout/006', '2026-09-22 08:03:00', '2026-09-22 08:12:00', NULL, NULL),

-- Thanh toán đơn 7: SUCCEEDED via ZALOPAY
('H0000001-0000-0000-0000-000000000007', 'E0000001-0000-0000-0000-000000000007', 'ZALOPAY', 'ZALO-REF-007',  'TXN-ZALO-007',  23000000, N'VND', 'SUCCEEDED',
 'https://sandbox.zalopay.vn/checkout/007', '2026-09-18 15:03:00', '2026-09-18 15:07:00', NULL, NULL),

-- Thanh toán đơn 8: SUCCEEDED via MOMO
('H0000001-0000-0000-0000-000000000008', 'E0000001-0000-0000-0000-000000000008', 'MOMO',    'MOMO-REF-008',  'TXN-MOMO-008',  10800000, N'VND', 'SUCCEEDED',
 'https://test-payment.momo.vn/checkout/008', '2026-09-19 09:03:00', '2026-09-19 09:11:00', NULL, NULL),

-- Thanh toán đơn 9: SUCCEEDED via VNPAY
('H0000001-0000-0000-0000-000000000009', 'E0000001-0000-0000-0000-000000000009', 'VNPAY',   'VNPAY-REF-009', 'TXN-VNPAY-009', 4200000,  N'VND', 'SUCCEEDED',
 'https://sandbox.vnpayment.vn/checkout/009', '2026-08-15 07:03:00', '2026-08-15 07:09:00', NULL, NULL),

-- Thanh toán đơn 10: REFUNDED (đơn đã hủy)
('H0000001-0000-0000-0000-000000000010', 'E0000001-0000-0000-0000-000000000010', 'ZALOPAY', 'ZALO-REF-010',  'TXN-ZALO-010',  7700000,  N'VND', 'REFUNDED',
 'https://sandbox.zalopay.vn/checkout/010', '2026-09-15 10:03:00', '2026-09-15 12:00:00', '2026-09-15 12:00:00', 'REFUND-ZALO-010');
GO

-- ----------------------------------------------------------
-- 2.8 AUDIT_LOG – 10 bản ghi nhật ký
-- ----------------------------------------------------------
INSERT INTO AUDIT_LOG (id, actorId, [action], entityId, metadata, createdAt) VALUES
('I0000001-0000-0000-0000-000000000001', 'A0000001-0000-0000-0000-000000000001', 'TOUR_CREATED',        'C0000001-0000-0000-0000-000000000001', N'{"title": "Vịnh Hạ Long 3 Ngày 2 Đêm"}',                             '2026-01-10 08:00:00'),
('I0000001-0000-0000-0000-000000000002', 'A0000001-0000-0000-0000-000000000001', 'TOUR_ACTIVATED',      'C0000001-0000-0000-0000-000000000003', N'{"title": "Đà Nẵng – Hội An 5 Ngày 4 Đêm", "oldStatus": "DRAFT"}',   '2026-02-01 10:30:00'),
('I0000001-0000-0000-0000-000000000003', 'A0000001-0000-0000-0000-000000000002', 'SCHEDULE_CREATED',    'D0000001-0000-0000-0000-000000000001', N'{"tourId": "C0000001-0000-0000-0000-000000000001", "seats": 30}',      '2026-06-01 09:00:00'),
('I0000001-0000-0000-0000-000000000004', 'A0000001-0000-0000-0000-000000000004', 'BOOKING_CREATED',     'E0000001-0000-0000-0000-000000000001', N'{"scheduleId": "D0000001-0000-0000-0000-000000000001", "total": 12200000}', '2026-09-20 10:00:00'),
('I0000001-0000-0000-0000-000000000005', NULL,                                   'PAYMENT_SUCCEEDED',   'H0000001-0000-0000-0000-000000000001', N'{"provider": "VNPAY", "amount": 12200000}',                           '2026-09-20 10:10:00'),
('I0000001-0000-0000-0000-000000000006', 'A0000001-0000-0000-0000-000000000007', 'BOOKING_CANCELLED',   'E0000001-0000-0000-0000-000000000004', N'{"reason": "Thay đổi kế hoạch cá nhân"}',                             '2026-09-10 17:00:00'),
('I0000001-0000-0000-0000-000000000007', 'A0000001-0000-0000-0000-000000000001', 'PAYMENT_REFUNDED',    'H0000001-0000-0000-0000-000000000004', N'{"refundRef": "REFUND-VNPAY-004", "amount": 20000000}',               '2026-09-10 18:00:00'),
('I0000001-0000-0000-0000-000000000008', 'A0000001-0000-0000-0000-000000000001', 'USER_DEACTIVATED',    'A0000001-0000-0000-0000-000000000010', N'{"email": "khach.huy@gmail.com", "reason": "Vi phạm điều khoản"}',     '2026-09-15 10:30:00'),
('I0000001-0000-0000-0000-000000000009', 'A0000001-0000-0000-0000-000000000002', 'SCHEDULE_CLOSED',     'D0000001-0000-0000-0000-000000000010', N'{"tourId": "C0000001-0000-0000-0000-000000000001", "reason": "Hết chỗ"}', '2026-08-30 15:00:00'),
('I0000001-0000-0000-0000-000000000010', 'A0000001-0000-0000-0000-000000000003', 'TOUR_STATUS_CHANGED', 'C0000001-0000-0000-0000-000000000009', N'{"title": "Côn Đảo Huyền Thoại", "oldStatus": "ACTIVE", "newStatus": "INACTIVE"}', '2026-06-01 10:00:00');
GO


-- ============================================================
-- PHẦN 3: KIỂM TRA NHANH
-- ============================================================

-- Đếm số dòng mỗi bảng
SELECT N'NGUOI_DUNG'        AS [Bảng], COUNT(*) AS [Số dòng] FROM NGUOI_DUNG
UNION ALL
SELECT N'RefreshSession',              COUNT(*)               FROM RefreshSession
UNION ALL
SELECT N'TOUR',                        COUNT(*)               FROM TOUR
UNION ALL
SELECT N'LICH_KHOI_HANH',              COUNT(*)               FROM LICH_KHOI_HANH
UNION ALL
SELECT N'DON_DAT_TOUR',                COUNT(*)               FROM DON_DAT_TOUR
UNION ALL
SELECT N'CHI_TIET_DAT_TOUR',           COUNT(*)               FROM CHI_TIET_DAT_TOUR
UNION ALL
SELECT N'THANH_TOAN',                  COUNT(*)               FROM THANH_TOAN
UNION ALL
SELECT N'AUDIT_LOG',                   COUNT(*)               FROM AUDIT_LOG;
GO

-- Hiển thị danh sách bảng trong database
SELECT TABLE_NAME AS [Tên bảng], TABLE_TYPE AS [Loại]
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'dbo'
ORDER BY TABLE_NAME;
GO
