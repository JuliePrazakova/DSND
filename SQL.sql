-- SQL FILE --

--------------------------------------------------------------------------------
-- 5. CVIKA
--------------------------------------------------------------------------------

-- synonyma
CREATE SYNONYM lide FOR c##schuzky.lide;
CREATE SYNONYM bydliste FOR c##schuzky.bydliste;
CREATE SYNONYM lide_schuzky FOR c##schuzky.lide_schuzky;
CREATE SYNONYM kontakty FOR c##schuzky.kontakty;
CREATE SYNONYM typy_kontaktu FOR c##schuzky.typy_kontaktu;
CREATE SYNONYM typy_vztahu FOR c##schuzky.typy_vztahu;
CREATE SYNONYM vztahy FOR c##schuzky.vztahy;
CREATE SYNONYM schuzky FOR c##schuzky.schuzky;

-- 1. Vypište jména a příjmení všech lidí, kteří jsou vyšší než 170.
SELECT jmeno, prijmeni FROM lide WHERE vyska > 170;

-- 2. Seznam adres (ulice a číslo domu), které se nacházejí v Pardubicích.
SELECT ulice, cislo_domu FROM bydliste WHERE mesto ='Pardubice';

-- 3. Vypište jméno, příjemní a datum narození všech lidí ve formátu např. úterý 7. března 23.
SELECT jmeno, prijmeni, to_char(datum_narozeni, 'DAY DD. MONTH YY') as datum_narozeni
FROM lide;

-- 4. Vypište ulici, číslo domu a město všech adres, kde číslo domu je liché nebo je dělitelné dvěma beze zbytku.
SELECT ulice, cislo_domu, mesto FROM bydliste;

-- 5. Vypište místa, kde se v listopadu konalanějaká schůzka.
SELECT misto FROM schuzky WHERE EXTRACT(MONTH FROM datum) = 11;

-- 6. Vypište přezdívku lidí, kteří neuvedli výšku.
SELECT prezdivka FROM lide WHERE vyska IS NULL;

-- 7. Pro všechny lidi určete jejich věk a seřaďte je od nejstaršího
----> sysdate = systemove datum
SELECT jmeno, TRUNC(MONTHS_BETWEEN(SYSDATE, datum_narozeni)/12) AS vek
FROM lide
ORDER BY vek DESC;

--------------------------------------------------------------------------------
-- 6. CVIKA
--------------------------------------------------------------------------------

CREATE SYNONYM zamestnanci FOR c##prodejny.zamestnanci;
CREATE SYNONYM oddeleni FOR c##prodejny.oddeleni;
CREATE SYNONYM pobocky FOR c##prodejny.pobocky;
CREATE SYNONYM pracovni_pozice FOR c##prodejny.pracovni_pozice;
CREATE SYNONYM nabidky FOR c##prodejny.nabidky;
CREATE SYNONYM prodeje FOR c##prodejny.prodeje;
CREATE SYNONYM polozky_prodeje FOR c##prodejny.polozky_prodeje;
CREATE SYNONYM svetadily FOR c##prodejny.svetadily;
CREATE SYNONYM zeme FOR c##prodejny.zeme;
CREATE SYNONYM produkty FOR c##prodejny.produkty;
CREATE SYNONYM producenti FOR c##prodejny.producenti;

--------------------------------------------------------------------------------
-- NOVE VECI

-- 2. nazev, (minplat + maxplat)/ 2 FROM pracovni_pozice
        -- pro vypocitani nejakeho vyrazu / pro praci s datumy pouzivame tabulku DUAL
SELECT vyraz FROM dual -- musi byt bez mocnin

-- 3. spojovaci operator || = ze dvou sloupcu bude jeden na vystupu
SELECT id_oddeleni || '-' || nazev FROM oddeleni

-- 4. aliasy = libovolne pojmenovani sloupcu na vystup
             -- pokud nazev neobsahuje nic special ani mezeru, tak pohoda, pokud ano tak musi byt v uvozovkach "A lias"
SELECT jmeno || prijmeni AS "jmena zamestnancu" FROM zamstnanci --> JuliePrazakova

