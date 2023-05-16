-- PL/SQL FILE --

--------------------------------------------------------------------------------
-- 9. CVIKA
--------------------------------------------------------------------------------

CREATE table ZVIRE (
    ZVIRE_ID NUMBER NOT NULL,
    NAZEV       VARCHAR2(50) NOT NULL,
    DRUH        VARCHAR2(50) NOT NULL,
    constraint  ZVIRE_PK primary key (ZVIRE_ID)
);

INSERT INTO zvire (zvire_id, nazev, druh) VALUES(1, 'pes', 'psoviti')

SELECT * FROM zvire

SAVEPOINT after_zvire_jedna;

UPDATE zvire SET nazev='kocka' WHERE zvire_id=1;
SELECT * FROM zvire;

ROLLBACK after_zvire_jedna;


-- PL SQL - VIEWS - DBMS Output
DECLARE
 v_promenna NUMBER;
 v_promenna2 VARCHAR2(5);
BEGIN
    v_promenna:=10;
    v_promenna2:='text';
    DBMS_OUTPUT.PUT_LINE(v_promenna);
    DBMS_OUTPUT.PUT_LINE(v_promenna2);
END;


--------------------------------------------------------------------------------
-- 10. CVIKA
--------------------------------------------------------------------------------

-- ukol 1.
-- cviceni 10 priklad z prednasky 8 slide 26
-- musime si v View -> DBMS output -> kliknout na plus v tom okne co se otevrelo
<<outer>> -- pojmenovany vnejsi blok
DECLARE
 v_father_name VARCHAR2 (20) :='Patrick';
 v_date_of_birth DATE:='20-Apr-1972';
BEGIN
 DECLARE
  v_child_name VARCHAR2(20):='Mike';
  v_date_of_birth DATE:='12-Dec-2002';
 BEGIN
  DBMS_OUTPUT.PUT_LINE('Fathe''s Name: '||v_father_name);
  DBMS_OUTPUT.PUT_LINE('Date of birth: ' ||outer.v_date_of_birth);
  DBMS_OUTPUT.PUT_LINE('Child''s Name: '||v_child_name);
  DBMS_OUTPUT.PUT_LINE('Date of Birth: ' ||v_date_of_birth);
 END;
END;


<<vnejsi>>
DECLARE
jmeno_vedouciho VARCHAR2(100) := 'Annaa';
plat INTEGER := 100;
BEGIN
  DECLARE
    jmeno_zamestnance VARCHAR2(100) := 'Pavel';
    plat NUMBER := 50;
  BEGIN
    DBMS_OUTPUT.PUT_LINE('vedouci: ' || jmeno_vedouciho || ', plat: ' || vnejsi.plat);
    DBMS_OUTPUT.PUT_LINE('zaměstnanec: ' || jmeno_zamestnance || ', plat: ' || plat);
  END;
END;

-- ukol 2.
-- Z tří zadaných stran trojúhelníka zjistěte, zda je možné trojúhelník zkonstruovat. Pokud to možné je, vypište jeho obvod.
DECLARE
    a NUMBER := &a; -- & znamena ze hodnota bude vyzadovana na vstupu
    b NUMBER := &b;
    c NUMBER := &c;
    obvod NUMBER;
BEGIN
    IF (a+b>c) and (a+c>b) and (c+b>a) THEN
        obvod:=a+b+c;
        DBMS_OUTPUT.PUT_LINE('Trojuhelnik lze zkonstruovat, jeho obvod je: ' || obvod);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Trojuhelnik nelze zkonstruovat');
    END IF;
END;

-- 3. ukol 
-- Přidejte informaci o tom, je-li trojúhelník rovnostranný, pravoúhlý nebo rovnoramenný
DECLARE
    a NUMBER := &a; -- & znamena ze hodnota bude vyzadovana na vstupu
    b NUMBER := &b;
    c NUMBER := &c;
    obvod NUMBER;
