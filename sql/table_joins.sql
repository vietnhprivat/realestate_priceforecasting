/* dagi */
select count(*) from dagi 
where regionskode = '1084'
limit 100;

select id, postnr, postnrnavn, kommunekode, kommunenavn, wgs84koordinat_bredde, wgs84koordinat_længde, betegnelse
from dagi limit 100;

/* bbr */
select * from bbr limit 100;

select adresseIdentificerer, enh020EnhedensAnvendelse, enh026EnhedensSamledeAreal, enh027ArealTilBeboelse, enh031AntalVærelser, enh065AntalVandskylledeToiletter, enh066AntalBadeværelser
from bbr limit 100;


select * from dar limit 100;

/* ebr */
select * from ebr_sample10 limit 100;

select id_lokalid, bestemtFastEjendomBFENr, Ejendomstype, kommuneinddelingKommunekode
from ebr_sample10 limit 100;

/* ois */
select * from ois limit 100;

select id, adresse, bfe, grund_areal, bebygget_areal, vurdering, salgspris
from ois limit 100;

/* join dagi_bbr*/
CREATE TABLE dagi_bbr AS
SELECT
    t1.id,
    t1.postnr,
    t1.postnrnavn,
    t1.kommunekode,
    t1.kommunenavn,
    t1.wgs84koordinat_bredde,
    t1.wgs84koordinat_længde,
    t1.betegnelse,
    t2.adresseIdentificerer,
    t2.enh020EnhedensAnvendelse,
    t2.enh026EnhedensSamledeAreal,
    t2.enh027ArealTilBeboelse,
    t2.enh031AntalVærelser,
    t2.enh065AntalVandskylledeToiletter,
    t2.enh066AntalBadeværelser
FROM
    dagi t1
Left JOIN
    bbr t2
ON
    t1.id = t2.adresseIdentificerer
where t1.regionskode = '1084';

select count(*) from dagi_bbr;

/* ebr_ois */    
create table ebr10_ois
SELECT
    t3.*,
    t4.*
FROM
    ebr_sample10 t3
inner JOIN
    ois t4
ON
    t3.id_lokalid = t4.id;
  
select * from ebr10_ois; 
  
/* ebr_ois on dagi_bbr */    

create table housing_sample10
select
	t1.*,
	t2.id_lokalid,
    t2.adresseLokalId as adresseLokalId_ebr,
    t2.bestemtFastEjendomBFENr, 
    t2.Ejendomstype, 
    t2.kommuneinddelingKommunekode, 
    t2.id as ois_id,
    t2.adresse, 
    t2.bfe, 
    t2.grund_areal, 
    t2.bebygget_areal, 
    t2.vurdering, 
    t2.salgspris, 
    t2.adresseLokalId
from 
	dagi_bbr t1
inner join
	ebr10_ois t2
on
	t1.id = t2.adresseLokalId;

select * from housing_sample10;

/* quick overview*/

UPDATE housing_sample10
SET 
    postnr = NULLIF(postnr, ''),
    postnrnavn = NULLIF(postnrnavn, ''),
    kommunekode = NULLIF(kommunekode, ''),
    kommunenavn = NULLIF(kommunenavn, ''),
    wgs84koordinat_bredde = NULLIF(wgs84koordinat_bredde, ''),
    wgs84koordinat_længde = NULLIF(wgs84koordinat_længde, ''),
    betegnelse = NULLIF(betegnelse, ''),
    adresseIdentificerer = NULLIF(adresseIdentificerer, ''),
    enh020EnhedensAnvendelse = NULLIF(enh020EnhedensAnvendelse, ''),
    enh026EnhedensSamledeAreal = NULLIF(enh026EnhedensSamledeAreal, ''),
    enh027ArealTilBeboelse = NULLIF(enh027ArealTilBeboelse, ''),
    enh031AntalVærelser = NULLIF(enh031AntalVærelser, ''),
    enh065AntalVandskylledeToiletter = NULLIF(enh065AntalVandskylledeToiletter, ''),
    enh066AntalBadeværelser = NULLIF(enh066AntalBadeværelser, ''),
    id_lokalid = NULLIF(id_lokalid, ''),
    adresseLokalId_ebr = NULLIF(adresseLokalId_ebr, ''),
    bestemtFastEjendomBFENr = NULLIF(bestemtFastEjendomBFENr, ''),
    Ejendomstype = NULLIF(Ejendomstype, ''),
    kommuneinddelingKommunekode = NULLIF(kommuneinddelingKommunekode, ''),
    ois_id = NULLIF(ois_id, ''),
    adresse = NULLIF(adresse, ''),
    bfe = NULLIF(bfe, ''),
    grund_areal = NULLIF(grund_areal, ''),
    bebygget_areal = NULLIF(bebygget_areal, ''),
    vurdering = NULLIF(vurdering, ''),
    salgspris = NULLIF(salgspris, ''),
    adresseLokalId = NULLIF(adresseLokalId, '');