-- 5. distinct - pouze unikatni vysledky
SELECT DISTINCT id_oddeleni FROM zamestnanci 
SELECT DISTINCT vedouci FROM oddeleni

-- 6. IN, LIKE 
SELECT * FROM zamestnanci WHERE datum_nastupu BETWEEN 2.1.2007 AND 9. 7. 2008;
SELECT prijmeni FROM zamestnanci WHERE prijmeni LIKE '_o%k';
SELECT * FROM zamestnanci WHERE id_oddeleni IN (10,15,23);
SELECT jmeno, prijmeni FROM zamestnanci WHERE nadrizeny IS NULL;

--------------------------------------------------------------------------------
-- PRIKLADY 6. CVIKO

-- 1. Vypište adresu poboček, které mají orientační číslo dělitelné pěti beze zbytku.
SELECT nazev FROM zeme WHERE nazev LIKE 'K%a%';

-- 2.: Vypište adresu poboček, které mají orientační číslo dělitelné pěti beze zbytku.
SELECT ulice FROM pobocky WHERE MOD(psc, 5)=0;

-- 3.: Vypište unikátní názvy oddělení, kteréobsahují 's' nebo 'e'
SELECT DISTINCT nazev FROM oddeleni WHERE (na zev LIKE '%s%' OR nazev LIKE '%e%');

-- 4. Vypište datum prodeje ve tvaru den v týdnu den v měsíci. měsíc slovy a poslední dvě čísliceroku (např. úterý 11. únor 14), kdy bylproveden nákup s celkovou mezi 7000 a 7500.
SELECT to_char(cas_prodeje, 'day dd.month yy') FROM prodeje WHERE cena_celkem BETWEEN 7000 AND 7500;

-- 5. Vypište název producentů, kteří nemají uvedený telefonní kontakt.
SELECT nazev FROM producenti WHERE telefon IS NULL;

-- 6.: Vypište název a telefonní spojení producentů, kde kontaktní osoba se křestním jménem jmenuje 'Anna' .
SELECT nazev, telefon FROM producenti WHERE kontaktni_osoba LIKE 'Anna%';

-- 7. Vypište datum všech prodejů a jejich celkovou cenu a počet prodaných kusů, kde se produkt 'Rohlík tukový' od firmy 'Pekárny Dvorák' prodal alespoň po čtyřech kusech. Celkovou cenu zarovnejte doprava a zaokrouhlete na stovky a vypište na 10 platných cifer a před jako první znak vypište dolar. Datum vypište podle příkladu: čtrnáctý led 09. Sloupce pojmenujte datum a cena.
SELECT to_char(cas_prodeje,'Ddspth mon YY') AS datum,
'$'||LPAD(ROUND(cena_celkem,-2),10,' ') AS cena
FROM producenti
JOIN produkty USING(id_producenti)
JOIN polozky_prodeje USING(id_produkty)
JOIN prodeje USING(id_prodeje)
WHERE produkty.nazev='Rohlík tukový' AND producenti.nazev='Pekárny Dvořák' AND pocet_kusu>=4;

-- 8.: Vypište názvy produktů a jejich pořizovací cenu, jejichž pořizovací cena je celé číslo.
SELECT * FROM produkty WHERE FLOOR(porizovaci_cena)=porizovaci_cena;

-- 9: Odkdy dokdy byly v oddělení potravin napobočce Brno 2 nabízeny produkt(y) dražší než500.
SELECT platnost_od, platnost_do FROM nabidky 
JOIN oddeleni USING(id_oddeleni) 
JOIN pobocky USING(id_pobocky)
WHERE oddeleni.nazev LIKE 'potraviny'
AND nabidky.cena > 500
AND pobocky.nazev LIKE 'Brno 2';

-- 10. Vypište maximální, minimální a průměrný plat všech zaměstnanců a celkové mzdové náklady (zaokrouhlený na dvě desetinná místa).
-- Sloupce pojmenujte odpovídajícím způsobem. Mezi řády tisíců udělejte čárku.
SELECT MAX(plat) as maximalni, MIN(plat) as minimalni, 
(MAX(plat)+MIN(plat))/2 as prumerny, ROUND(SUM(plat),2) as "celkove mzdove naklady"
FROM zamestnanci;

