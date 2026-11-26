-- Day 44: 퍼널 분석 (단계별 전환율)
-- 목표: 방문 → 장바구니 → 결제 → 구매 단계별 사용자 수와 전환율, 이탈률을 계산한다.

-- 개념 설명
--   퍼널(funnel)은 사용자가 여러 단계를 차례로 거치며 줄어드는 흐름을 말한다.
--   events 테이블은 사용자 한 명이 한 단계에 도달할 때마다 한 행이 쌓이는 로그 구조이다.
--   같은 사용자가 같은 단계를 여러 번 기록할 수 있으므로 COUNT(DISTINCT user_id)로 센다.
--   단계 전환율 = 현재 단계 사용자 수 / 이전 단계 사용자 수
--   전체 전환율 = 현재 단계 사용자 수 / 첫 단계 사용자 수
--   이탈률     = 1 - 단계 전환율
--   SQLite, MySQL 공통 문법만 사용한다. (CTE 는 MySQL 8.0 / SQLite 3.8.3 이상)

DROP TABLE IF EXISTS events;

CREATE TABLE events (
    user_id    INTEGER     NOT NULL,
    step_no    INTEGER     NOT NULL,   -- 1 방문, 2 장바구니, 3 결제, 4 구매
    step_name  VARCHAR(20) NOT NULL
);

INSERT INTO events (user_id, step_no, step_name) VALUES
    (1, 1, '방문'), (1, 2, '장바구니'), (1, 3, '결제'), (1, 4, '구매'),
    (2, 1, '방문'), (2, 2, '장바구니'), (2, 3, '결제'),
    (3, 1, '방문'), (3, 2, '장바구니'),
    (4, 1, '방문'),
    (5, 1, '방문'), (5, 2, '장바구니'), (5, 3, '결제'), (5, 4, '구매'),
    (6, 1, '방문'), (6, 1, '방문'),
    (7, 1, '방문'), (7, 2, '장바구니'), (7, 2, '장바구니'),
    (8, 1, '방문'), (8, 2, '장바구니'), (8, 3, '결제'), (8, 4, '구매'),
    (9, 1, '방문'), (9, 2, '장바구니'),
    (10, 1, '방문');

-- 1) 단계별 사용자 수 (중복 기록은 DISTINCT 로 제거)
SELECT step_no, step_name, COUNT(DISTINCT user_id) AS users
FROM events
GROUP BY step_no, step_name
ORDER BY step_no;

-- 2) 단계 전환율, 전체 전환율, 이탈률 (LAG 와 FIRST_VALUE 사용)
WITH step_users AS (
    SELECT step_no, step_name, COUNT(DISTINCT user_id) AS users
    FROM events
    GROUP BY step_no, step_name
)
SELECT step_no, step_name, users,
       LAG(users) OVER (ORDER BY step_no) AS prev_users,
       ROUND(users * 100.0 / LAG(users) OVER (ORDER BY step_no), 1)          AS step_rate_pct,
       ROUND(users * 100.0 / FIRST_VALUE(users) OVER (ORDER BY step_no), 1)  AS total_rate_pct,
       ROUND(100.0 - users * 100.0 / LAG(users) OVER (ORDER BY step_no), 1)  AS drop_rate_pct
FROM step_users
ORDER BY step_no;

-- 3) 사용자별 도달한 최대 단계 (어디까지 갔는지)
SELECT user_id, MAX(step_no) AS max_step
FROM events
GROUP BY user_id
ORDER BY max_step DESC, user_id;

-- 4) 각 단계에서 이탈한 사용자 수 (최대 단계가 그 단계인 사용자)
WITH user_max AS (
    SELECT user_id, MAX(step_no) AS max_step
    FROM events
    GROUP BY user_id
)
SELECT max_step AS last_step, COUNT(*) AS dropped_users
FROM user_max
WHERE max_step < 4
GROUP BY max_step
ORDER BY max_step;

-- 연습 문제
-- 1) '장바구니'에 담았지만 '결제'까지 가지 않은 사용자의 user_id 목록을 구하세요.
-- 2) 가장 이탈률이 높은 단계(직전 단계 대비)를 찾는 쿼리를 작성해 보세요.