SELECT 
    COUNT(CASE WHEN postnr IS NULL THEN 1 END) AS postnr_null_count,
    COUNT(CASE WHEN postnrnavn IS NULL THEN 1 END) AS postnrnavn_null_count,
    COUNT(CASE WHEN kommunekode IS NULL THEN 1 END) AS kommunekode_null_count,
    COUNT(CASE WHEN kommunenavn IS NULL THEN 1 END) AS kommunenavn_null_count,
    COUNT(CASE WHEN wgs84koordinat_bredde IS NULL THEN 1 END) AS wgs84koordinat_bredde_null_count,
    COUNT(CASE WHEN wgs84koordinat_længde IS NULL THEN 1 END) AS wgs84koordinat_længde_null_count,
    COUNT(CASE WHEN betegnelse IS NULL THEN 1 END) AS betegnelse_null_count,
    COUNT(CASE WHEN adresseIdentificerer IS NULL THEN 1 END) AS adresseIdentificerer_null_count,
    COUNT(CASE WHEN enh020EnhedensAnvendelse IS NULL THEN 1 END) AS enh020EnhedensAnvendelse_null_count,
    COUNT(CASE WHEN enh026EnhedensSamledeAreal IS NULL THEN 1 END) AS enh026EnhedensSamledeAreal_null_count,
    COUNT(CASE WHEN enh027ArealTilBeboelse IS NULL THEN 1 END) AS enh027ArealTilBeboelse_null_count,
    COUNT(CASE WHEN enh031AntalVærelser IS NULL THEN 1 END) AS enh031AntalVærelser_null_count,
    COUNT(CASE WHEN enh065AntalVandskylledeToiletter IS NULL THEN 1 END) AS enh065AntalVandskylledeToiletter_null_count,
    COUNT(CASE WHEN enh066AntalBadeværelser IS NULL THEN 1 END) AS enh066AntalBadeværelser_null_count,
    COUNT(CASE WHEN id_lokalid IS NULL THEN 1 END) AS id_lokalid_null_count,
    COUNT(CASE WHEN adresseLokalId_ebr IS NULL THEN 1 END) AS adresseLokalId_ebr_null_count,
    COUNT(CASE WHEN bestemtFastEjendomBFENr IS NULL THEN 1 END) AS bestemtFastEjendomBFENr_null_count,
    COUNT(CASE WHEN Ejendomstype IS NULL THEN 1 END) AS Ejendomstype_null_count,
    COUNT(CASE WHEN kommuneinddelingKommunekode IS NULL THEN 1 END) AS kommuneinddelingKommunekode_null_count,
    COUNT(CASE WHEN ois_id IS NULL THEN 1 END) AS ois_id_null_count,
    COUNT(CASE WHEN adresse IS NULL THEN 1 END) AS adresse_null_count,
    COUNT(CASE WHEN bfe IS NULL THEN 1 END) AS bfe_null_count,
    COUNT(CASE WHEN grund_areal IS NULL THEN 1 END) AS grund_areal_null_count,
    COUNT(CASE WHEN bebygget_areal IS NULL THEN 1 END) AS bebygget_areal_null_count,
    COUNT(CASE WHEN vurdering IS NULL THEN 1 END) AS vurdering_null_count,
    COUNT(CASE WHEN salgspris IS NULL THEN 1 END) AS salgspris_null_count,
    COUNT(CASE WHEN adresseLokalId IS NULL THEN 1 END) AS adresseLokalId_null_count
FROM housing_sample10;

