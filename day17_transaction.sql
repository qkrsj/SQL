-- Day 17: 트랜잭션(TRANSACTION)
-- 목표: 여러 SQL을 하나의 작업 단위로 묶어 모두 성공하거나 모두 취소되게 하는 방법을 익힌다.

-- 개념 설명
-- 트랜잭션은 "하나로 취급해야 하는 여러 SQL 문의 묶음"이다.
-- 예) 계좌이체: 보내는 계좌에서 차감 + 받는 계좌에 입금 → 둘 중 하나만 반영되면 안 된다.
-- BEGIN    : 트랜잭션 시작 (MySQL에서는 START TRANSACTION도 사용 가능)
-- COMMIT   : 지금까지의 변경을 영구히 확정한다.
-- ROLLBACK : 지금까지의 변경을 모두 취소하고 BEGIN 이전 상태로 되돌린다.
-- 트랜잭션의 성질(ACID): 원자성, 일관성, 격리성, 지속성
-- 주의: MySQL은 기본적으로 한 문장마다 자동 커밋(autocommit)되므로
--       여러 문장을 묶으려면 반드시 BEGIN으로 시작해야 한다.
-- 이 파일은 SQLite·MySQL 공통 문법(BEGIN / COMMIT / ROLLBACK)만 사용한다.

DROP TABLE IF EXISTS accounts;

CREATE TABLE accounts (
    id      INTEGER PRIMARY KEY,
    owner   VARCHAR(30) NOT NULL,
    balance INTEGER NOT NULL
);

INSERT INTO accounts (id, owner, balance) VALUES
    (1, '김하늘', 10000),
    (2, '이바다',  5000),
    (3, '박나무',  7000);

-- 1) COMMIT: 김하늘 → 이바다 3000원 이체 (두 UPDATE가 함께 확정된다)
BEGIN;
UPDATE accounts SET balance = balance - 3000 WHERE id = 1;
UPDATE accounts SET balance = balance + 3000 WHERE id = 2;
COMMIT;

SELECT * FROM accounts ORDER BY id;   -- 김하늘 7000, 이바다 8000, 박나무 7000

-- 2) ROLLBACK: 실수로 잘못된 변경을 했을 때 모두 취소한다
BEGIN;
UPDATE accounts SET balance = 0;      -- 앗, WHERE를 빼먹었다!
SELECT * FROM accounts ORDER BY id;   -- 트랜잭션 안에서는 전부 0으로 보인다
ROLLBACK;

SELECT * FROM accounts ORDER BY id;   -- 원래대로 복구됨 (7000, 8000, 7000)

-- 3) 조건 확인 후 취소: 박나무가 이바다에게 9000원을 보내려는 경우
--    잔액(7000)이 부족하므로 이체를 확정하지 않고 ROLLBACK 한다.
BEGIN;
UPDATE accounts SET balance = balance - 9000 WHERE id = 3;
UPDATE accounts SET balance = balance + 9000 WHERE id = 2;
-- 잔액이 음수가 된 계좌가 있는지 확인한다 (실제 서비스에서는 프로그램 코드가 이 결과로 판단)
SELECT * FROM accounts WHERE balance < 0;   -- 박나무 -2000 → 문제 발견!
ROLLBACK;

SELECT * FROM accounts ORDER BY id;   -- 변화 없음 (7000, 8000, 7000)

-- 연습 문제
-- 1) 이바다(id=2)가 박나무(id=3)에게 2000원을 이체하는 트랜잭션을 BEGIN ... COMMIT 으로 작성해 보자.
-- 2) 모든 계좌에 1000원씩 이자를 더하는 UPDATE를 BEGIN 안에서 실행한 뒤,
--    결과를 SELECT로 확인하고 ROLLBACK 으로 취소해 보자. 취소 후 잔액이 원래대로인지 확인한다.