-- 11. Vypište v kolika zemích se vyrábí nějaký produkt. = unikatne pocet id_zeme
SELECT count(DISTINCT id_zeme) FROM produkty;

-- 12. - kolik mesicu jsem na svete :(((
SELECT MONTHS_BETWEEN('02-Nov-2000', '22-Mar-2023') FROM DUAL;

-- 13. Vypište jakým dnem (myšleno,pondělí, úterý, ...) končí aktuální měsíc
SELECT TO_CHAR(DATE '2023-03-31', 'DAY')
FROM DUAL;

SELECT to_char(LAST_DAY(SYSDATE), 'day') as "posledni den" FROM DUAL;

-- 14. Vypište datum první neděle roku 2015.
SELECT TO_CHAR(DATE '2023-03-31', 'DAY')
FROM DUAL;


SELECT to_char(NEXT_DATE(
to_date('31.12.2014'), 'dd.mm.yyyy'), 'sunday'),
    'dd. month') as "prvni nedele"
FROM dual;

-- 15. Ze jména a příjmení vytvořte login ve tvaru první písmeno křestního jména a prvních pět
-- znaků příjmení vše malými písmeny. Loginy vytvořte tak, aby se v nich nevyskytovala diakritika.
SELECT translate(
    lower(substr(jmeno,1,1)||substr(prijmeni,1,5)),
    'ěščřžýáíé',
    'escrzyaie' ) as login
    FROM zamestnanci;

--------------------------------------------------------------------------------
-- 7. CVIKO
--------------------------------------------------------------------------------

-- 1. Vypište jména a příjmení zaměstnanců s nejvyšším počtem nadřízených.
SELECT z.jmeno, z.prijmeni, NVL(n.prijmeni, 'bez nadřízeného')
FROM zamestnanci z
LEFT JOIN zamestnanci n ON (z.nadrizeny = n.id_zamestnanci)
WHERE z.plat > (SELECT avg(plat) FROM zamestnanci)
ORDER BY z.prijmeni, z.jmeno;

-- 3. Vypište názvy prvních deseti neprodávanějších produktů na pobočce Brno 1
-- od 9. 2. do 17. 2. 2014 včetně pořadí.
SELECT ROWNUM ||'.' poradi, nazev, pocet
FROM (SELECT * FROM
    (SELECT id_produkty, sum(pocet_kusu) pocet
     FROM polozky_prodeje
        JOIN prodeje USING (id_prodeje)
        JOIN pobocky USING(id_pobocky)
     WHERE pobocky.nazev='Brno 1' AND trunc(cas_prodeje)
       BETWEEN to_date('09.02.14','dd.mm.yy') AND to_date('17.02.14','dd.mm.yy')
     GROUP BY id_produkty
    )
    JOIN produkty USING (id_produkty)
    ORDER BY pocet DESC)
WHERE ROWNUM<=10;

-- 4.  Vypište pět dnů s nejnižším obratem.
SELECT TO_CHAR(cas_prodeje, 'yy-mm-dd'), SUM(cena_celkem)
FROM prodeje
    GROUP BY (TO_CHAR(cas_prodeje, 'yy-mm-dd'))
    ORDER BY (SUM(cena_celkem)) ASC
FETCH FIRST 5 ROWS ONLY;

WITH produc AS(
    SELECT id_producenti, sum(pocet_kusu)
    FROM polozky_prodeje
    NATURAL JOIN produkty
        JOIN producenti USING (id_producenti)
    GROUP BY id_producenti
    ORDER BY sum(pocet_kusu) DESC);
   
-- 7. Vypište názvy a zemi původu všech asijských produktů, které vyrobili
-- producenti, kteří patřili mezi tři nejúspěšnějších producentů z hlediska
-- počtu prodaných kusů.   
SELECT id_produkty, produkty.nazev produkt, zeme.nazev "země"
FROM  (
    SELECT * FROM produc
        WHERE ROWNUM <=3)
    JOIN produkty USING (id_producenti)
    JOIN zeme USING (id_zeme)
    JOIN svetadily USING (id_svetadily)
WHERE svetadily.nazev = 'Asie';

-- 8. Vypište názvy, zemi původu a název producenta všech neasijských produktů,
-- které vyrobili producenti, kteří patřili mezi tři nejúspěšnější producenty z hlediska tržeb.
WITH produc AS(
    SELECT id_producenti, sum(pocet_kusu*cena) trzba
    FROM polozky_prodeje
        JOIN produkty ON (polozky_prodeje.id_produkty = produkty.id_produkty)
        JOIN producenti USING (id_producenti)
        JOIN prodeje USING (id_prodeje)
        JOIN pobocky USING (id_pobocky)
        JOIN oddeleni USING (id_pobocky) -- produkt se musi nachazet na nejakem oddeleni a pobocce abychom overili ze je fakt v nabidce
        JOIN nabidky ON(oddeleni.id_oddeleni = nabidky.id_oddeleni AND TRUNC(cas_prodeje) BETWEEN platnost_od AND platnost_do AND nabidky.id_produkty=produkty.id_produkty)
        -- primarni klic nabidek je slozeny ze 2 klicu, musime overit id_oddeleni i id_produkty
GROUP BY id_producenti
ORDER BY sum(pocet_kusu*cena) DESC)
    
SELECT produkty.nazev produkt, producenti.nazev producenti, zeme.nazev "země původu"
    FROM (SELECT * FROM produc WHERE ROWNUM<=3)
        NATURAL JOIN produkty
        JOIN zeme USING(id_zeme)
        JOIN svetadily USING(id_svetadily)
        JOIN producenti USING(id_producenti)
WHERE svetadily.nazev != 'Asie';

-- 9. Vypište pořadí českých produktů (název produktu, producent, pořizovací cena, zisk), podle výše zisku, který přinesly.
WITH zisky AS(
  SELECT produkty.id_produkty,
         sum(pocet_kusu*(cena-porizovaci_cena)) zisk
  FROM polozky_prodeje 
   JOIN produkty ON (polozky_prodeje.id_produkty = produkty.id_produkty)
   JOIN producenti USING (id_producenti) 
   JOIN prodeje USING (id_prodeje) 
   JOIN pobocky USING(id_pobocky) 
   JOIN oddeleni USING(id_pobocky) 
   JOIN nabidky ON (oddeleni.id_oddeleni=nabidky.id_oddeleni
        AND trunc(cas_prodeje) BETWEEN platnost_od AND platnost_do 
        AND nabidky.id_produkty= produkty.id_produkty)
   JOIN zeme USING(id_zeme)
    WHERE zeme.nazev='Česká republika'
  GROUP BY produkty.id_produkty
)

SELECT ROWNUM "pořadí",produkt,producent, porizovaci_cena, to_char(zisk,'999999.99') 
FROM
(SELECT produkty.nazev produkt, producenti.nazev
    producent, porizovaci_cena,  zisk
FROM zisky JOIN produkty USING(id_produkty)  JOIN
     producenti USING (id_producenti)
ORDER BY zisk DESC);

-- az budu importovat projekt tak opravdu naimportovat vsechny zaznamy
-- importovat od tabulek ktere nemaji zadne zavislosti
 
 
-- Vypište 10 evropských produktů, které přinesly nejvyšší zisk hodonínské pobočce.
-- nenechala nas si opsat kod :) takze vim uplnou picu.
WITH zisky AS(
  SELECT produkty.id_produkty,
         sum(pocet_kusu*(cena-porizovaci_cena)) zisk
  FROM polozky_prodeje 
   JOIN produkty ON (polozky_prodeje.id_produkty = produkty.id_produkty)
   JOIN producenti USING (id_producenti) 
   JOIN prodeje USING (id_prodeje) 
   JOIN pobocky USING(id_pobocky) 
   JOIN oddeleni USING(id_pobocky) 
   JOIN nabidky ON (oddeleni.id_oddeleni=nabidky.id_oddeleni
        AND trunc(cas_prodeje) BETWEEN platnost_od AND platnost_do 
        AND nabidky.id_produkty= produkty.id_produkty)
   JOIN svetadily USING(id_svetadily) 
    WHERE svetadily.nazev='Evropa' AND pobocky.mesto='Hodinín'
  GROUP BY produkty.id_produkty
  ORDER BY sum(pocet_kusu*(cena-porizovaci_cena)) DESC
)

SELECT por, produkty.nazev produkt, producenti.nazev producent, zisk
FROM (SELECT ROWNUM por, id_produkty, zisk
FROM zisky WHERE ROWNUM<=10)
FROM
(SELECT produkty.nazev produkt
FROM zisky JOIN produkty USING(id_produkty) 
    JOIN producenti USING (id_producenti)
ORDER BY por;
    

-- 10. Sestavte pro producenty, kteří vyrobili nějaký produkt v České republice, Německu, Slovensku,
-- Maďarsku nebo Finsku kontingenční tabulku, ze které bude patrné, kolik různých produktu v dané zemi vyrobili.
-- KONTINGENCNI TABULKA
WITH prehlad AS(
    SELECT producenti.nazev producent, zeme.nazev zeme 
    FROM zeme
        JOIN produkty USING(id_zeme)
        JOIN producenti USING(id_producenti)
        
    WHERE zeme.nazev IN ('Česká republika', 'Slovensko', 'Finsko', 'Maďarsko','Německo')
)

SELECT * FROM 
(
    SELECT producent, zeme 
    FROM prehlad
)
PIVOT 
(
    COUNT(zeme)
        for zeme IN ('Česká republika', 'Slovensko', 'Finsko', 'Maďarsko','Německo')
)
ORDER BY producent;

--------------------------------------------------------------------------------
-- 8. CVIKO
--------------------------------------------------------------------------------

-- 3. Vytvořte pohled (starsi30), který umožní přístup jen k osobám starším třiceti let.
CREATE OR REPLACE VIEW starsi30 AS SELECT * FROM osoby WHERE vek>30;

-- 4. Vložte pomocí pohledu starsi30 vložte třiadvacetiletou studentku z Prahy i id 1000.
INSERT INTO starsi30(osoby_id, kraje_id, povolani_id, vek, pohlavi) VALUES (1000, 1, 4, 23, 'žena') 


-- 5. Ověřte, zda se do pohledu starsi30 vložila?
SELECT * FROM starsi30 WHERE osoby_id=1000;

-- 6. Ověřte, zda se nachází v osobách.
SELECT * FROM osoby WHERE osoby_id=1000;

-- 7. Jak je možné, že se do tabulky osobyvložila, i když jí ještě nebylo třicet?
-- nemame tam WITH CHECK OPTION

-- 8. Upravte pohled tak, abyste nemohli vkládat jiná data,než pohled zobrazuje.
CREATE OR REPLACE VIEW starsi30 AS SELECT * FROM osoby WHERE vek>30 WITH CHECK OPTION;

-- 9. Pokuste se nyní vložit osobu mladší třiceti let.
INSERT INTO starsi30(osoby_id, kraje_id, povolani_id, vek, pohlavi) VALUES (1000, 1, 4, 23, 'žena') 

-- 10. Vložte osobu starší než 30 let.
INSERT INTO starsi30(osoby_id, kraje_id, povolani_id, vek, pohlavi) VALUES (1005, 1, 4, 89, 'žena')

-- 11. Smažte prostřednictvím pohledu přidané osoby.
DELETE FROM starsi30 WHERE osoby_id=1005

-- 12. Přetvořte pohled tak, aby jeho prostřednictvím nešlo provádět žádné DML operace.
CREATE OR REPLACE VIEW starsi30 AS SELECT * FROM osoby WHERE vek>30 WITH READ ONLY;

-- 13. Otestujte, zda se to podařilo.
INSERT INTO starsi30(osoby_id, kraje_id, povolani_id, vek, pohlavi) VALUES (1005, 1, 4, 89, 'žena') -- => VYHODI ERROR

-- 14. tabulky nemaji povolene nullove hodnoty = je tam jen JOIN (bez LEFT)
--     Vytvořte pohled, který bude zobrazovat kompletně vyplněné dotazníky ve formě:
--     informace o osobě, odpověď1, ... odpověď12. v odpovedich jsou jen 3 ID. + tabulka text => potrebujeme text odpovedi a proto pouzijeme moznosti_ID
CREATE or REPLACE VIEW dotaznik1(osoba, vek, pohlavi, vyska, 
vaha, prijem, povolani, kraj, otazka1, otazka2, 
otazka3, otazka4, otazka5, otazka6, otazka7, 
otazka8, otazka9, otazka10, otazka11, otazka12)
AS
SELECT osoby_id, vek, pohlavi, vyska, vaha, prijem, povolani.nazev, kraje.nazev, o1.text,  o2.text,  o3.text, o4.text, o5.text, o6.text, o7.text, o8.text, o9.text, o10.text, o11.text, o12.text
FROM osoby NATURAL JOIN
    kraje 
    JOIN povolani USING(povolani_id)
    JOIN (SELECT text,osoby_id FROM odpovedi JOIN moznosti USING(moznosti_id) WHERE otazky_id=1)o1 USING(osoby_id)
    JOIN (SELECT text,osoby_id FROM odpovedi JOIN moznosti USING(moznosti_id) WHERE otazky_id=2)o2 USING(osoby_id)
    JOIN (SELECT text,osoby_id FROM odpovedi JOIN moznosti USING(moznosti_id) WHERE otazky_id=3)o3 USING(osoby_id)
    JOIN (SELECT text,osoby_id FROM odpovedi JOIN moznosti USING(moznosti_id) WHERE otazky_id=4)o4 USING(osoby_id)
    JOIN (SELECT text,osoby_id FROM odpovedi JOIN moznosti USING(moznosti_id) WHERE otazky_id=5)o5 USING(osoby_id)
    JOIN (SELECT text,osoby_id FROM odpovedi JOIN moznosti USING(moznosti_id) WHERE otazky_id=6)o6 USING(osoby_id)
    JOIN (SELECT text,osoby_id FROM odpovedi JOIN moznosti USING(moznosti_id) WHERE otazky_id=7)o7 USING(osoby_id)
    JOIN (SELECT text,osoby_id FROM odpovedi JOIN moznosti USING(moznosti_id) WHERE otazky_id=8)o8 USING(osoby_id)
    JOIN (SELECT text,osoby_id FROM odpovedi JOIN moznosti USING(moznosti_id) WHERE otazky_id=9)o9 USING(osoby_id)
    JOIN (SELECT text,osoby_id FROM odpovedi JOIN moznosti USING(moznosti_id) WHERE otazky_id=10)o10 USING(osoby_id)
    JOIN (SELECT text,osoby_id FROM odpovedi JOIN moznosti USING(moznosti_id) WHERE otazky_id=11)o11 USING(osoby_id)
    JOIN (SELECT text,osoby_id FROM odpovedi JOIN moznosti USING(moznosti_id) WHERE otazky_id=12)o12 USING(osoby_id)


SELECT * FROM dotaznik1


-- 15. Vytvořte pohled, který bude zobrazovat vyplněné dotazníky (včetně těch jen
--     částečně vyplněných) ve formě: informace o osobě, odpověď1, ... odpověď12.
--     LEFT JOIN = budou tam nullove hodnoty
--     u projektu pokud nam u jednoho dotazu nevyjde odpoved tak bude odpoved NULL
CREATE or REPLACE VIEW dotaznik2(osoba, vek, pohlavi, vyska, 
vaha, prijem, povolani, kraj, otazka1, otazka2, 
otazka3, otazka4, otazka5, otazka6, otazka7, 
otazka8, otazka9, otazka10, otazka11, otazka12)
AS
SELECT osoby_id, vek, pohlavi, vyska, vaha, prijem, povolani.nazev, kraje.nazev, o1.text,  o2.text,  o3.text, o4.text, o5.text, o6.text, o7.text, o8.text, o9.text, o10.text, o11.text, o12.text
FROM osoby NATURAL JOIN
    kraje 
    JOIN povolani USING(povolani_id)
    LEFT JOIN (SELECT text,osoby_id FROM odpovedi JOIN moznosti USING(moznosti_id) WHERE otazky_id=1)o1 USING(osoby_id)
    LEFT JOIN (SELECT text,osoby_id FROM odpovedi JOIN moznosti USING(moznosti_id) WHERE otazky_id=2)o2 USING(osoby_id)
    LEFT JOIN (SELECT text,osoby_id FROM odpovedi JOIN moznosti USING(moznosti_id) WHERE otazky_id=3)o3 USING(osoby_id)
    LEFT JOIN (SELECT text,osoby_id FROM odpovedi JOIN moznosti USING(moznosti_id) WHERE otazky_id=4)o4 USING(osoby_id)
    LEFT JOIN (SELECT text,osoby_id FROM odpovedi JOIN moznosti USING(moznosti_id) WHERE otazky_id=5)o5 USING(osoby_id)
    LEFT JOIN (SELECT text,osoby_id FROM odpovedi JOIN moznosti USING(moznosti_id) WHERE otazky_id=6)o6 USING(osoby_id)
    LEFT JOIN (SELECT text,osoby_id FROM odpovedi JOIN moznosti USING(moznosti_id) WHERE otazky_id=7)o7 USING(osoby_id)
    LEFT JOIN (SELECT text,osoby_id FROM odpovedi JOIN moznosti USING(moznosti_id) WHERE otazky_id=8)o8 USING(osoby_id)
    LEFT JOIN (SELECT text,osoby_id FROM odpovedi JOIN moznosti USING(moznosti_id) WHERE otazky_id=9)o9 USING(osoby_id)
    LEFT JOIN (SELECT text,osoby_id FROM odpovedi JOIN moznosti USING(moznosti_id) WHERE otazky_id=10)o10 USING(osoby_id)
    LEFT JOIN (SELECT text,osoby_id FROM odpovedi JOIN moznosti USING(moznosti_id) WHERE otazky_id=11)o11 USING(osoby_id)
    LEFT JOIN (SELECT text,osoby_id FROM odpovedi JOIN moznosti USING(moznosti_id) WHERE otazky_id=12)o12 USING(osoby_id)

SELECT * FROM dotaznik2

-- 16. Vytvořte kopii tabulky osoby, do tabulky vložte všechny osoby, které bydlí v
--     Karlovarském kraji. Všem osobám v této tabulce zdvojnásobte příjem.
CREATE TABLE kopie AS (
   SELECT osoby_id, vaha, vyska, pohlavi, povolani_id, kraje_id, (prijem*2) prijem 
   FROM osoby 
   WHERE kraje_id = (SELECT kraje_id FROM kraje WHERE nazev = 'Karlovarský kraj'))


-- 17. Z tabulky osoby vložte do tabulky kopie osoby všechny důchodce, v případě, že se v
--     tabulce osoba již vyskytuje, upravte data podle tabulky osoby, v případě, že se v
--     tabulce kopie nevyskytuje tato data vložte.
-- MERGE INTO kopie USING

MERGE INTO kopie USING 
    (SELECT * FROM OSOBY WHERE povolani_id = (SELECT 
    povolani_id FROM povolani WHERE nazev='důchodce')) duchodce
    ON (kopie.osoby_id = duchodce.osoby_id)

WHEN MATCHED THEN -- jestli je tento duchodce uz v tabulce, tak se to jen updatne
    UPDATE SET
        kopie.prijem = duchodce.prijem
        
        
WHEN NOT MATCHED THEN
    INSERT VALUES(duchodce.osoby_id, duchodce.vek, duchodce.pohlavi, duchodce.vyska,
    duchodce.vaha, duchodce.prijem, duchodce.povolani_id, duchodce.kraje_id)
        