SELECT COUNT(*)
FROM housing_sample10
WHERE 
    postnr IS NOT NULL AND
    postnrnavn IS NOT NULL AND
    kommunekode IS NOT NULL AND
    kommunenavn IS NOT NULL AND
    wgs84koordinat_bredde IS NOT NULL AND
    wgs84koordinat_længde IS NOT NULL AND
    betegnelse IS NOT NULL AND
    adresseIdentificerer IS NOT NULL AND
    enh020EnhedensAnvendelse IS NOT NULL AND
    enh026EnhedensSamledeAreal IS NOT NULL AND
    enh027ArealTilBeboelse IS NOT NULL AND
    enh031AntalVærelser IS NOT NULL AND
    enh065AntalVandskylledeToiletter IS NOT NULL AND
    enh066AntalBadeværelser IS NOT NULL AND
    id_lokalid IS NOT NULL AND
    adresseLokalId_ebr IS NOT NULL AND
    bestemtFastEjendomBFENr IS NOT NULL AND
    Ejendomstype IS NOT NULL AND
    kommuneinddelingKommunekode IS NOT NULL AND
    ois_id IS NOT NULL AND
    adresse IS NOT NULL AND
    bfe IS NOT NULL AND
    grund_areal IS NOT NULL AND
    bebygget_areal IS NOT NULL AND
    salgspris IS NOT NULL AND
    adresseLokalId IS NOT NULL;

select
	id,
    postnr,
    kommuneinddelingKommunekode as kommunekode,
    kommunenavn,
    wgs84koordinat_bredde as koordinat_bredde,
    wgs84koordinat_længde as koordinat_længde,
    enh026EnhedensSamledeAreal as samlede_areal,
    enh027ArealTilBeboelse as beboelses_areal,
    enh031AntalVærelser as værelser,
    enh065AntalVandskylledeToiletter as toiletter,
    enh066AntalBadeværelser as badeværelser,
    Ejendomstype,
    vurdering,
    salgspris,
    adresse
from housing_sample10
order by
	kommunekode, postnr;

-- Step 1: Set 'Loading...' to NULL in the "vurdering" column
UPDATE housing_sample10
SET vurdering = NULL
WHERE vurdering = 'Loading...';

-- Step 2: Set 'Loading...' to NULL in the "salgspris" column
UPDATE housing_sample10
SET salgspris = NULL
WHERE salgspris = 'Loading...';

-- Step 3: Update the original "vurdering" column and handle empty values
UPDATE housing_sample10
SET vurdering = REPLACE(REPLACE(SUBSTRING_INDEX(vurdering, ' (', 1), '.', ''), '.', ''),
    vur_år = NULLIF(SUBSTRING(vurdering, -5, 4), '');

-- Step 4: Update the original "salgspris" column and handle empty values
UPDATE housing_sample10
SET salgspris = REPLACE(REPLACE(SUBSTRING_INDEX(salgspris, ' (', 1), '.', ''), '.', ''),
    salgspris_år = NULLIF(SUBSTRING(salgspris, -5, 4), '');

-- Step 5: Convert the "vurdering" and "salgspris" columns to integers
ALTER TABLE housing_sample10
MODIFY COLUMN vurdering INT;

-- Step 6: Convert the "salgspris" column to BIGINT
ALTER TABLE housing_sample10
MODIFY COLUMN salgspris BIGINT;


SELECT
    COUNT(CASE WHEN id < 0 THEN 1 END) AS count_id,
    COUNT(CASE WHEN postnr < 0 THEN 1 END) AS count_postnr,
    COUNT(CASE WHEN kommuneinddelingKommunekode < 0 THEN 1 END) AS count_kommunekode,
    COUNT(CASE WHEN kommunenavn < 0 THEN 1 END) AS count_kommunenavn,
    COUNT(CASE WHEN wgs84koordinat_bredde < 0 THEN 1 END) AS count_koordinat_bredde,
    COUNT(CASE WHEN wgs84koordinat_længde < 0 THEN 1 END) AS count_koordinat_længde,
    COUNT(CASE WHEN enh026EnhedensSamledeAreal < 0 THEN 1 END) AS count_samlede_areal,
    COUNT(CASE WHEN enh027ArealTilBeboelse < 0 THEN 1 END) AS count_beboelses_areal,
    COUNT(CASE WHEN enh031AntalVærelser < 0 THEN 1 END) AS count_værelser,
    COUNT(CASE WHEN enh065AntalVandskylledeToiletter < 0 THEN 1 END) AS count_toiletter,
    COUNT(CASE WHEN enh066AntalBadeværelser < 0 THEN 1 END) AS count_badeværelser,
    COUNT(CASE WHEN vurdering < 0 THEN 1 END) AS count_vurdering,
    COUNT(CASE WHEN salgspris < 0 THEN 1 END) AS count_salgspris,
    COUNT(CASE WHEN adresse < 0 THEN 1 END) AS count_adresse
FROM housing_sample10;

