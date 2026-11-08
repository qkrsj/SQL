-- Day 26: CROSS JOIN (모든 조합 만들기)
-- 목표: CROSS JOIN 으로 두 테이블의 모든 조합을 만들고, 빠진 조합을 찾는 방법을 익힌다.

-- 개념 설명
-- CROSS JOIN 은 ON 조건 없이 왼쪽 행 × 오른쪽 행의 모든 조합(카테시안 곱)을 만든다.
-- 3행 × 4행이면 결과는 12행이다. 행 수가 곱해지므로 큰 테이블에는 주의한다.
-- FROM a, b (쉼표 조인)도 같은 결과지만, 의도가 드러나도록 CROSS JOIN 을 쓰는 것이 좋다.
-- 활용: 옵션 조합 목록, 날짜 x 매장 같은 "빈 칸 없는" 틀 만들기, 없는 조합 찾기.

DROP TABLE IF EXISTS sales;
DROP TABLE IF EXISTS sizes;
DROP TABLE IF EXISTS colors;

CREATE TABLE colors (
    color VARCHAR(10) PRIMARY KEY
);

CREATE TABLE sizes (
    size VARCHAR(5) PRIMARY KEY
);

CREATE TABLE sales (
    id    INTEGER PRIMARY KEY,
    color VARCHAR(10) NOT NULL,
    size  VARCHAR(5) NOT NULL,
    qty   INTEGER NOT NULL
);

INSERT INTO colors (color) VALUES ('검정'), ('흰색'), ('파랑');
INSERT INTO sizes (size) VALUES ('S'), ('M'), ('L'), ('XL');

INSERT INTO sales (id, color, size, qty) VALUES
    (1, '검정', 'M', 5),
    (2, '검정', 'L', 3),
    (3, '흰색', 'S', 2),
    (4, '흰색', 'M', 4),
    (5, '검정', 'M', 1);

-- 1) 모든 색상 x 사이즈 조합 (3 x 4 = 12행)
SELECT c.color, s.size
FROM colors c
CROSS JOIN sizes s
ORDER BY c.color, s.size;
-- 결과: 12개 조합

-- 2) 조합 개수 확인
SELECT COUNT(*) AS combo_count
FROM colors
CROSS JOIN sizes;
-- 결과: 12

-- 3) 조합별 판매량을 빠짐없이 보기: CROSS JOIN 틀 + LEFT JOIN + COALESCE
SELECT c.color, s.size, COALESCE(SUM(sa.qty), 0) AS total_qty
FROM colors c
CROSS JOIN sizes s
LEFT JOIN sales sa ON sa.color = c.color AND sa.size = s.size
GROUP BY c.color, s.size
ORDER BY c.color, s.size;
-- 결과: 판매가 없는 조합도 0으로 나온다. 예) 검정 M 은 5+1=6

-- 4) 한 번도 팔리지 않은 조합 찾기
SELECT c.color, s.size
FROM colors c
CROSS JOIN sizes s
LEFT JOIN sales sa ON sa.color = c.color AND sa.size = s.size
WHERE sa.id IS NULL
ORDER BY c.color, s.size;
-- 결과: 12개 조합 중 판매 기록이 있는 4개(검정M, 검정L, 흰색S, 흰색M)를 뺀 8개

-- 5) 서로 다른 두 색상의 짝 만들기 (중복 쌍 제외: a < b)
SELECT a.color AS color1, b.color AS color2
FROM colors a
CROSS JOIN colors b
WHERE a.color < b.color
ORDER BY color1, color2;
-- 결과: 3개 쌍 (같은 색끼리, 순서만 다른 쌍은 제외)

-- 연습 문제
-- 1) sizes 와 colors 를 CROSS JOIN 하여 "검정-S" 같은 형태의 상품명 목록을 만드세요. (|| 연산자 사용)
-- 2) 색상별로 아직 한 번도 팔리지 않은 사이즈의 개수를 조회하세요.
