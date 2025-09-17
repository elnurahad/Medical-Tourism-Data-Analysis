-- =====================================================
-- INTERMEDIATE SQL QUERIES (40 queries) - Part 1
-- Medical Tourism Database 
-- Mittlere SQL-Abfragen für medizinische Tourismusdatenbank
-- =====================================================

-- 1. Join patients with their treatments / Patienten mit ihren Behandlungen verknüpfen
SELECT p.Vorname, p.Nachname, b.Behandlungsdatum, b.Status
FROM patienten p
JOIN behandlungsverlaeufe b ON p.Patienten_ID = b.Patienten_ID;

-- 2. Show treatments with service details / Behandlungen mit Leistungsdetails anzeigen
SELECT b.Behandlungs_ID, p.Nachname, ml.Leistungsname, ml.Kategorie, b.Gesamtkosten_EUR
FROM behandlungsverlaeufe b
JOIN patienten p ON b.Patienten_ID = p.Patienten_ID
JOIN medizinische_leistungen ml ON b.Leistungs_ID = ml.Leistungs_ID;

-- 3. Count treatments per patient / Behandlungen pro Patient zählen
SELECT p.Vorname, p.Nachname, COUNT(b.Behandlungs_ID) AS anzahl_behandlungen
FROM patienten p
LEFT JOIN behandlungsverlaeufe b ON p.Patienten_ID = b.Patienten_ID
GROUP BY p.Patienten_ID, p.Vorname, p.Nachname;

-- 4. Average treatment cost by country / Durchschnittliche Behandlungskosten nach Land
SELECT p.Herkunftsland, AVG(b.Gesamtkosten_EUR) AS durchschnittliche_kosten
FROM patienten p
JOIN behandlungsverlaeufe b ON p.Patienten_ID = b.Patienten_ID
GROUP BY p.Herkunftsland;

-- 5. Staff workload analysis / Arbeitsbelastung des Personals analysieren
SELECT bp.Vorname, bp.Nachname, COUNT(b.Behandlungs_ID) AS anzahl_behandlungen
FROM begleitpersonal bp
LEFT JOIN behandlungsverlaeufe b ON bp.Mitarbeiter_ID = b.Mitarbeiter_ID
GROUP BY bp.Mitarbeiter_ID, bp.Vorname, bp.Nachname;

-- 6. Most expensive treatments by category / Teuerste Behandlungen nach Kategorie
SELECT ml.Kategorie, MAX(b.Gesamtkosten_EUR) AS max_kosten
FROM medizinische_leistungen ml
JOIN behandlungsverlaeufe b ON ml.Leistungs_ID = b.Leistungs_ID
GROUP BY ml.Kategorie;

-- 7. Patients with multiple treatments / Patienten mit mehreren Behandlungen
SELECT p.Vorname, p.Nachname, COUNT(b.Behandlungs_ID) AS anzahl_behandlungen
FROM patienten p
JOIN behandlungsverlaeufe b ON p.Patienten_ID = b.Patienten_ID
GROUP BY p.Patienten_ID, p.Vorname, p.Nachname
HAVING COUNT(b.Behandlungs_ID) > 1;

-- 8. Revenue by treatment location / Umsatz nach Behandlungsort
SELECT b.Behandlungsort, SUM(b.Gesamtkosten_EUR) AS gesamtumsatz
FROM behandlungsverlaeufe b
GROUP BY b.Behandlungsort
ORDER BY gesamtumsatz DESC;

-- 9. Treatments requiring follow-up care / Behandlungen mit erforderlicher Nachsorge
SELECT p.Nachname, ml.Leistungsname, b.Nachsorge_erforderlich
FROM behandlungsverlaeufe b
JOIN patienten p ON b.Patienten_ID = p.Patienten_ID
JOIN medizinische_leistungen ml ON b.Leistungs_ID = ml.Leistungs_ID
WHERE b.Nachsorge_erforderlich = 'Ja';

-- 10. Age groups and treatment preferences / Altersgruppen und Behandlungspräferenzen
SELECT
	ml.Kategorie,
	CASE
		WHEN p.Alter_bei_Anmeldung < 30 THEN "Under 30"
        WHEN p.Alter_bei_Anmeldung BETWEEN 30 AND 50 THEN "30-50"
        WHEN p.Alter_bei_Anmeldung BETWEEN 51 AND 70 THEN "51-70"
        ELSE "Over 70"
    END AS age_groups,
	COUNT(*) AS treatment_counts
FROM patienten p   
JOIN behandlungsverlaeufe bv 
	ON bv.Patienten_ID = p.Patienten_ID
JOIN medizinische_leistungen ml
	ON bv.Leistungs_ID = ml.Leistungs_ID
GROUP BY age_groups, ml.Kategorie
ORDER BY ml.Kategorie, age_groups, treatment_counts DESC;

