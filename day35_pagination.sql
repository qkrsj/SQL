-- Day 35: 페이지네이션 (LIMIT/OFFSET, 키셋 페이징, 전체 건수)
-- 목표: 게시글 목록처럼 많은 데이터를 페이지 단위로 나누어 가져오는 방법과, 페이지가 깊어질 때의 성능 문제를 피하는 방법을 익힌다.

-- 개념 설명
--   기본 형태         : ORDER BY ... LIMIT 페이지크기 OFFSET (페이지번호 - 1) * 페이지크기
--   OFFSET            : 앞에서부터 건너뛸 행 수. OFFSET 20 이면 21번째 행부터 가져온다.
--   정렬 필수         : ORDER BY 없이 LIMIT/OFFSET 을 쓰면 페이지마다 결과 순서가 달라질 수 있다.
--   정렬 기준 유일화  : 정렬 값이 같은 행이 있으면 id 같은 유일한 컬럼을 마지막에 추가해 순서를 고정한다.
--   전체 페이지 수    : CEIL(전체 건수 / 페이지 크기). 전체 건수는 COUNT(*) 로 구한다.
--   키셋 페이징       : OFFSET 대신 "마지막으로 본 값보다 뒤" 조건(WHERE id < 마지막 id)을 쓴다.
--                       앞 행을 읽고 버리지 않으므로 페이지가 깊어져도 빠르다. (인덱스가 있을 때 특히 유리)
-- 주의: OFFSET 이 클수록 건너뛸 행을 모두 읽어야 해서 느려진다.
--       OFFSET 방식은 페이지를 넘기는 사이에 새 글이 추가되면 같은 글이 중복되어 보일 수 있다.

DROP TABLE IF EXISTS posts;

CREATE TABLE posts (
    id         INTEGER PRIMARY KEY,
    title      VARCHAR(50) NOT NULL,
    views      INTEGER NOT NULL,
    created_at DATE NOT NULL
);

INSERT INTO posts (id, title, views, created_at) VALUES
    (1,  'SQL 시작하기',        120, '2026-10-01'),
    (2,  'SELECT 기초',         80,  '2026-10-02'),
    (3,  'WHERE 조건',          80,  '2026-10-03'),
    (4,  'ORDER BY 정렬',       150, '2026-10-04'),
    (5,  '집계 함수',           95,  '2026-10-05'),
    (6,  'GROUP BY 정리',       200, '2026-10-06'),
    (7,  'JOIN 이해하기',       310, '2026-10-07'),
    (8,  '서브쿼리 활용',       150, '2026-10-08'),
    (9,  '윈도우 함수 맛보기',  275, '2026-10-09'),
    (10, '인덱스란?',           60,  '2026-10-10'),
    (11, '트랜잭션 개념',       130, '2026-10-11');

-- 1) 최신 글 먼저, 한 페이지에 4건씩 : 1페이지
SELECT id, title, created_at
FROM posts
ORDER BY created_at DESC, id DESC
LIMIT 4 OFFSET 0;

-- 2) 2페이지 : OFFSET = (2 - 1) * 4
SELECT id, title, created_at
FROM posts
ORDER BY created_at DESC, id DESC
LIMIT 4 OFFSET 4;

-- 3) 3페이지 (마지막 페이지는 4건보다 적을 수 있다)
SELECT id, title, created_at
FROM posts
ORDER BY created_at DESC, id DESC
LIMIT 4 OFFSET 8;

-- 4) 정렬 기준이 겹칠 때 : views 가 같은 글이 있으므로 id 를 추가해 순서를 고정한다.
SELECT id, title, views
FROM posts
ORDER BY views DESC, id ASC
LIMIT 4 OFFSET 0;

-- 5) 전체 건수와 전체 페이지 수 (페이지 크기 4)
--    정수 나눗셈 함정을 피하려고 (건수 + 크기 - 1) / 크기 로 올림 계산을 한다.
SELECT COUNT(*) AS total_rows,
       (COUNT(*) + 4 - 1) / 4 AS total_pages
FROM posts;

-- 6) 키셋 페이징 : 첫 페이지는 그냥 최신 4건
SELECT id, title
FROM posts
ORDER BY id DESC
LIMIT 4;

-- 7) 키셋 페이징 : 위 결과의 마지막 id 가 8 이었다면, 다음 페이지는 id < 8 조건으로 가져온다.
SELECT id, title
FROM posts
WHERE id < 8
ORDER BY id DESC
LIMIT 4;

-- 8) 조회수 상위 3개 글을 건너뛰고 그다음 3개 (순위 4~6위)
SELECT id, title, views
FROM posts
ORDER BY views DESC, id ASC
LIMIT 3 OFFSET 3;

-- 연습 문제
-- 1) 한 페이지에 3건씩 보여줄 때, 조회수(views) 높은 순으로 2페이지에 해당하는 글을 구해 보세요. (동점이면 id 오름차순)
-- 2) 키셋 페이징으로 id 오름차순 목록에서 마지막으로 본 id 가 5 일 때, 다음 3건을 가져오는 쿼리를 작성해 보세요.