BEGIN
    IF (a+b>c) and (a+c>b) and (c+b>a) THEN
        obvod:=a+b+c;
        DBMS_OUTPUT.PUT_LINE('Trojuhelnik lze zkonstruovat, jeho obvod je: ' || obvod);
        IF (a=b) and (b=c) THEN
            DBMS_OUTPUT.PUT_LINE('Trojuhelnik je rovnostranny');
        ELSIF (a=b) OR (a=c) OR (b=c) THEN
            DBMS_OUTPUT.PUT_LINE('Trojuhelnik je rovnoramenny');
        ELSIF (POWER(a,2)=POWER(b,2)+POWER(c,2)) THEN
            DBMS_OUTPUT.PUT_LINE('Trojuhelnik je pravouhly');    
        END IF;
    ELSE
        DBMS_OUTPUT.PUT_LINE('Trojuhelnik nelze zkonstruovat');
    END IF;
END; 

-- 4. ukol
-- Zjistěte maximální počet pracovníků na jednom oddělení. Pokud jich je méně než 6 vypište „malé oddělení“. Je-li více než 5 a méně než 10 vypište „střední oddělení“. Má-li toto oddělení více než 9 pracovníků
-- vypište „velké oddělení“. Pracujte s tabulkami ze schématu c##prodejny
DECLARE
    v_max BINARY_INTEGER;
BEGIN
    SELECT max(pocet) INTO v_max -- ulozeni implicitnim kurzorem do promenne v_max
    FROM (SELECT count(*) pocet
        FROM zamestnanci
        GROUP BY id_oddeleni);
    
    IF v_max < 6 THEN
        dbms_output.put_line('Male oddeleni');
    ELSIF v_max<10 THEN
        DBMS_OUTPUT.PUT_LINE('Stredni oddeleni');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Velke oddeleni');
    END IF;
END;

-- nebo:
CASE
  WHEN v_max < 6 THEN
   blablabla pomoci CASE

-- ukol 5. potrebujeme explicitni kurzor! - prezentace 8. slide 54
-- Na základě stejných pravidel vypište všechna oddělení (název pobočky a název oddělení) a přiřaďte
-- k nim informaci o jejich velikosti formou uvedené klasifikace.

DECLARE
    CURSOR cur_odd IS
        SELECT pobocky.nazev pobocka, oddeleni.nazev oddeleni, pocet
        FROM pobocky
        JOIN oddeleni USING (id_pobocky)
        JOIN (SELECT id_oddeleni, count(*) pocet
            FROM zamestnanci
            GROUP BY id_oddeleni) USING (id_oddeleni);
   
    v_pobocka pobocky.nazev%TYPE;
    v_oddeleni oddeleni.nazev%TYPE;
    v_pocet PLS_INTEGER;
BEGIN
    OPEN cur_odd;
    LOOP
    FETCH cur_odd INTO v_pobocka, v_oddeleni, v_pocet;
    EXIT WHEN cur_odd%NOTFOUND;
    DBMS_OUTPUT.PUT(v_pobocka|| ' ' ||v_oddeleni|| ': ');
    IF v_pocet < 6 THEN
      DBMS_OUTPUT.PUT_LINE('malé oddělení');
    ELSIF v_pocet < 10 THEN
      DBMS_OUTPUT.PUT_LINE('střední oddělení');
    ELSE
      DBMS_OUTPUT.PUT_LINE('velké oddělení');
    END IF;
    END LOOP;
    CLOSE cur_odd;
END;

-- nebo od Turci
DECLARE
    CURSOR cur_odd IS
    SELECT pobocky.nazev, oddeleni.nazev, pocet
    FROM(SELECT COUNT(*) pocet, id_oddeleni
        FROM C##prodejny.zamestnanci
        GROUP BY id_oddeleni) 
        JOIN C##prodejny.oddeleni USING(id_oddeleni)
        JOIN C##prodejny.pobocky USING(id_pobocky);

    v_pocet NUMBER;
    v_pob C##prodejny.pobocky.nazev%TYPE;
    v_odd C##prodejny.oddeleni.nazev%TYPE;
