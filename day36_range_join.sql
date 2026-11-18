-- Day 36: 범위 조인 (Non-equi JOIN, BETWEEN 조인)
-- 목표: 같다(=)가 아니라 "구간에 속한다" 조건으로 두 테이블을 연결해, 점수→등급·금액→할인율 같은 구간 매핑을 익힌다.

-- 개념 설명
--   등가 조인(equi join)  : ON a.id = b.id 처럼 같은 값끼리 연결한다.
--   비등가 조인(non-equi) : ON 에 BETWEEN, <, >=, <= 같은 비교 조건을 써서 구간으로 연결한다.
--   기본 형태             : FROM 데이터 d JOIN 구간표 r ON d.값 BETWEEN r.최소 AND r.최대
--   장점                  : CASE WHEN 으로 구간을 하드코딩하지 않고, 구간표만 고치면 기준을 바꿀 수 있다.
--   LEFT JOIN             : 어느 구간에도 속하지 않는 행도 남기고 싶을 때 사용한다. (구간 컬럼은 NULL)
--   시간 구간 조인        : 이벤트 시각이 기간표의 시작~종료 사이에 있는지로 연결할 수도 있다.
-- 주의: 구간이 서로 겹치면 한 행이 여러 구간과 연결되어 결과가 중복된다.
--       경계값 처리를 위해 BETWEEN(양 끝 포함) 또는 >= 와 < 를 쓰고, 구간 정의와 일관되게 맞춘다.

DROP TABLE IF EXISTS scores;
DROP TABLE IF EXISTS grades;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS discount_rules;

CREATE TABLE scores (
    student VARCHAR(20) NOT NULL,
    score   INTEGER NOT NULL
);

CREATE TABLE grades (
    grade     VARCHAR(2) NOT NULL,
    min_score INTEGER NOT NULL,
    max_score INTEGER NOT NULL
);

CREATE TABLE orders (
    id     INTEGER PRIMARY KEY,
    amount INTEGER NOT NULL
);

CREATE TABLE discount_rules (
    min_amount    INTEGER NOT NULL,
    discount_rate INTEGER NOT NULL
);

INSERT INTO scores (student, score) VALUES
    ('민수', 95), ('지영', 88), ('철수', 72), ('영희', 65), ('하나', 100), ('보라', 40);

INSERT INTO grades (grade, min_score, max_score) VALUES
    ('A', 90, 100),
    ('B', 80, 89),
    ('C', 70, 79),
    ('D', 60, 69);
-- 60점 미만은 구간표에 없다 (F 등급 없음)

INSERT INTO orders (id, amount) VALUES
    (1, 8000), (2, 30000), (3, 55000), (4, 120000), (5, 50000);

INSERT INTO discount_rules (min_amount, discount_rate) VALUES
    (0, 0), (30000, 5), (50000, 10), (100000, 15);

-- 1) 점수를 등급으로 변환 : INNER JOIN 은 구간에 없는 학생(보라)이 빠진다.
SELECT s.student, s.score, g.grade
FROM scores s
JOIN grades g ON s.score BETWEEN g.min_score AND g.max_score
ORDER BY s.score DESC;

-- 2) LEFT JOIN 으로 구간 밖 학생도 남기기 : 보라의 등급은 NULL
SELECT s.student, s.score, COALESCE(g.grade, '등급없음') AS grade
FROM scores s
LEFT JOIN grades g ON s.score BETWEEN g.min_score AND g.max_score
ORDER BY s.score DESC;

-- 3) 등급별 인원 수 : 범위 조인 결과를 GROUP BY 로 집계
SELECT g.grade, COUNT(*) AS cnt, ROUND(AVG(s.score), 1) AS avg_score
FROM scores s
JOIN grades g ON s.score BETWEEN g.min_score AND g.max_score
GROUP BY g.grade
ORDER BY g.grade;

-- 4) 시작값만 있는 구간표 : "가장 큰 min_amount 중 주문금액 이하인 것"을 적용한다.
--    (구간표에 최대값이 없을 때 쓰는 흔한 패턴, 상관 서브쿼리 사용)
SELECT o.id, o.amount, r.discount_rate
FROM orders o
JOIN discount_rules r
  ON r.min_amount = (
        SELECT MAX(r2.min_amount)
        FROM discount_rules r2
        WHERE r2.min_amount <= o.amount
     )
ORDER BY o.id;

-- 5) 할인 금액과 결제 금액 계산 (정수 나눗셈이므로 100 으로 나누기 전 곱셈 먼저)
SELECT o.id, o.amount,
       r.discount_rate,
       o.amount * r.discount_rate / 100 AS discount,
       o.amount - o.amount * r.discount_rate / 100 AS pay
FROM orders o
JOIN discount_rules r
  ON r.min_amount = (
        SELECT MAX(r2.min_amount)
        FROM discount_rules r2
        WHERE r2.min_amount <= o.amount
     )
ORDER BY o.id;

-- 연습 문제
-- 1) scores 와 grades 를 조인해 'B' 등급 이상(A, B)인 학생의 이름과 점수만 조회해 보세요.
-- 2) 등급표의 구간을 겹치게 바꾸면(예: C 를 70~85 로 수정) 학생 결과가 어떻게 달라지는지 직접 확인해 보세요.