-- 11. Monthly treatment volume / Monatliches Behandlungsvolumen
SELECT 
    YEAR(b.Behandlungsdatum) AS jahr,
    MONTH(b.Behandlungsdatum) AS monat,
    COUNT(*) AS anzahl_behandlungen
FROM behandlungsverlaeufe b
GROUP BY YEAR(b.Behandlungsdatum), MONTH(b.Behandlungsdatum)
ORDER BY jahr, monat;

-- 12. Patient satisfaction by service category / Patientenzufriedenheit nach Leistungskategorie
SELECT ml.Kategorie, b.Patientenzufriedenheit, COUNT(*) AS anzahl
FROM behandlungsverlaeufe b
JOIN medizinische_leistungen ml ON b.Leistungs_ID = ml.Leistungs_ID
GROUP BY ml.Kategorie, b.Patientenzufriedenheit;

-- 13. Treatment duration vs cost analysis / Behandlungsdauer vs. Kostenanalyse
SELECT 
    ml.Dauer_Stunden,
    AVG(b.Gesamtkosten_EUR) AS durchschnittliche_kosten,
    COUNT(*) AS anzahl_behandlungen
FROM medizinische_leistungen ml
JOIN behandlungsverlaeufe b ON ml.Leistungs_ID = b.Leistungs_ID
GROUP BY ml.Dauer_Stunden
ORDER BY ml.Dauer_Stunden;

-- 14. Patients without treatments / Patienten ohne Behandlungen
SELECT p.Vorname, p.Nachname, p.Anmeldedatum
FROM patienten p
LEFT JOIN behandlungsverlaeufe b ON p.Patienten_ID = b.Patienten_ID
WHERE b.Patienten_ID IS NULL;

-- 15. Top 10 most expensive individual treatments / Top 10 teuerste Einzelbehandlungen
SELECT 
    p.Nachname,
    ml.Leistungsname,
    b.Gesamtkosten_EUR,
    b.Behandlungsdatum
FROM behandlungsverlaeufe b
JOIN patienten p ON b.Patienten_ID = p.Patienten_ID
JOIN medizinische_leistungen ml ON b.Leistungs_ID = ml.Leistungs_ID
ORDER BY b.Gesamtkosten_EUR DESC
LIMIT 10;

-- 16. Insurance type distribution by country / Versicherungstyp-Verteilung nach Land
SELECT 
    p.Herkunftsland,
    p.Versicherungstyp,
    COUNT(*) AS anzahl_patienten
FROM patienten p
GROUP BY p.Herkunftsland, p.Versicherungstyp
ORDER BY p.Herkunftsland, anzahl_patienten DESC;

-- 17. Treatment complications by service type / Behandlungskomplikationen nach Leistungstyp
SELECT 
    ml.Kategorie,
    SUM(CASE WHEN b.Komplikationen = 'Ja' THEN 1 ELSE 0 END) AS mit_komplikationen,
    COUNT(*) AS gesamt_behandlungen,
    (SUM(CASE WHEN b.Komplikationen = 'Ja' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS komplikationsrate
FROM behandlungsverlaeufe b
JOIN medizinische_leistungen ml ON b.Leistungs_ID = ml.Leistungs_ID
GROUP BY ml.Kategorie;

-- 18. Seasonal treatment patterns / Saisonale Behandlungsmuster
SELECT 
    QUARTER(b.Behandlungsdatum) AS quartal,
    ml.Kategorie,
    COUNT(*) AS anzahl_behandlungen
FROM behandlungsverlaeufe b
JOIN medizinische_leistungen ml ON b.Leistungs_ID = ml.Leistungs_ID
GROUP BY QUARTER(b.Behandlungsdatum), ml.Kategorie
ORDER BY quartal, anzahl_behandlungen DESC;

-- 19. Average interpreter hours by language / Durchschnittliche Dolmetscherstunden nach Sprache
SELECT 
    p.Sprache,
    AVG(b.Dolmetscherstunden) AS durchschnittliche_dolmetscherstunden,
    COUNT(*) AS anzahl_behandlungen
FROM patienten p
JOIN behandlungsverlaeufe b ON p.Patienten_ID = b.Patienten_ID
GROUP BY p.Sprache;

-- 20. Treatment cost breakdown / Aufschlüsselung der Behandlungskosten
SELECT 
    AVG(b.Leistungskosten_EUR) AS durchschnittliche_leistungskosten,
    AVG(b.Dolmetscherkosten_EUR) AS durchschnittliche_dolmetscherkosten,
    AVG(b.Transportkosten_EUR) AS durchschnittliche_transportkosten,
    AVG(b.Unterkunftskosten_EUR) AS durchschnittliche_unterkunftskosten,
    AVG(b.Zusatzkosten_EUR) AS durchschnittliche_zusatzkosten
FROM behandlungsverlaeufe b;
