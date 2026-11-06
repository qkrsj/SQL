-- Day 24: 중복 데이터 찾기와 제거 (DISTINCT, GROUP BY HAVING, DELETE)
-- 목표: 테이블에서 중복된 행을 찾아내고, 하나만 남기고 안전하게 삭제하는 방법을 익힌다.

-- 개념 설명
-- DISTINCT: 결과에서 완전히 같은 행을 하나로 합쳐 보여준다. (원본 데이터는 바뀌지 않는다.)
-- 중복 찾기: GROUP BY 중복기준컬럼 HAVING COUNT(*) > 1 로 2번 이상 나타나는 값을 찾는다.
-- 중복 제거(삭제): 같은 값을 가진 행들 중 id 가 가장 작은 행(MIN(id))만 남기고 나머지를 DELETE 한다.
-- 삭제 전에는 반드시 SELECT 로 지울 대상을 먼저 확인하는 습관을 들인다.
-- 이 파일은 SQLite·MySQL 공통 문법만 사용한다.

DROP TABLE IF EXISTS members;

CREATE TABLE members (
    id    INTEGER PRIMARY KEY,
    name  VARCHAR(20) NOT NULL,
    email VARCHAR(50) NOT NULL,
    city  VARCHAR(20) NOT NULL
);

INSERT INTO members (id, name, email, city) VALUES
    (1, '김민수', 'minsu@example.com', '서울'),
    (2, '이지은', 'jieun@example.com', '부산'),
    (3, '김민수', 'minsu@example.com', '서울'),
    (4, '박서준', 'seojun@example.com', '서울'),
    (5, '이지은', 'jieun@example.com', '부산'),
    (6, '최유나', 'yuna@example.com', '대구'),
    (7, '김민수', 'minsu@example.com', '인천');

-- 1) DISTINCT: 어떤 도시가 있는지 중복 없이 보기
SELECT DISTINCT city
FROM members;
-- 결과: 서울, 부산, 대구, 인천 (4행)

-- 2) 여러 컬럼 조합의 DISTINCT: (이름, 이메일) 조합이 같으면 하나로 본다
SELECT DISTINCT name, email
FROM members;
-- 결과: 4행 (김민수, 이지은, 박서준, 최유나)

-- 3) 중복된 이메일 찾기: 2번 이상 나온 값과 횟수
SELECT email, COUNT(*) AS cnt
FROM members
GROUP BY email
HAVING COUNT(*) > 1;
-- 결과: jieun@example.com 2, minsu@example.com 3

-- 4) 중복 행 중 남길 행(가장 작은 id)과 지울 행 확인하기
SELECT id, name, email
FROM members
WHERE id NOT IN (SELECT MIN(id) FROM members GROUP BY email);
-- 결과: id 3, 5, 7 이 삭제 대상

-- 5) 이메일 기준 중복 제거: 이메일마다 가장 작은 id 하나만 남기고 삭제
DELETE FROM members
WHERE id NOT IN (SELECT MIN(id) FROM members GROUP BY email);

-- 6) 삭제 결과 확인
SELECT * FROM members ORDER BY id;
-- 결과: id 1, 2, 4, 6 만 남는다

-- 7) 다시 중복 검사: 결과가 0행이면 중복이 모두 사라진 것
SELECT email, COUNT(*) AS cnt
FROM members
GROUP BY email
HAVING COUNT(*) > 1;

-- 연습 문제
-- 문제 1) members 테이블에서 (name, city) 조합이 같은 중복 쌍을 찾는 쿼리를 작성해 보세요.
--         (힌트: GROUP BY name, city HAVING COUNT(*) > 1)
-- 문제 2) 중복 제거 후, 앞으로 같은 이메일이 들어오지 못하게 하려면 어떻게 해야 할까요?
--         (힌트: UNIQUE 제약조건 또는 CREATE UNIQUE INDEX)
