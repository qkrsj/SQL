-- Day 32: 문자열 연결과 그룹 문자열 합치기 (||, GROUP_CONCAT)
-- 목표: 여러 컬럼을 하나의 문자열로 붙이고, 그룹 안의 여러 행을 한 줄로 모아 보여주는 방법을 익힌다.

-- 개념 설명
--   a || b            : 두 문자열을 이어 붙인다 (SQLite 방식).
--                       MySQL 에서는 CONCAT(a, b) 를 쓰는 것이 일반적이다.
--   NULL 주의         : 값 중 하나라도 NULL 이면 || 결과도 NULL 이 된다. COALESCE 로 먼저 바꿔 준다.
--   GROUP_CONCAT(col) : GROUP BY 로 묶인 그룹 안의 값들을 쉼표(,)로 이어 한 문자열로 만든다.
--                       NULL 값은 자동으로 건너뛴다.
--   DISTINCT          : GROUP_CONCAT(DISTINCT col) 로 중복을 제거하고 모을 수 있다.
-- 참고: 구분자를 바꾸는 문법이 DB 마다 다르다.
--       SQLite 는 GROUP_CONCAT(col, ' / '), MySQL 은 GROUP_CONCAT(col SEPARATOR ' / ').
--       이 파일은 두 DB 에서 모두 되는 "기본 구분자(쉼표)" 형태만 사용한다.

DROP TABLE IF EXISTS members;

CREATE TABLE members (
    id         INTEGER PRIMARY KEY,
    last_name  VARCHAR(10) NOT NULL,
    first_name VARCHAR(10) NOT NULL,
    team       VARCHAR(10) NOT NULL,
    nickname   VARCHAR(10)           -- NULL 허용
);

INSERT INTO members (id, last_name, first_name, team, nickname) VALUES
    (1, '김', '민수', '개발', '민'),
    (2, '이', '지은', '개발', NULL),
    (3, '박', '하준', '디자인', '준'),
    (4, '최', '서연', '개발', '연이'),
    (5, '정', '도윤', '디자인', NULL),
    (6, '한', '유나', '기획', '유');

-- 1) || 로 성과 이름을 붙여 전체 이름 만들기
SELECT id,
       last_name || first_name AS full_name,
       team
FROM members;

-- 2) 문자열 상수와 함께 붙이기 : "김민수 (개발)" 형태
SELECT last_name || first_name || ' (' || team || ')' AS label
FROM members
ORDER BY id;

-- 3) NULL 함정 : nickname 이 NULL 이면 결과 전체가 NULL 이 된다
SELECT first_name,
       first_name || '/' || nickname                  AS wrong_result,
       first_name || '/' || COALESCE(nickname, '없음') AS right_result
FROM members;

-- 4) GROUP_CONCAT : 팀별 구성원 이름을 한 줄로 모으기
SELECT team,
       COUNT(*)           AS cnt,
       GROUP_CONCAT(first_name) AS names
FROM members
GROUP BY team
ORDER BY cnt DESC, team;

-- 5) GROUP_CONCAT 은 NULL 을 건너뛴다 : 별명이 있는 사람만 모인다
SELECT team,
       GROUP_CONCAT(nickname) AS nicknames
FROM members
GROUP BY team
ORDER BY team;

-- 6) DISTINCT 로 중복 제거 : 성이 같은 사람이 여럿이어도 한 번만 모은다
SELECT GROUP_CONCAT(DISTINCT team) AS teams
FROM members;

-- 7) 전체를 한 줄로 : GROUP BY 없이 쓰면 모든 행이 하나의 그룹이 된다
SELECT GROUP_CONCAT(last_name || first_name) AS everyone
FROM members;

-- 연습 문제
-- 1) 각 팀별로 "팀명: 인원수명" 형태의 문자열(예: 개발: 3명)을 만들어 보여주세요.
--    (힌트: team || ': ' || COUNT(*) || '명')
-- 2) 별명(nickname)이 NULL 인 사람은 이름을 대신 쓰도록 COALESCE 를 사용하여,
--    팀별로 "표시 이름"들을 GROUP_CONCAT 으로 한 줄에 모아 보여주세요.
