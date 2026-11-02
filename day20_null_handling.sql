-- Day 20: NULL 처리 (IS NULL, COALESCE, NULLIF)
-- 목표: NULL 의 특성을 이해하고 IS NULL, COALESCE, NULLIF 로 안전하게 다루는 방법을 익힌다.

-- 개념 설명
-- NULL 은 "값이 없음(알 수 없음)"을 뜻하며 0 이나 빈 문자열('')과는 다르다.
-- 규칙 1) NULL 과의 비교(=, <>, >, <)는 결과가 항상 NULL(거짓처럼 취급)이므로 IS NULL / IS NOT NULL 을 써야 한다.
-- 규칙 2) NULL 이 포함된 산술 연산 결과는 NULL 이다. (예: 100 + NULL = NULL)
-- 규칙 3) COUNT(*) 는 모든 행을 세지만 COUNT(컬럼), SUM, AVG 는 NULL 값을 무시한다.
-- COALESCE(a, b, ...) : 왼쪽부터 처음으로 NULL 이 아닌 값을 반환한다. (NULL 대체용)
-- NULLIF(a, b)        : a 와 b 가 같으면 NULL, 다르면 a 를 반환한다. (0 으로 나누기 방지 등에 사용)
-- 이 파일은 SQLite·MySQL 공통 문법만 사용한다.

DROP TABLE IF EXISTS members;

CREATE TABLE members (
    id    INTEGER PRIMARY KEY,
    name  VARCHAR(30) NOT NULL,
    phone VARCHAR(20),          -- 전화번호 (없으면 NULL)
    bonus INTEGER,              -- 보너스 (없으면 NULL)
    visits INTEGER NOT NULL     -- 방문 횟수
);

INSERT INTO members (id, name, phone, bonus, visits) VALUES
    (1, '김하늘', '010-1111-2222', 300, 10),
    (2, '이바다', NULL,            NULL, 0),
    (3, '박나무', '010-3333-4444', 0,    5),
    (4, '최구름', NULL,            500,  2),
    (5, '정노을', '010-5555-6666', NULL, 8);

-- 1) NULL 비교는 = 가 아닌 IS NULL 사용: 전화번호가 없는 회원
SELECT id, name FROM members WHERE phone IS NULL;        -- 이바다, 최구름

-- 2) 잘못된 예: phone = NULL 은 항상 NULL 이므로 결과가 한 건도 없다
SELECT id, name FROM members WHERE phone = NULL;         -- (결과 없음)

-- 3) IS NOT NULL: 전화번호가 있는 회원
SELECT id, name, phone FROM members WHERE phone IS NOT NULL;   -- 김하늘, 박나무, 정노을

-- 4) COALESCE 로 NULL 대체: 전화번호가 없으면 '미등록', 보너스가 없으면 0 으로 표시
SELECT name,
       COALESCE(phone, '미등록') AS phone_text,
       COALESCE(bonus, 0)        AS bonus_value
FROM members
ORDER BY id;

-- 5) NULL 이 들어간 산술 연산: bonus 가 NULL 이면 합계도 NULL, COALESCE 를 쓰면 정상 계산
SELECT name,
       visits * 100 + bonus              AS total_wrong,   -- 이바다, 정노을은 NULL
       visits * 100 + COALESCE(bonus, 0) AS total_right
FROM members
ORDER BY id;

-- 6) 집계 함수와 NULL: COUNT(*) 는 5, COUNT(bonus) 는 3, AVG(bonus) 는 NULL 을 뺀 (300+0+500)/3
SELECT COUNT(*)                   AS all_rows,
       COUNT(bonus)               AS bonus_rows,
       AVG(bonus)                 AS avg_ignore_null,      -- 266.666...
       AVG(COALESCE(bonus, 0))    AS avg_null_as_zero      -- 160
FROM members;

-- 7) NULLIF 로 0 으로 나누기 방지: 방문 1회당 보너스 (방문 0회이면 NULL 반환)
SELECT name,
       bonus * 1.0 / NULLIF(visits, 0) AS bonus_per_visit
FROM members
ORDER BY id;

-- 8) 정렬과 NULL: NULL 을 맨 뒤로 보내기 (SQLite·MySQL 공통 방식)
SELECT name, bonus
FROM members
ORDER BY CASE WHEN bonus IS NULL THEN 1 ELSE 0 END, bonus DESC;

-- 연습 문제
-- 1) 보너스가 NULL 이거나 0 인 회원의 이름을 조회해 보자. (힌트: COALESCE(bonus, 0) = 0)
-- 2) 전화번호가 있으면 전화번호를, 없으면 이름을 contact 컬럼으로 보여 주는 쿼리를 작성해 보자.
