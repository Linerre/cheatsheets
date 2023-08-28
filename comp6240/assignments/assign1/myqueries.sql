-- Name: Zhiren Lin
-- Uid:  u7753813

-- Q1
SELECT COUNT(last_name) FROM person
  WHERE
  year_born > 1974 AND
  last_name LIKE '%e';

-- Q2
SELECT ROUND(AVG(run_time), 2) FROM
  (
    SELECT DISTINCT
    restriction.title,
    restriction.production_year,
    description,
    restriction.country,
    run_time
    FROM restriction, movie
    WHERE
    restriction.country = 'USA' AND
    restriction.description = 'R' AND
    restriction.production_year > 1991
  ) AS mv;

-- Q3