BEGIN
  OPEN cur_odd;
  LOOP
    FETCH cur_odd INTO v_pob,v_odd,v_pocet;
    EXIT WHEN cur_odd%NOTFOUND;
    DBMS_OUTPUT.put_line(v_pob||' ('||v_odd||')');
  END LOOP;
  CLOSE cur_odd;
END;

-- implicitni = jedna hodnota ulozena do promenne
-- explicitni = mnoho hodnot do promenne a pak hodne vysledku


-- 1. Pomocí nepojmenovaného bloku spočítejte faktoriál 5.
DECLARE
    v_fakt NUMBER:=:cislo;
    vysl NUMBER:=1;
BEGIN
    WHILE v_fakt>1 LOOP
        vysl:=vysl*v_fakt;
        v_fakt:=v_fakt-1;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE(vysl);
END;

DECLARE
    v_fakt NUMBER:=:cislo;
    vysl NUMBER:=1;
BEGIN
    FOR i IN 2..v_fakt LOOP
        vysl:=vysl*i;
        END LOOP;
    DBMS_OUTPUT.PUT_LINE(vysl);
END;

-- 2. Pomocí nepojmenovaného bloku zjistěte, průměrné příjmy mužů a žen. Pokud mají vyšší plat ženy, vypište:
-- "Ženy mají vyšší příjem." Pokud mají vyšší průměrný příjem muži, vypište: "Muži berou více." V případě, že se
-- průměry rovnají, vypište: "Je to remíza." 

DECLARE
    v_prijem_zeny FLOAT;
    v_pr_muzi FLOAT;
BEGIN
    SELECT avg(prijem) INTO v_pr_zeny FROM osoby
    WHERE pohlavi=zena;
    
    SELECT avg(prijem) INTO v_pr_musi FROM osoby
    WHERE pohlavi=muz;
    
    IF v_pr_zeny>v_pr_muzi THEN
     DBMS_OUTPUT.PUT_LINE('Zeny berou vice');
    ELSIF v_pr_zeny<v_pr_muzi THEN
     DBMS_OUTPUT.PUT_LINE('Muzi berou vice');
    END IF;
END;

-- nebo
DECLARE
    v_muz NUMBER:=0;
    v_zena NUMBER:=0;
BEGIN
    SELECT AVG(prijem) INTO v_zena
    FROM osoby
    WHERE pohlavi='žena' ;

    SELECT AVG(prijem) INTO v_muz
    FROM osoby
    WHERE pohlavi='muž';

    IF (v_zena>v_muz) THEN
        DBMS_OUTPUT.PUT_LINE('Zeny maji vyssi prijem ');
    ELSIF (v_zena=v_muz) THEN
        DBMS_OUTPUT.PUT_LINE('Je to remiza');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Muzi berou vice');
    END IF;
END;

-- 3. Pomocí nepojmenovaného bloku spočítejte průměrnou výšku v jednotlivých krajích zaokrouhlenou na celá
-- čísla. Pokud je toto číslo dělitelné třemi beze zbytku, vypište název kraje velkými písmeny. Pokud je zbytek po
-- dělení třemi jedna, pak název kraje vypište s velkými písmeny na začátku každého slova. V ostatních případech
-- vypište název kraje malými písmeny. Vždy připojte i zaokrouhlený průměr.

----> potreba je explicitni kurzor

DECLARE
     CURSOR cur_prumer IS
        SELECT nazev, round(avg(vyska),0), pocet
        FROM kraje
        JOIN osoby USING (osoby_id)
        JOIN (SELECT kraje_id, count(*) pocet
            FROM kraje
            GROUP BY kraje_id) USING (kraje_id);
   
    v_kraj kraje.nazev%TYPE;
    v_vyska osoby.vyska%TYPE;
    v_pocet PLS_INTEGER;
