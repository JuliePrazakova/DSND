-------------------------------------------------------------------------------------------------------------------------
-- 1. 	Vytvořte proceduru, která pro všechny pivovary v rámci vybraného kraje, vypíše název pivovaru a počet druhů piva,
-- 	které pivovar vaří. Dále také vypíše seznam jednotlivých druhů a kolik různých piv tohoto druhu,
-- 	daný pivovar vaří. Kraj bude zadán jako parametr pomocí textového řetězce. Výpis bude v následujícím formátu.
-- 	Počet HVĚZDIČEK bude odpovídat délce předchozího řádku.
-------------------------------------------------------------------------------------------------------------------------	CREATE OR REPLACE PROCEDURE pivovary_v_kraji(p_kraj VARCHAR2)
	IS

	BEGIN
		 FOR v_pivovar IN
			 (
			  SELECT COUNT(DISTINCT id_druhu_piva) AS pocet_piv, pi.nazev as nazev_pivovaru
			  FROM piva p
			  JOIN pivovary pi USING (id_pivovaru)
			  JOIN adresy a USING (id_adresy)
			  JOIN smerovaci_cisla sc USING (psc)
			  JOIN obce o USING (id_obce)
			  JOIN kraje k USING (id_kraje)
			 WHERE k.nazev = p_kraj
			  GROUP BY pi.nazev
			  )
			LOOP

				DBMS_OUTPUT.PUT_LINE(v_pivovar.nazev_pivovaru || ' (' || v_pivovar.pocet_piv || ')' );
				DBMS_OUTPUT.PUT_LINE(RPAD('#', LENGTH(v_pivovar.nazev_pivovaru) + LENGTH(v_pivovar.pocet_piv) + 3, '#'));
		 		
				FOR v_druh_piva IN
				 (
				 SELECT DISTINCT dp.nazev as nazev_druhu, COUNT(id_druhu_piva) AS pocet_piv_druhu
				 FROM druhy_piva dp
			 	 JOIN piva p USING (id_druhu_piva)
			 	 JOIN pivovary pi USING (id_pivovaru)
			 	 JOIN adresy a USING (id_adresy)
			 	 JOIN smerovaci_cisla sc USING (psc)
			 	 JOIN obce o USING (id_obce)
			 	 JOIN kraje k USING (id_kraje)
			 	 WHERE pi.nazev = v_pivovar.nazev_pivovaru AND k.nazev = p_kraj
			 	 GROUP BY dp.nazev
			 	 )
			 	 
					LOOP
			 		 DBMS_OUTPUT.PUT_LINE(' ' || v_druh_piva.nazev_druhu  || ' - ' || v_druh_piva.pocet_piv_druhu);
			 	 END LOOP;

			 	 DBMS_OUTPUT.PUT_LINE(' ');
		 END LOOP;
	END;
	/
	BEGIN
	pivovary_v_kraji('Jihomoravský kraj');
	END;
	
---------------------------------------------------------------------------------------------------------------------------------------------
-- 2. 	Vytvořte proceduru se vstupním parametrem (název piva), která pro pivo se zadaným s daným názvem vypíše název piva a název 
-- 	pivovaru, ve kterém bylo pivo uvařeno, a dopočítá pro něj následující informace: počet obcí, ve kterých se alespoň jednou vystavilo;
-- 	počet různých druhů obalů, ve kterých bylo pivo vystaveno; celkový počet piv stejného druhu ve všech pivovarech. 
-- 	Případ, že nebude nalezeno pivo, nebo bude piv se stejným názvem více, ošetřete pomocí výjimky tak, aby se vypsala hláška, 
-- 	která bude uživatele této procedury o této skutečnosti informovat. Výpis pak bude v následujícím formátu:
---------------------------------------------------------------------------------------------------------------------------------------------	
CREATE OR REPLACE PROCEDURE vypis_informace_o_pivu(p_nazev_piva VARCHAR2)
IS
	v_pivovar pivovary.nazev%TYPE;
	v_obaly NUMBER
	v_obce NUMBER;
	v_piva_stejneho_druhu NUMBER;
	v_stejne_nazvy_piv NUMBER;
	e_stejne_nazvy_piva EXCEPTION;

