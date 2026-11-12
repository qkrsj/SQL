-- Day 30: 교집합과 차집합 (INTERSECT, EXCEPT)
-- 목표: INTERSECT 와 EXCEPT 로 "둘 다 해당하는 값"과 "한쪽에만 있는 값"을 찾는다.

-- 개념 설명
-- Day 18 에서 배운 UNION 이 "합집합"이라면, 같은 집합 연산자 중 두 가지가 더 있다.
--   INTERSECT : 두 결과에 모두 있는 행만 남긴다 (교집합)
--   EXCEPT    : 앞 결과에는 있고 뒤 결과에는 없는 행만 남긴다 (차집합)
-- 규칙은 UNION 과 같다.
--   1) 두 SELECT 의 컬럼 개수와 타입이 서로 맞아야 한다.
--   2) 중복 행은 자동으로 제거된다.
--   3) ORDER BY 는 맨 마지막에 한 번만 쓴다.
-- EXCEPT 는 순서가 중요하다. A EXCEPT B 와 B EXCEPT A 는 결과가 다르다.
-- 참고: MySQL 은 8.0.31 이상부터 INTERSECT, EXCEPT 를 지원한다.
--       (그 이전 버전에서는 IN, NOT IN 이나 JOIN 으로 대신한다.)

DROP TABLE IF EXISTS sql_class;
DROP TABLE IF EXISTS python_class;

CREATE TABLE sql_class (
    student VARCHAR(10) NOT NULL
);

CREATE TABLE python_class (
    student VARCHAR(10) NOT NULL
);

INSERT INTO sql_class (student) VALUES
    ('민수'), ('지은'), ('하준'), ('서연'), ('도윤');

INSERT INTO python_class (student) VALUES
    ('지은'), ('서연'), ('예린'), ('지우'), ('서연');  -- 서연은 일부러 두 번 넣음

-- 1) INTERSECT : 두 수업을 모두 듣는 학생 (지은, 서연)
SELECT student FROM sql_class
INTERSECT
SELECT student FROM python_class
ORDER BY student;

-- 2) EXCEPT : SQL 수업만 듣는 학생 (도윤, 민수, 하준)
SELECT student FROM sql_class
EXCEPT
SELECT student FROM python_class
ORDER BY student;

-- 3) 순서를 바꾸면 결과가 달라진다 : Python 수업만 듣는 학생 (예린, 지우)
SELECT student FROM python_class
EXCEPT
SELECT student FROM sql_class
ORDER BY student;

-- 4) 한쪽에만 있는 학생 전체 (대칭 차집합) : UNION 과 EXCEPT 를 함께 사용
SELECT student FROM (
    SELECT student FROM sql_class
    EXCEPT
    SELECT student FROM python_class
) AS only_sql
UNION
SELECT student FROM (
    SELECT student FROM python_class
    EXCEPT
    SELECT student FROM sql_class
) AS only_python
ORDER BY student;

-- 5) 같은 결과를 IN / NOT IN 으로도 만들 수 있다 (구버전 MySQL 대비)
SELECT DISTINCT student
FROM sql_class
WHERE student IN (SELECT student FROM python_class)
ORDER BY student;

SELECT DISTINCT student
FROM sql_class
WHERE student NOT IN (SELECT student FROM python_class)
ORDER BY student;

-- 6) 실전 예: 주문 이력 비교 - 1월에만 주문한 고객
DROP TABLE IF EXISTS orders;

CREATE TABLE orders (
    order_id    INTEGER PRIMARY KEY,
    customer    VARCHAR(10) NOT NULL,
    order_month INTEGER     NOT NULL   -- 주문한 월
);

INSERT INTO orders (order_id, customer, order_month) VALUES
    (1, '가온', 1), (2, '나래', 1), (3, '다솜', 1),
    (4, '나래', 2), (5, '라온', 2), (6, '다솜', 2);

-- 1월에 주문했지만 2월에는 주문하지 않은 고객 (이탈 후보) -> 가온
SELECT customer FROM orders WHERE order_month = 1
EXCEPT
SELECT customer FROM orders WHERE order_month = 2;

-- 1월과 2월 모두 주문한 단골 고객 -> 나래, 다솜
SELECT customer FROM orders WHERE order_month = 1
INTERSECT
SELECT customer FROM orders WHERE order_month = 2
ORDER BY customer;

-- 연습 문제
-- 1) 2월에만 주문한 신규 고객(1월에는 없고 2월에만 있는 고객)을 EXCEPT 로 구하시오.
-- 2) 4번 예제처럼 UNION 과 EXCEPT 를 사용해, 1월 또는 2월 중 "한 달만" 주문한 고객을 모두 구하시오.