BEGIN
    OPEN cur_prumer;
    LOOP
    FETCH cur_prumer INTO v_kraj, v_prumer;
    EXIT WHEN cur_prumer%NOTFOUND;
        IF v_prumer/3!=0 THEN 
            DBMS_OUTPUT.PUT_LINE(UPPER(v_kraj));
        ELSIF v_prumer/3!=1 THEN
            DBMS_OUTPUT.PUT_LINE(INITCAP(UPPER(v_kraj)));
        ELSE
            DBMS_OUTPUT.PUT_LINE(LOWER(v_kraj));
        END IF;
    END LOOP;
    CLOSE cur_prumer;
END;


-- 6. Vytvořte funkci, která se bude chovat stejně jako funkce NVL2 bez použití této funkce.
-- BVL2 - resi nullove hodnoty, ma 2 parametry
CREATE OR REPLACE FUNCTION mojeNVL2 (p1 VARCHAR2, p2 VARCHAR2, p3 VARCHAR2) RETURN VARCHAR2
AS 
BEGIN
    IF p2 IS NULL THEN
        return p3;
    ELSE
        return p2;
    END iF;
END;


--------------------------------------------------------------------------------
-- 11. CVIKA
--------------------------------------------------------------------------------

-- 7. Vytvořte funkci prvočíslo, která na základě vstupního parametru určí, zda se jedná o prvočíslo. Pokud zadané číslo bude prvočíslo, funkce vrátí hodnotu 1. Pokud předaný parametr nebude prvočíslo, funkce vrátí hodnotu 0. Tato funkce bude vyhodnocovat pouze přirozená čísla. Pokud uživatel zadá jiné než přirozené číslo, funkce vy-hodí výjimku -20001 stextem „Není prirozene číslo.“


-- 8. Vytvořte procedurukraje_povolani s parametrem počet. Výstupem této procedury bude seznam krajů a u nich všechna povolání,která se v kraji vyskytují v počtu alespoň počet. Výpis bude následující:
-- Hlavní město Praha-ostatní; důchodce; zaměstnanec; Jihomoravský kraj-důchodce; zaměstnanec; OSVČ; 

CREATE OR REPLACE PROCEDURE kraje_povolani(p_pocet NUMBER)
AS
CURSOR cur_kraje IS 
  SELECT nazev, kraje_id FROM kraje;
CURSOR cur_povolani(p_kraj NUMBER) IS
  SELECT nazev
  FROM povolani JOIN osoby USING (povolani_id)
  WHERE kraje_id=p_kraj
  GROUP BY nazev
  HAVING count(*)>=p_pocet;
BEGIN
  FOR r_kraj IN cur_kraje LOOP
    DBMS_OUTPUT.PUT_LINE(r_kraj.nazev);
    DBMS_OUTPUT.PUT(' - ');
    FOR r_pov IN cur_povolani(r_kraj.kraje_id) LOOP
      DBMS_OUTPUT.PUT(r_pov.nazev||'; ');
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('');
  END LOOP; 
END;

-- 9. Vytvořte funkci, která na základě parametru kraj, číslo otázky a odpověď vrátí id a příjem osoby. Ošetřete případ, že takových osob bude více, nebo že taková osoba nebude ani jedna.
DECLARE
    CURSOR cur_kraje IS 
        SELECT round(avg(prijem),2) prum,kraje_id,nazev
        FROM osoby JOIN kraje USING(kraje_id)
        GROUP BY nazev,kraje_id;
    CURSOR cur_osoby(p_kraj NUMBER, p_prum NUMBER) IS
        SELECT osoby_id, prijem
        FROM osoby 
        WHERE prijem>p_prum AND kraje_id=p_kraj;