BEGIN
	SELECT COUNT(nazev) INTO v_stejne_nazvy_piv
	FROM piva
	WHERE piva.nazev = p_nazev_piva;

	CASE
		WHEN v_stejne_nazvy_piv > 1 THEN
			RAISE_APPLICATION_ERROR(-20001, 'Takto se jmenuje více než jedno pivo');
		WHEN v_stejne_nazvy_piv < 1 THEN
			RAISE_APPLICATION_ERROR(-20002, 'Takové pivo v databázi nemáme');
		ELSE
			NULL;
	END CASE;

	SELECT pi.nazev, COUNT(DISTINCT o.id_obce), COUNT(DISTINCT v.id_typu_obalu), COUNT(p.id_druhu_piva)
	INTO v_pivovar, v_obce, v_obaly, v_piva_stejneho_druhu
	FROM piva p
	LEFT JOIN pivovary pi ON pi.id_pivovaru = p.id_pivovaru
	LEFT JOIN vystav v ON v.id_piva = p.id_piva
	LEFT JOIN restaurace r ON r.id_restaurace = v.id_restaurace
	LEFT JOIN adresy a ON a.id_adresy = r.id_adresy
	LEFT JOIN smerovaci_cisla sc USING(psc)
	LEFT JOIN obce o ON o.id_obce = sc.id_obce
	WHERE p.nazev = p_nazev_piva
	GROUP BY pi.nazev;

		IF v_pivovar IS NOT NULL THEN
			DBMS_OUTPUT.PUT_LINE(UPPER(p_nazev_piva) || ' [' || LOWER(v_pivovar) || ']');
			DBMS_OUTPUT.PUT_LINE(' # ' || 'počet obcí: ' || v_obce);
			DBMS_OUTPUT.PUT_LINE(' # ' || 'počet různých obalů: ' || v_obaly);
			DBMS_OUTPUT.PUT_LINE(' # ' || 'počet piv stejného druhu: ' || v_piva_stejneho_druhu);
		ELSE
			RAISE_APPLICATION_ERROR(-20003, 'Nekde se stala chyba');
		END IF;
END;
/
BEGIN
	vypis_informace_o_pivu('Vsacan');
END;

