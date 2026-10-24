-- Day 11: CASE WHEN (조건 분기)
-- 목표: 쿼리 안에서 조건에 따라 다른 값을 돌려주는 CASE WHEN 사용법을 익힌다.

-- 개념 설명
-- CASE WHEN 조건1 THEN 값1
--      WHEN 조건2 THEN 값2
--      ELSE 기본값
-- END
--   : 위에서부터 조건을 차례로 검사해 처음 참인 THEN 값을 반환한다.
--   : ELSE를 생략하면 어떤 조건도 맞지 않을 때 NULL이 반환된다.
-- 활용 위치: SELECT(새 컬럼 만들기), ORDER BY(사용자 지정 정렬), 집계 함수 안(조건부 집계)
-- 일반적으로 컬럼 별칭(AS)을 붙여 결과를 읽기 쉽게 만든다.

DROP TABLE IF EXISTS scores;

CREATE TABLE scores (
    id      INTEGER PRIMARY KEY,
    name    VARCHAR(30) NOT NULL,
    subject VARCHAR(20) NOT NULL,
    score   INTEGER NOT NULL
);

INSERT INTO scores (id, name, subject, score) VALUES
    (1, '김하늘', '수학', 95),
    (2, '김하늘', '영어', 82),
    (3, '이바다', '수학', 68),
    (4, '이바다', '영어', 74),
    (5, '박나무', '수학', 55),
    (6, '박나무', '영어', 91),
    (7, '최구름', '수학', 100),
    (8, '최구름', '영어', 47);

-- 1) 점수를 등급으로 바꾸기
SELECT name AS 이름, subject AS 과목, score AS 점수,
       CASE
           WHEN score >= 90 THEN 'A'
           WHEN score >= 80 THEN 'B'
           WHEN score >= 70 THEN 'C'
           ELSE 'F'
       END AS 등급
FROM scores;

-- 2) 합격/불합격 표시 (60점 이상 합격)
SELECT name, subject, score,
       CASE WHEN score >= 60 THEN '합격' ELSE '불합격' END AS 결과
FROM scores;

-- 3) 조건부 집계: 학생별로 수학/영어 점수를 한 줄에 펼치기
SELECT name AS 이름,
       SUM(CASE WHEN subject = '수학' THEN score ELSE 0 END) AS 수학,
       SUM(CASE WHEN subject = '영어' THEN score ELSE 0 END) AS 영어
FROM scores
GROUP BY name;

-- 4) 조건부 개수 세기: 과목별 합격자 수
SELECT subject AS 과목,
       COUNT(*) AS 응시자,
       SUM(CASE WHEN score >= 60 THEN 1 ELSE 0 END) AS 합격자
FROM scores
GROUP BY subject;

-- 5) ORDER BY에서 사용: '영어'를 먼저, 그다음 '수학' 순서로, 같은 과목은 점수 높은 순
SELECT subject, name, score
FROM scores
ORDER BY CASE subject WHEN '영어' THEN 1 ELSE 2 END, score DESC;

-- 연습 문제
-- 1) scores에서 점수가 80 이상이면 '우수', 60 이상 80 미만이면 '보통', 그 외는 '노력 필요'로 표시하는 '평가' 컬럼을 만들어 보자.
-- 2) 학생별 평균 점수를 구하고, 평균이 70 이상이면 '통과', 아니면 '재시험'을 보여 주는 쿼리를 작성해 보자. (힌트: GROUP BY와 CASE WHEN 함께 사용)
