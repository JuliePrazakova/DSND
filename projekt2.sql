-- 1. Vypište nejčastěji používaný výraz jako klíčové slovo u evidovaných knih (ne exemplářů), 
-- které byly vydány ve městě "New York". Kdyby bylo více výrazů se stejným počtem knih, vyberte ten, který v abecedním seznamu na prvním místě.
SELECT vyraz.text AS nejpocetnejsi_vyraz, COUNT(*) AS pocet_knih 
FROM kniha
JOIN klicove_slovo ON klicove_slovo.kniha_id_knihy = kniha.id_knihy
JOIN vyraz ON klicove_slovo.vyraz_id_vyrazu = vyraz.id_vyrazu
WHERE misto_vydani = 'New York'
GROUP BY vyraz.text 
ORDER BY pocet_knih DESC, vyraz.text ASC 
fETCH FIRST 1 ROW ONLY;

-- 2.  Vypište nejčastěji používaný výraz jako klíčové slovo u evidovaných knih (ne exemplářů), 
-- které jsou napsané v jiném než českém jazyce. Kdyby bylo více výrazů se stejným počtem exemplářů, vyberte ten, 
-- který v abecedním seznamu na posledním místě. 
SELECT vyraz.text AS nejpocetnejsi_vyraz, COUNT(*) AS pocet_knih 
FROM kniha
JOIN klicove_slovo ON klicove_slovo.kniha_id_knihy = kniha.id_knihy
JOIN vyraz ON klicove_slovo.vyraz_id_vyrazu = vyraz.id_vyrazu
JOIN jazyk ON jazyk.id_jazyku = kniha.jazyk_id_jazyku
WHERE jazyk.nazev != 'čeština'
GROUP BY vyraz.text 
ORDER BY pocet_knih DESC, vyraz.text DESC 
FETCH FIRST 1 ROW ONLY;

-- 3. Kolikrát byla vypůjčena kniha (klidně ve více exemplářích), která jako klíčové slovo má výraz, 
-- který byl nejžádanějším výrazem? Jinými slovy, knihy jsou charakterizovány klíčovými slovy. Nás zajímá, 
-- který výraz byl nejčastěji půjčovaný a konkrétně kolikrát to bylo.
SELECT COUNT(*) AS pocet_vypujcek FROM vypujcka 
JOIN exemplar ON exemplar.id_exemplare = vypujcka.exemplar_id_exemplare 
JOIN kniha ON kniha.id_knihy = exemplar.kniha_id_knihy
JOIN klicove_slovo ON klicove_slovo.kniha_id_knihy = kniha.id_knihy
JOIN vyraz ON klicove_slovo.vyraz_id_vyrazu = vyraz.id_vyrazu 
WHERE vyraz.text = ( 
SELECT vy.text
FROM vyraz vy
JOIN klicove_slovo ks ON ks.vyraz_id_vyrazu = vy.id_vyrazu
GROUP BY vy.text
ORDER BY COUNT(*) DESC
FETCH FIRST 1 ROW ONLY
)

-- 4. U kolika evidovaných exemplářů osoby (osoba je za exemplář zodpovědná) s loginem "kovarj0" je použit jako klíčové slovo výraz, 
-- který je současně nejčastějším používaným výrazem jako klíčové slovo u této osoby? 
SELECT COUNT(*) as pocet_exemplaru FROM exemplar
JOIN osoba ON osoba.id_osoby = exemplar.osoba_id_osoby
JOIN klicove_slovo ON klicove_slovo.kniha_id_knihy = exemplar.kniha_id_knihy 
JOIN vyraz ON vyraz.id_vyrazu = klicove_slovo.vyraz_id_vyrazu
WHERE osoba.login = 'kovarj0' 
AND vyraz.text = ( 
SELECT vyraz.text
FROM vyraz 
JOIN klicove_slovo ks ON ks.vyraz_id_vyrazu = vyraz.id_vyrazu
JOIN exemplar e ON ks.kniha_id_knihy = e.kniha_id_knihy
JOIN osoba o ON o.id_osoby = e.osoba_id_osoby
WHERE o.login = 'kovarj0'
GROUP BY vyraz.text
ORDER BY COUNT(*) DESC
FETCH FIRST 1 ROW ONLY 
);