---------------------------------------------------------------------------------------------------------------------------------------------------
-- 3. 	Vytvořte proceduru, která na základě tří parametrů (id, název sloupce a hodnota), nastaví novou hodnotu v daném sloupci 
-- 	pro pivovar s daným id. Pokud dané id neexistuje, je potřeba vyvolat chybu s vhodně voleným číslem a odpovídající chybovou hláškou.
-- 	V případě neexistujícího sloupce vypište informaci: „Takovýto sloupec neexistuje“ a následně vypište názvy sloupců, které je možné použít.
-- 	Pro tento výpis použijte datový slovník. V případě, že by změnou hodnoty sloupce došlo k porušení integritního omezení, odchyťte tuto chybu
-- 	v rámci procedury a vypište text chybové hlášky.
---------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE nastaveni_hodnoty
(p_id NUMBER, p_sloupec VARCHAR2, p_nova_hodnota VARCHAR2)
	IS
			 v_prikaz_k_provedeni VARCHAR2(500);
			 v_id NUMBER;
			 v_pocet_sloupcu PLS_INTEGER;

	BEGIN

	SELECT id_pivovaru
	INTO v_id
	FROM pivovary
	WHERE id_pivovaru = p_id;

	SELECT COUNT(*) INTO v_pocet_sloupcu
	FROM all_tab_columns
	WHERE UPPER(column_name) = UPPER(p_sloupec) AND UPPER(table_name) = 'PIVOVARY';

	IF v_pocet_sloupcu = 0 THEN
		 DBMS_OUTPUT.PUT_LINE('Takovýto sloupec neexistuje');

		FOR rec IN (SELECT column_name
			 	FROM all_tab_columns
			 	WHERE UPPER(table_name) = 'PIVOVARY') LOOP
			 		DBMS_OUTPUT.PUT_LINE(rec.column_name);
			 	END LOOP;
	ELSE
		BEGIN
			SELECT id_pivovaru INTO v_id
			FROM pivovary
			WHERE id_pivovaru = p_id;

			IF v_id IS NULL THEN
				RAISE_APPLICATION_ERROR(-20021, 'Pivovar s danym ID neexistuje');
			END IF;

			v_prikaz_k_provedeni := 'UPDATE pivovary SET ' || p_sloupec || ' = :nova_hodnota WHERE id_pivovaru = :id';
			EXECUTE IMMEDIATE v_prikaz_k_provedeni USING p_nova_hodnota, p_id;

			EXCEPTION
				WHEN OTHERS THEN
			 		DBMS_OUTPUT.PUT_LINE('Chyba při změně hodnoty sloupce: ' || SQLERRM);
			END;
	END IF;

		EXCEPTION
			WHEN OTHERS THEN
				DBMS_OUTPUT.PUT_LINE('Chyba: ' || SQLERRM);
END;
/
BEGIN
	nastaveni_hodnoty(8,'nazev','nove jmeno');
END;

---------------------------------------------------------------------------------------------------------------------------------------
-- 4. 	Vytvořte pohled adresa_restaurace, který bude mít sloupce id, restaurace, ulice, orientacni_cislo, popisne_cislo, psc, obec.
--    	Sloupec id bude odpovídat sloupci id_restaurace z tabulky restaurace, sloupec restaurace bude odpovídat sloupci nazev z tabulky 
--    	restaurace, sloupec ulice bude odpovídat sloupci ulice z tabulky adresy, sloupec orientacni_cislo bude odpovídat sloupci 
--    	cislo_orientacni z tabulky adresy, sloupec popisne_cislo bude odpovídat sloupci cislo_popisne z tabulky adresy, sloupec psc 
--    	bude odpovídat sloupci psc z tabulky adresy, sloupec obec bude odpovídat sloupci nazev z tabulky obce a náležící k danému psc. 
--    	V tomto pohledu se vyskytnou pouze restaurace z Jihomoravského kraje. Tento pohled vytvořte tak, aby případné DML operace nad 
--    	tímto pohledem nemohly ovlivnit jiná data než ta, která jsou přístupná prostřednictvím pohledu. 
---------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW adresa_restaurace
(id, restaurace, ulice, orientacni_cislo, popisne_cislo, psc, obec)
AS
	SELECT r.id_restaurace, r.nazev, a.ulice,
	a.cislo_orientacni, a.cislo_popisne, sc.psc, o.nazev
	FROM restaurace r
	JOIN adresy a ON a.id_adresy = r.id_adresy
	JOIN smerovaci_cisla sc ON sc.psc = a.psc
	JOIN obce o ON sc.id_obce = o.id_obce
	JOIN kraje k ON k.id_kraje = o.id_kraje
	WHERE k.nazev = 'Jihomoravský kraj'
	WITH CHECK OPTION;

------------------------------------------------------------------------------------------
-- 5. 	Vytvořte spouš(ť/tě), kter(á/é) umožní DML operace nad pohledem adresa_restaurace.
------------------------------------------------------------------------------------------

	[DELETE]

	CREATE OR REPLACE TRIGGER delete_adresa_restaurace
	INSTEAD OF DELETE ON adresa_restaurace
	FOR EACH ROW

	BEGIN

    	DELETE FROM restaurace
    		WHERE id_restaurace = :OLD.id;
	END;