BEGIN
  FOR r_kraj IN cur_kraje LOOP
    DBMS_OUTPUT.put_line(r_kraj.nazev||' '||r_kraj.prum);
    FOR r_osoba IN cur_osoby(r_kraj.kraje_id, r_kraj.prum) LOOP
       DBMS_OUTPUT.put_line(r_osoba.osoby_id||' '||r_osoba.prijem);
    END LOOP;
  END LOOP;
END;



-- 10. Vytvořte proceduru pro smazaní řádku z tabulky osoby. Procedura bude mít jeden parametr (příjem). Pokud žádný řádek neobsahuje v sloupci prijem danou hodnotu, vyvoláte výjimku, kterou zpracujete. V případě úspěš-ného smazání se vypíše, kolik záznamů bylo smazáno.
CREATE OR REPLACE PROCEDURE smaz_osobu(p_prijem NUMBER)
AS  
BEGIN
   DELETE FROM osoby WHERE prijem=p_prijem;
   IF SQL%NOTFOUND THEN
     RAISE_APPLICATION_ERROR(-20015,'NIC nsemazano!!!');
   ELSE
     DBMS_OUTPUT.PUT_LINE('SMAZANO: '|| SQL%ROWCOUNT);
   END IF;
END

-- tady to spoustime i s vyjimkou
DECLARE
e_chyba EXCEPTION;
PRAGMA EXCEPTION_INIT(e_chyba,-20015);
BEGIN
  smaz_osobu(1820);
EXCEPTION
  WHEN e_chyba THEN 
  DBMS_OUTPUT.PUT_LINE('fhsdfhewoifh');
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(SQLCODE||' '||SQLERRM(SQLCODE));
END;

-- 11. a) Vytvořte proceduru pro úpravu názvu kraje na základě předávaného id a nového názvu. Je-li zadáno nee-xistující id, vyvolejte error s číslem -20917 a chybovou hláškou "Pokus o úpravu neexistujícího kraje."b) v části výjimek tuto chybu odchytněte a ošetřete.
CREATE OR REPLACE PROCEDURE update_kraj(p_id INTEGER, p_nazev VARCHAR2)
AS
e_chyba EXCEPTION;
PRAGMA EXCEPTION_INIT(e_chyba,-20917);
BEGIN
    UPDATE kraje SET nazev = p_nazev
    WHERE kraje_id = p_id;
    IF SQL%NOTFOUND THEN
        RAISE_APPLICATION_ERROR(-20917, 'Pokus o úpravu neexistujícího kraje.');
    ELSE
        dbms_output.put_line('Zmena provedena');
    END IF;
   EXCEPTION
    WHEN  e_chyba THEN
        dbms_output.put_line('Kraj neexistuje');
END;


-- 12. Vytvořte spoušť, která aby se příjem mohl změnit maximálmě o 20%.
CREATE OR REPLACE TRIGGER spoust
BEFORE UPDATE OF prijem ON osoby
FOR EACH ROW
BEGIN
IF (:NEW.prijem > :OLD.prijem * 1.2) OR
(:NEW.prijem < :OLD.prijem * 0.8) THEN
RAISE_APPLICATION_ERROR(-20179,
'Změna prijmu o více než 20 %.');
END IF;
END;

-- 13. Upravte předchozí spoušť tak, aby nevyhazovala výjimku, ale aby nastavila prijem na maximální změnu o20%.

CREATE OR REPLACE TRIGGER moje_osoby_tg INSTEAD of INSERT ON moje_osoby
FOR EACH ROW

-- 14. Vytvořte pohled moje_osoby, který bude vypisovat informace o osobách ve tvaru id osoby, název kraje, název povolání, pohlaví, věk a příjem (osoba, kraj, povolani, pohlavi, vek, prijem).
CREATE OR REPLACE VIEW moje_osoby(osoba, kraj, povolani, pohlavi, vek, prijem)
AS SELECT osoby_id, kraje.nazev, povolani.nazev, pohlavi, vek, prijem
FROM osoby
JOIN kraje USING (kraje_id)
JOIN povolani USING (povolani_id);


