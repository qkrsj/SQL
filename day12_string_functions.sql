-- Day 12: 문자열 함수
-- 목표: 문자열을 다루는 대표 함수(LENGTH, UPPER/LOWER, SUBSTR, TRIM, REPLACE, || 연결)를 익힌다.

-- 개념 설명
-- LENGTH(s)              : 문자열 길이를 반환한다.
-- UPPER(s) / LOWER(s)    : 대문자 / 소문자로 바꾼다.
-- SUBSTR(s, 시작, 길이)  : 시작 위치(1부터)에서 길이만큼 잘라 낸다. 길이를 생략하면 끝까지.
-- TRIM(s)                : 양쪽 공백을 제거한다.
-- REPLACE(s, 찾을, 바꿀) : 문자열 안의 특정 부분을 다른 문자열로 바꾼다.
-- 문자열 연결            : SQLite는 'a' || 'b', MySQL은 CONCAT('a', 'b')를 쓴다. (DB마다 다름)
-- INSTR(s, 찾을)         : 찾을 문자열이 처음 나오는 위치(1부터)를 반환한다. 없으면 0.

DROP TABLE IF EXISTS members;

CREATE TABLE members (
    id    INTEGER PRIMARY KEY,
    name  VARCHAR(30) NOT NULL,
    email VARCHAR(50) NOT NULL,
    phone VARCHAR(20)
);

INSERT INTO members (id, name, email, phone) VALUES
    (1, '김하늘', 'Haneul.Kim@Example.com',  '010-1234-5678'),
    (2, '이바다', '  bada@example.com ',      '010-2222-3333'),
    (3, '박나무', 'namu.park@sample.org',     '010-9876-5432'),
    (4, '최구름', 'GOORUM@EXAMPLE.COM',       NULL);

-- 1) LENGTH: 이름과 이메일 길이
SELECT name, LENGTH(name) AS name_len, LENGTH(email) AS email_len
FROM members;

-- 2) UPPER / LOWER: 대소문자 통일 (이메일 비교 시 유용)
SELECT id, LOWER(email) AS email_lower, UPPER(name) AS name_upper
FROM members;

-- 3) TRIM: 양쪽 공백 제거 (2번 회원 이메일 앞뒤 공백 확인)
SELECT id, LENGTH(email) AS before_len, LENGTH(TRIM(email)) AS after_len
FROM members;

-- 4) SUBSTR: 앞 3글자, 전화번호 앞자리 등 일부만 추출
SELECT name,
       SUBSTR(name, 1, 1)  AS family_name,  -- 성(첫 글자)
       SUBSTR(phone, 1, 3) AS phone_prefix  -- 010
FROM members;

-- 5) REPLACE: 하이픈 제거 / 도메인 변경
SELECT name,
       REPLACE(phone, '-', '') AS phone_digits,
       REPLACE(LOWER(TRIM(email)), 'example.com', 'company.com') AS new_email
FROM members;

-- 6) 문자열 연결 (SQLite 방식 ||). MySQL에서는 CONCAT(name, '님')을 사용한다.
SELECT name || '님' AS greeting FROM members;

-- 7) 함수 조합 + WHERE: 공백/대소문자를 정리한 뒤 조건 비교
SELECT id, name
FROM members
WHERE LOWER(TRIM(email)) LIKE '%@example.com';

-- 8) NULL 주의: phone이 NULL이면 함수 결과도 NULL, COALESCE로 기본값 지정
SELECT name, COALESCE(REPLACE(phone, '-', ''), '번호 없음') AS phone_digits
FROM members;

-- 연습 문제
-- 문제 1) 이메일을 TRIM과 LOWER로 정리한 뒤, '@' 앞부분이 8글자 이상인 회원을 찾아 보세요.
--        (힌트: INSTR(email, '@') 로 '@' 위치를 구하고 SUBSTR로 잘라 LENGTH로 길이를 잰다)
-- 문제 2) 이름과 전화번호 뒤 4자리를 합쳐 '김하늘(5678)' 형태로 출력해 보세요.
--        (힌트: SUBSTR에 음수 시작 위치를 쓰거나, LENGTH로 위치를 계산한다. SQLite는 SUBSTR(phone, -4))