-- 5.  Vypište název knihy (klidně ve více exemplářích), kterou si nejčastěji půjčovaly osoby s křestním jménem "Karolína". 
-- Kdyby bylo více knih se stejným počtem půjčení, vyberte tu, která v abecedním seznamu na druhém místě.
SELECT k.nazev, COUNT(*) AS pocet_pujceni 
FROM kniha k 
INNER JOIN exemplar e ON k.id_knihy = e.kniha_id_knihy 
INNER JOIN vypujcka v ON e.id_exemplare = v.exemplar_id_exemplare 
INNER JOIN osoba o ON v.osoba_id_osoby = o.id_osoby 
WHERE o.jmeno = 'Karolína'
GROUP BY k.nazev
ORDER BY COUNT(*) DESC, k.nazev
FETCH FIRST 1 ROW ONLY;

-- 6. Kolik osob si někdy půjčilo alespoň tři knihy (exempláře), jejichž název začíná písmenem "p" (nezáleží na velikosti).
SELECT COUNT(DISTINCT v.osoba_id_osoby) as pocet_osob
FROM ( 
SELECT v.osoba_id_osoby, COUNT(*) as pocet_vypujcek 
FROM vypujcka v
INNER JOIN exemplar e ON v.exemplar_id_exemplare = e.id_exemplare
INNER JOIN kniha k ON e.kniha_id_knihy = k.id_knihy 
WHERE k.nazev LIKE 'p%' 
GROUP BY v.osoba_id_osoby 
HAVING COUNT(*) >= 3
) v; 

-- 7 Kolik osob si půjčilo jiný exemplář knihy, kterou sami vlastní, více než 3 krát? (Může se jednat o stejnou knihu opakovaně i o různé knihy)
SELECT COUNT(DISTINCT v.osoba_id_osoby) as pocet_osob
FROM vypujcka v
INNER JOIN exemplar e ON v.exemplar_id_exemplare = e.id_exemplare
INNER JOIN kniha k ON k.id_knihy = e.kniha_id_knihy
WHERE v.osoba_id_osoby = e.osoba_id_osoby
AND v.skutecne_vraceno IS NOT NULL
GROUP BY v.osoba_id_osoby, e.kniha_id_knihy
HAVING COUNT(*) > 3;

-- 8 Vypište, kolik osob si půjčilo knihy častěji, než je průměr půjčení na jednu osobu. Berte v potaz jen ty osoby, 
-- které si půjčili alespoň jednu knihu. 
SELECT COUNT(*) as pocet_osob 
    FROM (
    SELECT COUNT(*) as pocet_vypujcek, osoba_id_osoby 
    FROM vypujcka
    GROUP BY osoba_id_osoby 
    HAVING COUNT(*) > (      
        SELECT AVG(pocet_vypujcek) as prumer FROM (
          SELECT COUNT(*) as pocet_vypujcek, osoba_id_osoby
          FROM vypujcka
          GROUP BY osoba_id_osoby
        )
    )
);

-- 9. Kolik osob nemá zadán e-mail?
SELECT COUNT(*) as pocet_osob_bez_emailu
FROM osoba
WHERE email IS NULL;

-- 10. Jaký je počet stran u nejkratší knihy? Berte v potaz knihy, u kterých je uvedena informace o počtu stran. 
SELECT MIN(pocet_stran) as nejkratsi_kniha_pocet_stran 
FROM kniha
WHERE pocet_stran IS NOT NULL;

