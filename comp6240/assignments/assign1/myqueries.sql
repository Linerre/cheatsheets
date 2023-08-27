-- Name: Zhiren Lin
-- Uid:  u7753813

-- Q1
-- TODO: count the result instead of returning it
SELECT COUNT(last_name) FROM person
  WHERE
  year_born > 1974 AND
  last_name LIKE '%e';

-- Q2
