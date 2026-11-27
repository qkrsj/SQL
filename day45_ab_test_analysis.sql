-- Day 45: A/B 테스트 결과 비교 (그룹별 전환율과 개선율)
-- 목표: 대조군(A)과 실험군(B)의 사용자 수, 전환 수, 전환율, 평균 구매액을 비교한다.

-- 개념 설명
--   A/B 테스트는 사용자를 두 그룹으로 나눠 서로 다른 화면을 보여주고 결과를 비교하는 실험이다.
--   participants 테이블은 사용자 한 명당 한 행이며 어느 그룹에 배정됐는지(grp)를 가진다.
--   purchases 테이블은 구매한 사용자의 구매 금액을 가진다. (구매하지 않은 사용자는 행이 없다)
--   전환율       = 구매한 사용자 수 / 전체 사용자 수
--   절대 차이    = B 전환율 - A 전환율          (퍼센트포인트, %p)
--   상대 개선율  = (B 전환율 - A 전환율) / A 전환율
--   구매하지 않은 사용자도 분모에 포함해야 하므로 LEFT JOIN 을 사용한다.
--   SQLite, MySQL 공통 문법만 사용한다. (CTE 는 MySQL 8.0 / SQLite 3.8.3 이상)

DROP TABLE IF EXISTS purchases;
DROP TABLE IF EXISTS participants;

CREATE TABLE participants (
    user_id  INTEGER     PRIMARY KEY,
    grp      VARCHAR(1)  NOT NULL      -- 'A' 대조군, 'B' 실험군
);

CREATE TABLE purchases (
    user_id  INTEGER NOT NULL,
    amount   INTEGER NOT NULL
);

INSERT INTO participants (user_id, grp) VALUES
    (1, 'A'), (2, 'A'), (3, 'A'), (4, 'A'), (5, 'A'),
    (6, 'A'), (7, 'A'), (8, 'A'), (9, 'A'), (10, 'A'),
    (11, 'B'), (12, 'B'), (13, 'B'), (14, 'B'), (15, 'B'),
    (16, 'B'), (17, 'B'), (18, 'B'), (19, 'B'), (20, 'B');

INSERT INTO purchases (user_id, amount) VALUES
    (2, 30000), (5, 45000), (9, 20000),
    (11, 35000), (12, 50000), (14, 28000), (16, 42000), (19, 60000);

-- 1) 그룹별 사용자 수 (배정이 한쪽으로 쏠리지 않았는지 확인)
SELECT grp, COUNT(*) AS users
FROM participants
GROUP BY grp
ORDER BY grp;

-- 2) 그룹별 구매 사용자 수, 전환율, 평균 구매액
SELECT p.grp,
       COUNT(*)                                          AS users,
       COUNT(pu.user_id)                                 AS buyers,
       ROUND(COUNT(pu.user_id) * 100.0 / COUNT(*), 1)    AS conv_rate_pct,
       ROUND(AVG(pu.amount), 0)                          AS avg_amount
FROM participants p
LEFT JOIN purchases pu ON pu.user_id = p.user_id
GROUP BY p.grp
ORDER BY p.grp;

-- 3) B 그룹의 절대 차이(%p)와 상대 개선율(%) 계산
WITH rate AS (
    SELECT p.grp,
           COUNT(pu.user_id) * 1.0 / COUNT(*) AS conv_rate
    FROM participants p
    LEFT JOIN purchases pu ON pu.user_id = p.user_id
    GROUP BY p.grp
)
SELECT ROUND(a.conv_rate * 100, 1)                                  AS a_rate_pct,
       ROUND(b.conv_rate * 100, 1)                                  AS b_rate_pct,
       ROUND((b.conv_rate - a.conv_rate) * 100, 1)                  AS diff_pp,
       ROUND((b.conv_rate - a.conv_rate) * 100.0 / a.conv_rate, 1)  AS lift_pct
FROM rate a
JOIN rate b ON a.grp = 'A' AND b.grp = 'B';

-- 4) 사용자당 평균 매출 (구매하지 않은 사용자는 0원으로 계산)
SELECT p.grp,
       SUM(COALESCE(pu.amount, 0))                         AS total_amount,
       ROUND(SUM(COALESCE(pu.amount, 0)) * 1.0 / COUNT(*), 0) AS revenue_per_user
FROM participants p
LEFT JOIN purchases pu ON pu.user_id = p.user_id
GROUP BY p.grp
ORDER BY p.grp;

-- 연습 문제
-- 1) 구매 금액이 30,000원 이상인 "큰 구매"의 전환율을 그룹별로 구해 보세요.
-- 2) 그룹별 최대 구매 금액과 최소 구매 금액을 한 번에 조회해 보세요.
