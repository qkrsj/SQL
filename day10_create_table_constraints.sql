-- Day 10: CREATE TABLE, 제약조건 (Constraints)
-- 목표: 테이블을 직접 설계하고, 제약조건으로 잘못된 데이터가 들어오지 않게 막는 방법을 익힌다.

-- 개념 설명
-- CREATE TABLE 테이블명 (컬럼명 자료형 [제약조건], ...) : 새 테이블을 만든다.
-- 자주 쓰는 제약조건
--   PRIMARY KEY : 행을 유일하게 식별하는 키. 중복과 NULL을 허용하지 않는다.
--   NOT NULL    : NULL(값 없음)을 허용하지 않는다.
--   UNIQUE      : 같은 값이 두 번 들어갈 수 없다. (NULL은 DBMS에 따라 여러 개 허용)
--   DEFAULT 값  : 값을 넣지 않았을 때 자동으로 들어갈 기본값.
--   CHECK (조건): 조건을 만족하는 값만 허용한다. (예: 나이는 0 이상)
--   FOREIGN KEY : 다른 테이블의 PRIMARY KEY를 참조해 관계를 보장한다.
-- 참고: SQLite는 FOREIGN KEY를 기본적으로 검사하지 않으므로
--   PRAGMA foreign_keys = ON; 을 먼저 실행해야 한다. (MySQL은 InnoDB에서 기본 동작)
-- 제약조건을 어기는 INSERT/UPDATE는 오류가 나며 실행되지 않는다.
-- 테이블을 지울 때는 DROP TABLE 테이블명; (DROP TABLE IF EXISTS 로 안전하게)

PRAGMA foreign_keys = ON;

-- 1) 부모 테이블: 팀
DROP TABLE IF EXISTS members;
DROP TABLE IF EXISTS teams;

CREATE TABLE teams (
    id   INTEGER PRIMARY KEY,
    name VARCHAR(30) NOT NULL UNIQUE
);

-- 2) 자식 테이블: 팀원 (여러 제약조건을 함께 사용)
CREATE TABLE members (
    id        INTEGER PRIMARY KEY,
    name      VARCHAR(30) NOT NULL,
    email     VARCHAR(50) UNIQUE,
    age       INTEGER CHECK (age >= 0),
    status    VARCHAR(10) NOT NULL DEFAULT 'active',
    team_id   INTEGER,
    FOREIGN KEY (team_id) REFERENCES teams (id)
);

-- 3) 올바른 데이터 삽입
INSERT INTO teams (id, name) VALUES (1, '개발'), (2, '디자인');

INSERT INTO members (id, name, email, age, team_id) VALUES
    (1, '김하늘', 'sky@example.com',  28, 1),
    (2, '이바다', 'sea@example.com',  34, 1),
    (3, '박나무', 'tree@example.com', 25, 2);

-- DEFAULT 확인: status를 넣지 않았지만 'active'로 채워진다
SELECT id, name, status FROM members;

-- JOIN으로 관계 확인
SELECT m.name AS 이름, t.name AS 팀
FROM members m
JOIN teams t ON m.team_id = t.id;

-- 4) 제약조건 위반 예시 (아래 문장은 각각 오류가 나는 것이 정상이다)
-- 실행해 보려면 주석(--)을 지우고 한 줄씩 실행해 보자.
-- INSERT INTO members (id, name) VALUES (1, '중복키');                         -- PRIMARY KEY 중복
-- INSERT INTO members (id, name) VALUES (4, NULL);                              -- NOT NULL 위반
-- INSERT INTO members (id, name, email) VALUES (5, '복사본', 'sky@example.com'); -- UNIQUE 위반
-- INSERT INTO members (id, name, age) VALUES (6, '음수', -1);                   -- CHECK 위반
-- INSERT INTO members (id, name, team_id) VALUES (7, '유령팀', 99);             -- FOREIGN KEY 위반

-- 5) 테이블 구조 변경 (필요할 때)
ALTER TABLE members ADD COLUMN phone VARCHAR(20);
UPDATE members SET phone = '010-1111-2222' WHERE id = 1;
SELECT id, name, phone FROM members;

-- 연습 문제
-- 1) books 테이블을 만들어 보자: id(기본키), title(NOT NULL), isbn(UNIQUE),
--    price(0 이상만 허용), stock(기본값 0). 그다음 책 3권을 INSERT 해 보자.
-- 2) books 테이블에 price가 -100인 행을 넣어 보고, 어떤 오류가 나는지 확인해 보자.
