select count(*) from ois where Matrikel_ejerlav is null;
select * from ois;
SELECT count(*)
FROM ebr_sample10 
WHERE ois = false; 

ALTER TABLE bbr DROP COLUMN `index`;



SELECT id_lokalid, bestemtFastEjendomBFENr, part FROM ebr_sample10 WHERE ois = false AND part IN (1, 10, 8, 6, 4) limit 100;

SELECT count(*)
FROM ebr_sample10 
WHERE ois = false 
AND part IN (2, 9, 7, 5, 3);


select count(*) from ebr_sample10 where ois = false;

select * from ebr;


select id_lokalid, bestemtFastEjendomBFENr, ois, part from ebr_sample
where ois = false and part = 1;

CREATE TABLE ois (
  id varchar(200),
  Adresse VARCHAR(200),
  BFE INT,
  Matrikel_ejerlav VARCHAR(200),
  Grund_areal VARCHAR(200),
  Bebygget_areal VARCHAR(200),
  Byggesager VARCHAR(200),
  Admininistrator VARCHAR(200),
  Ejer VARCHAR(200),
  Vurdering VARCHAR(200),
  Salgspris VARCHAR(200)
);

ALTER TABLE ois 
CHANGE Admininistrator Administrator VARCHAR(200);

SELECT
  e.kommuneinddelingKommunekode,
  COUNT(*) AS count,
  (COUNT(*) / total.total_count) * 100 AS percentage
FROM
  ebr e
CROSS JOIN
  (SELECT COUNT(*) AS total_count FROM ebr) AS total
GROUP BY
  e.kommuneinddelingKommunekode, total.total_count;


UPDATE ebr_sample10
SET ois = false
WHERE bestemtFastEjendomBFENr IN (
    SELECT o.BFE
    FROM ois o
    WHERE o.Matrikel_ejerlav = 'Loading...'
);





select * from ois