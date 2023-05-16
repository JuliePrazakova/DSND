-- 2. Pomocí PL/SQL vytvořte funkci, která vypíše názvy kategorií pro danou fotografii na základě jejího primárního identifikátoru. 
--Výpis bude ve formě textového řetězce. Jednotlivé kategorie budou od- děleny čárkou. Pokud taková fotografie neexistuje nebo nemá přidělenou žádnou kategorii, vraťte NULL. (7 bodů)

CREATE OR REPLACE FUNCTION seznam_kategorii (p_id_fotografie NUMBER)
	RETURN VARCHAR2
	AS
        v_kategorie VARCHAR2(300);
        v_id_fotografie NUMBER;

BEGIN
    SELECT id_fotografie INTO v_id_fotografie
    FROM fotografie
    WHERE id_fotografie = p_id_fotografie;

    -- vyjimka jestlize id neexistuje
    IF v_id_fotografie = 0 THEN
        RETURN NULL;
    END IF;

    -- vytvori se list do jedne promenne
    SELECT LISTAGG(k.nazev, ', ') WITHIN GROUP (ORDER BY k.nazev)
    INTO v_kategorie
    FROM kategorie k
    LEFT JOIN fotografie_kategorie fk ON k.id_kategorie = fk.kategorie_id_kategorie
    WHERE fk.fotografie_id_fotografie = p_id_fotografie;

    -- vracime cely list
    RETURN v_kategorie;

    -- vyjimka kdyz se zadne data nenajdou
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;

END;


-- 3. Nad Vámi vytvořeným datovým modelem sestavte SQL dotaz, který vypíše všechny fotografie, 
-- na kte- rých se nachází Petra Šťastná. Výpis bude obsahovat název fotografie, datum pořízení, název země, 
-- kde byla pořízena, popisek a seznam kategorií do kterých je fotografie zařazena. (3 bodů)

SELECT f.nazev, f.datum, f.zeme, f.popisek, seznam_kategorii(f.id_fotografie) AS kategorie
FROM fotografie f
LEFT JOIN fotografie_pratele fp USING(id_fotografie)
LEFT JOIN pratele p USING(id_pritele)
WHERE p.jmeno = "Petra" AND p.prijmeni = "Šťastná";



-- 4. Nad následujícím datovým modelem zjistěte požadované informace pomocí SQL dotazů:
-- a. Ve kterých městech bylo vystaveno pivo s názvem „Tmavý džbán 11°“? (3 body)
SELECT DISTINCT o.nazev
FROM obce o
LEFT JOIN smerovaci_cisla sc USING(id_obce)
LEFT JOIN adresy a ON a.psc = sc.psc
LEFT JOIN restaurace r ON r.id_adresy = a.id_adresy
LEFT JOIN vystav v ON v.id_restaurace = r.id_restaurace
LEFT JOIN piva p ON v.id_piva = p.id_piva
WHERE pi.nazev = "Tmavý džbán 11°";

-- b. Pro jednotlivá piva, určete, kolik sudů bylo celkem vystaveno v restauraci s názvem „U lípy“? (5 bodů)
SELECT p.nazev, SUM(v.pocet_kusu) as celkem_sudu
FROM pivo p
LEFT JOIN vystav v ON v.id_piva = p.id_piva
LEFT JOIN restaurace r ON r.id_restaurace = v.id_restaurace
WHERE r.nazev = "U lípy"
GROUP BY p.nazev;

-- c. Pro jednotlivé kraje vyberte dny s největším vystaveným objemem. Seřaďte podle názvu kraje
-- (pro kazdy kraj vypište právě jeden den, pokud tedy není mezi dny rovnost). (7 bodů)

-- tabulka vsech kraju a jejich celkovem objemu pro kazdy den
WITH kraje_dny AS (
    SELECT k.nazev AS kraj, v.cas_vystaveni, SUM(v.pocet_kusu * tb.objem_v_litrech) AS celkovy_objem
    FROM kraje k
    JOIN obce o ON o.kraje_id_kraje = k.id_kraje
    JOIN restaurace r ON r.adresy_id_adresy = o.id_obce
    JOIN vystav v ON v.restaurace_id_restaurace = r.id_restaurace
    JOIN typy_obalu tb ON t.id_typy_obalu = v.typy_obalu_id_typy_obalu
    GROUP BY k.nazev, v.cas_vystaveni
) -- vybereme ke kazdemu kraji max objem a vypiseme jeho den
SELECT kraj, MAX(celkovy_objem) AS nejvyssi_objem, cas_vystaveni
FROM kraje_dny
GROUP BY kraj
ORDER BY kraj;