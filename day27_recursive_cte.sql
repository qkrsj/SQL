-- Day 27: 재귀 CTE (WITH RECURSIVE)
-- 목표: 재귀 CTE로 숫자·날짜 연속 목록을 만들고, 조직도 같은 계층 구조를 한 번에 조회한다.

-- 개념 설명
-- 재귀 CTE는 자기 자신을 참조하는 WITH 절이다. 구조는 항상 세 부분이다.
--   1) 앵커(시작) 쿼리 : 출발점이 되는 행을 만든다.
--   2) UNION ALL
--   3) 재귀 쿼리       : CTE 자신을 FROM 에 써서 "다음 행"을 만든다.
-- 재귀 쿼리가 더 이상 행을 만들지 못하면 반복이 끝난다.
-- 종료 조건(WHERE)을 꼭 넣어야 한다. 빼먹으면 무한 반복이 된다!
-- 활용: 1~N 숫자열, 연속된 날짜 목록, 조직도/카테고리 트리, 댓글 계층 탐색.

DROP TABLE IF EXISTS employees;

CREATE TABLE employees (
    id         INTEGER PRIMARY KEY,
    name       VARCHAR(20) NOT NULL,
    manager_id INTEGER            -- 상사의 id (최상위는 NULL)
);

INSERT INTO employees (id, name, manager_id) VALUES
    (1, '김대표', NULL),
    (2, '이부장', 1),
    (3, '박팀장', 2),
    (4, '최사원', 3),
    (5, '정사원', 3),
    (6, '한이사', 1),
    (7, '오대리', 6);

-- 1) 1부터 5까지 숫자 만들기
WITH RECURSIVE nums(n) AS (
    SELECT 1                      -- 앵커: 시작값
    UNION ALL
    SELECT n + 1 FROM nums        -- 재귀: 이전 값 + 1
    WHERE n < 5                   -- 종료 조건
)
SELECT n FROM nums;

-- 2) 연속된 날짜 7일 만들기 (빈 날짜 채우기에 유용)
WITH RECURSIVE days(d) AS (
    SELECT DATE('2026-11-01')
    UNION ALL
    SELECT DATE(d, '+1 day') FROM days
    WHERE d < DATE('2026-11-07')
)
SELECT d FROM days;

-- 3) 조직도 전체 펼치기: 대표(김대표)부터 아래로 내려가며 단계(level) 계산
WITH RECURSIVE org(id, name, level) AS (
    SELECT id, name, 1
    FROM employees
    WHERE manager_id IS NULL      -- 앵커: 최상위 직원
    UNION ALL
    SELECT e.id, e.name, o.level + 1
    FROM employees e
    JOIN org o ON e.manager_id = o.id   -- 재귀: 현재 단계 직원의 부하 직원
)
SELECT id, name, level
FROM org
ORDER BY level, id;

-- 4) 특정 직원(박팀장) 아래의 모든 부하 직원 찾기
WITH RECURSIVE subordinates(id, name) AS (
    SELECT id, name FROM employees WHERE id = 3
    UNION ALL
    SELECT e.id, e.name
    FROM employees e
    JOIN subordinates s ON e.manager_id = s.id
)
SELECT name FROM subordinates WHERE id <> 3;

-- 5) 위로 올라가기: 최사원부터 대표까지 보고 라인(상사 체인) 찾기
WITH RECURSIVE chain(id, name, manager_id, step) AS (
    SELECT id, name, manager_id, 0 FROM employees WHERE id = 4
    UNION ALL
    SELECT e.id, e.name, e.manager_id, c.step + 1
    FROM employees e
    JOIN chain c ON e.id = c.manager_id
)
SELECT step, name FROM chain ORDER BY step;

-- 연습 문제
-- 문제 1) 재귀 CTE로 1부터 10까지의 합계를 구해 보세요. (힌트: 숫자열을 만든 뒤 SUM)
-- 문제 2) 한이사 아래의 모든 부하 직원 수를 구해 보세요. (한이사 본인은 제외)