------------------------------------------------------------------------------------------
[UPDATE]	

	CREATE OR REPLACE TRIGGER update_adresa_restaurace
	NSTEAD OF UPDATE ON adresa_restaurace
	FOR EACH ROW
	
	BEGIN
    	UPDATE restaurace
        	SET 
			id_restaurace = :NEW.id
       		WHERE id_restaurace = :OLD.id;
    
    	UPDATE adresy
        	SET 
          		id_adresy = :NEW.id,
            		ulice = :NEW.ulice,
            		cislo_orientacni = :NEW.orientacni_cislo,
            		cislo_popisne = :NEW.popisne_cislo,
            		psc = :NEW.psc
        	WHERE id_adresy = :OLD.id;
	END;       

---------------------------------------------------------------------------------------------------------------------------------------------------
-- 6. 	Vytvořte funkci, která bude vracet textový řetězce s informacemi o pivu. Jediným parametrem bude id piva. Bude-li zadáno neexistující 
-- 	id piva, funkce vrátí hodnotu NULL. Výpis bude závislý na názvu daného piva. Pokud bude mít název 7 a méně písmen, výstupem funkce bude
-- 	řetězec obsahující název piva a název pivovaru. Pokud bude mít název 8 až 15 písmen, výstupem funkce bude řetězec obsahující název 
-- 	piva, název pivovaru a množství alkoholu. Pokud bude mít název více než 15 písmen, výstupem funkce bude řetězec obsahující název 
-- 	piva, název pivovaru a objem vystaveného množství v litrech v aktuálním roce. Jednotlivé informace budou odděleny čárkou a ukončeny tečkou.
---------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION informace_o_pivu (p_id NUMBER)
	RETURN VARCHAR2
	AS
			v_vypsani VARCHAR2(500);
			v_nazev_piva piva.nazev%TYPE;
			v_objem_v_litrech NUMBER;
			v_pocet_kusu NUMBER;
			v_objem_mnozstvi NUMBER;

	BEGIN
			SELECT piva.nazev
			INTO v_nazev_piva
			FROM piva
			WHERE id_piva = p_id;

			IF v_nazev_piva IS NULL THEN
				RETURN NULL;
			END IF;

			IF LENGTH(v_nazev_piva) < 8 THEN
				SELECT piva.nazev ||','|| pivovary.nazev||'.'
				INTO v_vypsani
			  	FROM piva
			  	JOIN pivovary USING (id_pivovaru)
			  	WHERE id_piva = p_id;

			ELSIF LENGTH(v_nazev_piva) >= 8 AND LENGTH(v_nazev_piva) <= 15 THEN
			  	SELECT piva.nazev ||', '|| pivovary.nazev ||', '|| piva.alkohol ||'.'
			  	INTO v_vypsani
			  	FROM piva
			  	JOIN pivovary USING (id_pivovaru)
			  	WHERE id_piva = p_id;

			ELSE
			  	SELECT v.pocet_kusu, tob.objem_v_litrech
			  	INTO v_pocet_kusu, v_objem_v_litrech
				FROM piva
				JOIN vystav v USING (id_piva)
				JOIN typy_obalu tob USING (id_typu_obalu)
				WHERE id_piva = p_id
				AND TO_CHAR(v.cas_vystaveni,'YYYY') = TO_CHAR(SYSDATE,'YYYY');

			  	v_objem_mnozstvi := v_objem_v_litrech*v_pocet_kusu;

				SELECT piva.nazev ||', '|| pivovary.nazev ||', '|| v_objem_mnozstvi ||'.'
				INTO v_vypsani
				FROM piva
				JOIN pivovary USING (id_pivovaru)
				WHERE id_piva = p_id;
			END IF;
		RETURN v_vypsani;

		EXCEPTION
			WHEN NO_DATA_FOUND THEN
			  	RETURN NULL;
END;

SELECT informace_o_pivu(8) FROM DUAL;


