-- Day 38: 중앙값과 최빈값
-- 목표: AVG로는 알 수 없는 중앙값(median)과 최빈값(mode)을 윈도우 함수와 GROUP BY로 구한다.

-- 개념 설명
--   평균(AVG)   : 극단값(아주 큰 값)에 크게 흔들린다.
--   중앙값      : 값을 정렬했을 때 가운데 값. 극단값에 강하다. 짝수 개면 가운데 두 값의 평균.
--   최빈값      : 가장 자주 나온 값. GROUP BY + COUNT(*) 로 센 뒤 가장 큰 횟수를 고른다.
--   중앙값 공식 : ROW_NUMBER() 로 순번(rn), COUNT(*) OVER () 로 전체 개수(cnt)를 구한 뒤
--                 rn 이 (cnt + 1) / 2 와 (cnt + 2) / 2 인 행만 평균 낸다. (정수 나눗셈 사용)
--                 홀수 개(5) : (5+1)/2 = 3, (5+2)/2 = 3 -> 3번째 값 하나
--                 짝수 개(6) : (6+1)/2 = 3, (6+2)/2 = 4 -> 3, 4번째 값의 평균
--   주의: MySQL 8.0 / SQLite 3.25 이상에서 윈도우 함수를 쓸 수 있다.
--         최빈값은 동점이 여러 개일 수 있으므로 서브쿼리로 최대 횟수를 비교하면 모두 조회된다.

DROP TABLE IF EXISTS salaries;
DROP TABLE IF EXISTS survey;

CREATE TABLE salaries (
    id     INTEGER PRIMARY KEY,
    name   VARCHAR(20) NOT NULL,
    dept   VARCHAR(20) NOT NULL,
    salary INTEGER NOT NULL
);

CREATE TABLE survey (
    id    INTEGER PRIMARY KEY,
    score INTEGER NOT NULL
);

INSERT INTO salaries (id, name, dept, salary) VALUES
    (1, '민수', '개발', 3000), (2, '지영', '개발', 3200), (3, '철수', '개발', 3500),
    (4, '영희', '개발', 3800), (5, '대표', '개발', 20000),
    (6, '수진', '영업', 2800), (7, '현우', '영업', 3000),
    (8, '다은', '영업', 3400), (9, '준호', '영업', 4000);

INSERT INTO survey (id, score) VALUES
    (1, 5), (2, 4), (3, 4), (4, 3), (5, 5), (6, 4), (7, 5), (8, 2), (9, 1);

-- 1) 평균과 중앙값 비교 전: 평균은 대표 한 명 때문에 크게 올라간다
SELECT AVG(salary) AS avg_salary FROM salaries;

-- 2) 전체 중앙값: 9명이므로 5번째 값 하나가 중앙값이다
SELECT AVG(salary) AS median_salary
FROM (
    SELECT salary,
           ROW_NUMBER() OVER (ORDER BY salary) AS rn,
           COUNT(*) OVER ()                    AS cnt
    FROM salaries
) t
WHERE rn IN ((cnt + 1) / 2, (cnt + 2) / 2);

-- 3) 부서별 중앙값: 개발(5명, 홀수) / 영업(4명, 짝수)
SELECT dept, AVG(salary) AS median_salary
FROM (
    SELECT dept, salary,
           ROW_NUMBER() OVER (PARTITION BY dept ORDER BY salary) AS rn,
           COUNT(*)     OVER (PARTITION BY dept)                 AS cnt
    FROM salaries
) t
WHERE rn IN ((cnt + 1) / 2, (cnt + 2) / 2)
GROUP BY dept
ORDER BY dept;

-- 4) 최빈값: 점수별 응답 수를 센 뒤, 가장 많은 횟수와 같은 점수만 조회
SELECT score, COUNT(*) AS cnt
FROM survey
GROUP BY score
HAVING COUNT(*) = (
    SELECT MAX(c)
    FROM (SELECT COUNT(*) AS c FROM survey GROUP BY score) x
);

-- 5) 평균 · 중앙값 · 최빈값을 한 번에 보기 (설문 점수)
SELECT
    (SELECT AVG(score) FROM survey) AS avg_score,
    (SELECT AVG(score)
       FROM (SELECT score,
                    ROW_NUMBER() OVER (ORDER BY score) AS rn,
                    COUNT(*) OVER ()                   AS cnt
             FROM survey) t
      WHERE rn IN ((cnt + 1) / 2, (cnt + 2) / 2)) AS median_score;

-- 연습 문제
-- 문제 1) salaries에서 '영업' 부서만 대상으로 평균과 중앙값을 각각 구해 보세요.
-- 문제 2) survey에 (10, 2), (11, 2) 행을 추가한 뒤 최빈값 쿼리를 다시 실행해 보세요.
--        최빈값이 몇 개가 되고, 각각 몇 번씩 나오는지 확인해 보세요.