-- 11. Která edice má nejdelší název? Pokud je více edicí se stejně dlouhým názvem, vyberte tu první podle abecedy (vypište její název). 
SELECT edice 
FROM kniha
WHERE LENGTH(edice) = (
SELECT MAX(LENGTH(edice)) 
FROM kniha
)
ORDER BY edice 
FETCH FIRST 1 ROW ONLY; 

-- 12 U kolika procent knih je uvedeno vydání? Zaokrouhlete na tři desetinná místa. ROUND(pocet knih s vzdanim[pocet knih celkem)
SELECT ROUND((SELECT COUNT(*) FROM kniha WHERE vydani IS NOT NULL) / COUNT(*) * 100, 3) AS procento_knih_s_vydanim
FROM kniha
GROUP BY 1;

-- 13 Kolik procent osob nemá zadán e-mail? Zaokrouhlete na tři desetinná místa.
SELECT ROUND((SELECT COUNT(*) FROM osoba WHERE email IS NOT NULL) / COUNT(*) * 100, 3) AS procento_osob_s_emailem
FROM osoba
GROUP BY 1;

-- 14 Vypište isbn knihy, která nevyšla jako součást edice, má minimálně 153 stran a nakladatel má v názvu písmeno 
-- "d" (nezálež na velikosti). Pokud je takových více, vyberte tu knihu, která má název abecedně na prvním místě.
SELECT isbn FROM kniha
WHERE edice IS NULL
AND pocet_stran>=153
AND LOWER(nakladatel) LIKE '%d%'
ORDER BY LOWER(nazev) ASC
FETCH FIRST 1 ROW ONLY;

-- 15 Kolik knih má menší počet stran než je průměrný počet stran knih vydaných stejným nakladatelem?
SELECT COUNT(*) as pocet_knih 
FROM kniha k
WHERE pocet_stran < (
    SELECT AVG(k2.pocet_stran) 
    FROM kniha k2
    WHERE k2.nakladatel = k.nakladatel 
);

-- 16 Kolik exemplářů bylo vráceno později, než byl stanovený termín?
SELECT COUNT(*) as pocet_vracenych_pozde
FROM vypujcka
WHERE skutecne_vraceno > vratit_do;

-- 17 Vypište příjmení a jméno osoby, u které jsou nejčastěji při výpůjčce vedeny poznámky. Pokud je větší počet takových osob, 
-- vyberte tu osobu, které má login na posledním místě v abecedě. Pro výpis použijte formát: "PŘÍJMENÍ, jmé" (Příjmení vše velkými písmeny, 
-- první tři písmene z křestního jména malými).
SELECT UPPER(o.prijmeni) || ', ' || LOWER(SUBSTR(o.jmeno, 1, 3)) as osoba,
COUNT(*) as pocet_poznamek
FROM vypujcka v
JOIN osoba o ON o.id_osoby = v.osoba_id_osoby
WHERE poznamka IS NOT NULL
GROUP BY o.prijmeni, o.jmeno, o.login
ORDER BY COUNT(poznamka) DESC, o.login DESC
FETCH FIRST 1 ROW ONLY;

-- 18 Kolik osob si půjčilo exemplář s konkrétním klíčovým slovem alespoň 3 krát? (Např. Když si osoba s id 45 půjčí alespoň 3 krát exemplář, 
-- který je charakterizovaný klíčovým slovem programování, tak se započítá.)
SELECT o.id_osoby, o.jmeno, o.prijmeni, COUNT(*) as pocet_vypujceni
FROM vypujcka v
JOIN osoba o ON o.id_osoby = v.osoba_id_osoby
JOIN exemplar e ON e.id_exemplare = v.exemplar_id_exemplare
JOIN klicove_slovo k ON k.kniha_id_knihy = e.kniha_id_knihy
JOIN vyraz vy ON vy.id_vyrazu = k.vyraz_id_vyrazu
GROUP BY o.id_osoby, o.jmeno, o.prijmeni, vy.text 
HAVING COUNT(*) >=3;