-- 15. Vytvořte trigger (spoušť), který umožní vkládání nových záznamů prostřednictvím pohledu moje_osoby. Po-kud bude uživatel vkládatneexitující kraj, trigger vyhodí chybovou hlášku: s číslem -20309 a textem "Neexistující kraj". Pokud uživatel zadá neexistující povolání, trigger zajistí jeho korektní vložení prostřednictvím pohledu.
CREATE OR REPLACE TRIGGER moje_osoby_trg
INSTEAD OF INSERT
ON moje_osoby
FOR EACH ROW
DECLARE
  v_kraje_id kraje.kraje_id%TYPE;
  v_povolani_id povolani.povolani_id%TYPE;
  v_exist INTEGER;
BEGIN
    SELECT COUNT (*) INTO v_exist
    FROM kraje
    WHERE nazev = :NEW.kraj;
   
    IF v_exist = 0
        THEN
            RAISE_APPLICATION_ERROR(-20309,'"Neexistující kraj');
    ELSE
        SELECT kraje_id INTO v_kraje_id FROM kraje WHERE nazev= :NEW.kraj;
    END IF;
   
   
    SELECT COUNT (*) INTO v_exist
    FROM povolani
    WHERE nazev = :NEW.povolani;
   
    IF v_exist = 0
        THEN
            SELECT max(povolani_id)
            INTO v_povolani_id
            FROM povolani;
            v_povolani_id:=(v_povolani_id+1);
           
            INSERT INTO povolani VALUES (v_povolani_id, :NEW.povolani);
    ELSE
        SELECT povolani_id INTO v_povolani_id FROM povolani WHERE nazev= :NEW.povolani;
    END IF;
  
    INSERT INTO osoby (osoby_id, kraje_id, povolani_id, pohlavi, vek, prijem)
    VALUES (:NEW.osoba, v_kraje_id, v_povolani_id, :NEW.pohlavi, :NEW.vek, :NEW.prijem);
END;

-- 16. Vložte prostřednictvím pohledu moje_osoby novou osobu.

-- 17. Vytvořte proceduru, která v tabulce osoby upravídata na základě tří parametrů (id osoby, název sloupce, nová hodnota). V případě, že takový sloupecneexistuje, vypište:takový sloupec neexistujea doplňte výpisem všech existujících sloupců. Pokud by došlo při vkládání k nějakému erroru, odchytněte tuto chybu a vypište ji.
create or replace procedure osoby_uprava
(p_id_osoby number,p_nazev_sloupce varchar2, nova_hodnota varchar2)
as
v_pocet number;
BEGIN
SELECT count(*) INTO v_pocet
FROM user_tab_columns
WHERE table_name='OSOBY' AND column_name=UPPER(p_nazev_sloupce);
IF v_pocet=0 THEN
  DBMS_OUTPUT.PUT_LINE('Existujici sloupce:');
  FOR r IN (SELECT column_name FROM user_tab_columns WHERE table_name='OSOBY')LOOP
    DBMS_OUTPUT.PUT_LINE(r.column_name);
  END LOOP;
ELSE
  EXECUTE IMMEDIATE 'UPDATE osoby SET '||p_nazev_sloupce||' = '''
  ||nova_hodnota||''' WHERE osoby_id= '||p_id_osoby;
END IF;
END;

-- 18. Vytvořte proceduru, která v tabulce osoby upraví data na základě čtyř parametrů (restrikční sloupec, re-strikční hodnota, upravovaný sloupce, upravovaná hodnota). V případě, že takový sloupec neexistuje, vypište:takový sloupec neexistuje. Pokud by došlo při vkládání k nějakému erroru, odchytněte tuto chybu a vypište ji. Vypište počet upravených řádků.

-- 19. Vytvořte agregační funkci pro výpočet 2. největší hodnoty















