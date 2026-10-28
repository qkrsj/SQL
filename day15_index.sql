-- Day 15: 인덱스(INDEX)
-- 목표: 인덱스가 무엇이고 언제 만드는지 이해하고, CREATE INDEX / UNIQUE INDEX / 복합 인덱스를 써본다.

-- 개념 설명
-- 인덱스는 책의 "찾아보기"처럼, 특정 컬럼 값으로 행을 빠르게 찾게 해주는 별도의 자료구조이다.
-- 인덱스가 없으면 DB는 테이블 전체를 처음부터 끝까지 읽는다(풀 스캔).
-- 만드는 법   : CREATE INDEX 인덱스명 ON 테이블(컬럼);
-- 유니크 인덱스: CREATE UNIQUE INDEX ... 는 빠른 검색과 함께 중복 값 입력도 막는다.
-- 복합 인덱스 : 컬럼 여러 개를 묶어 만든다. 왼쪽 컬럼부터 순서대로 쓰일 때 효과가 크다.
--               (dept, city) 인덱스는 dept 단독 조건에도 쓰이지만 city 단독 조건에는 잘 쓰이지 않는다.
-- 언제 만들까 : WHERE, JOIN, ORDER BY에 자주 쓰이고 값의 종류가 다양한 컬럼.
-- 주의        : 인덱스는 INSERT/UPDATE/DELETE를 느리게 하고 저장 공간도 쓰므로 필요한 곳에만 만든다.
--               PRIMARY KEY와 UNIQUE 제약조건은 보통 인덱스가 자동으로 만들어진다.
-- 인덱스를 지울 때 문법이 다르다(SQLite: DROP INDEX 이름; MySQL: DROP INDEX 이름 ON 테이블;).
--   그래서 이 파일은 테이블을 DROP TABLE 하는 방식으로 정리한다(테이블을 지우면 인덱스도 함께 사라진다).
-- 실행 계획 확인: SQLite는 EXPLAIN QUERY PLAN SELECT ...; MySQL은 EXPLAIN SELECT ...;

DROP TABLE IF EXISTS members;

CREATE TABLE members (
    id    INTEGER PRIMARY KEY,
    email VARCHAR(50) NOT NULL,
    name  VARCHAR(30) NOT NULL,
    dept  VARCHAR(20) NOT NULL,
    city  VARCHAR(20) NOT NULL
);

INSERT INTO members (id, email, name, dept, city) VALUES
    (1, 'ha@example.com',   '김하늘', '개발', '서울'),
    (2, 'sea@example.com',  '이바다', '개발', '부산'),
    (3, 'tree@example.com', '박나무', '디자인', '서울'),
    (4, 'cloud@example.com','최구름', '개발', '서울'),
    (5, 'sun@example.com',  '정햇살', '디자인', '대구'),
    (6, 'glow@example.com', '한노을', '기획', '부산');

-- 1) 단일 컬럼 인덱스: city로 자주 검색한다고 가정하고 인덱스를 만든다
CREATE INDEX idx_members_city ON members(city);

-- 2) 인덱스를 만든 뒤에도 쿼리는 똑같이 쓴다. DB가 알아서 인덱스를 사용한다
SELECT name, city FROM members WHERE city = '서울';

-- 3) 유니크 인덱스: email은 중복되면 안 되므로 UNIQUE 인덱스를 만든다
CREATE UNIQUE INDEX idx_members_email ON members(email);

-- 4) 복합 인덱스: dept로 거르고 city까지 함께 조건을 거는 쿼리를 위해 만든다
CREATE INDEX idx_members_dept_city ON members(dept, city);

SELECT name FROM members WHERE dept = '개발' AND city = '서울';

-- 5) ORDER BY에도 인덱스가 도움이 된다
SELECT name, city FROM members ORDER BY city;

-- 6) 아래 INSERT는 email이 중복이라 UNIQUE 인덱스 때문에 오류가 난다 (확인용, 주석 해제해서 실행)
-- INSERT INTO members (id, email, name, dept, city) VALUES (7, 'ha@example.com', '신규', '개발', '서울');

-- 정리: 테이블을 지우면 딸린 인덱스도 함께 사라진다
DROP TABLE members;

-- 연습 문제
-- 1) 아래 테이블 books(id, title, author, year)에서 author로 자주 검색한다.
--    author 컬럼에 idx_books_author 라는 이름의 인덱스를 만들고, author = '박작가'인 책의 title을 조회해 보자.
-- 2) title은 중복되면 안 된다. title에 UNIQUE 인덱스를 만들고, 같은 title을 한 번 더 INSERT해 오류가 나는지 확인해 보자.
-- DROP TABLE IF EXISTS books;
-- CREATE TABLE books (id INTEGER PRIMARY KEY, title VARCHAR(50), author VARCHAR(30), year INTEGER);
-- INSERT INTO books VALUES (1, 'SQL 입문', '박작가', 2020), (2, '데이터 읽기', '김작가', 2021), (3, '쿼리 실전', '박작가', 2022);
