-- =====================================================
-- INTERMEDIATE SQL QUERIES Part 2 (Queries 21-40)
-- Medical Tourism Database 
-- =====================================================

-- 21. Patient demographics by education level
SELECT 
    p.Bildungsgrad,
    AVG(p.Alter_bei_Anmeldung) AS durchschnittsalter,
    COUNT(*) AS anzahl_patienten
FROM patienten p
GROUP BY p.Bildungsgrad;

-- 22. Treatment success rate by staff member
SELECT 
    bp.Vorname,
    bp.Nachname,
    SUM(CASE WHEN b.Status = 'Abgeschlossen' THEN 1 ELSE 0 END) AS abgeschlossene_behandlungen,
    COUNT(*) AS gesamt_behandlungen
FROM begleitpersonal bp
JOIN behandlungsverlaeufe b ON bp.Mitarbeiter_ID = b.Mitarbeiter_ID
GROUP BY bp.Mitarbeiter_ID, bp.Vorname, bp.Nachname;

-- 23. Transportation preferences by country
SELECT 
    p.Herkunftsland,
    b.Transportart,
    COUNT(*) AS anzahl_behandlungen
FROM patienten p
JOIN behandlungsverlaeufe b ON p.Patienten_ID = b.Patienten_ID
GROUP BY p.Herkunftsland, b.Transportart
ORDER BY p.Herkunftsland, anzahl_behandlungen DESC;

-- 24. Medical reports by treatment status
SELECT 
    b.Status,
    mr.Berichtstyp,
    COUNT(*) AS anzahl_berichte
FROM behandlungsverlaeufe b
JOIN medizinische_berichte mr ON b.Behandlungs_ID = mr.Behandlungs_ID
GROUP BY b.Status, mr.Berichtstyp;

-- 25. Services requiring anesthesia analysis
SELECT 
    ml.Kategorie,
    SUM(CASE WHEN ml.Narkose_erforderlich = 'Ja' THEN 1 ELSE 0 END) AS mit_narkose,
    COUNT(*) AS gesamt_leistungen
FROM medizinische_leistungen ml
GROUP BY ml.Kategorie;

-- 26. Patient family history patterns
SELECT 
    p.Familienanamnese,
    ml.Kategorie,
    COUNT(*) AS anzahl_behandlungen
FROM patienten p
JOIN behandlungsverlaeufe b ON p.Patienten_ID = b.Patienten_ID
JOIN medizinische_leistungen ml ON b.Leistungs_ID = ml.Leistungs_ID
GROUP BY p.Familienanamnese, ml.Kategorie;

-- 27. Treatment timeline analysis
SELECT 
    p.Nachname,
    b.Anfragedatum,
    b.Beratungsdatum,
    b.Behandlungsdatum,
    b.Abschlussdatum
FROM patienten p
JOIN behandlungsverlaeufe b ON p.Patienten_ID = b.Patienten_ID
WHERE b.Behandlungsdatum IS NOT NULL;

-- 28. Cost efficiency by service complexity
SELECT 
    ml.Komplexitaet,
    AVG(b.Gesamtkosten_EUR) AS durchschnittliche_kosten,
    COUNT(*) AS anzahl_behandlungen
FROM medizinische_leistungen ml
JOIN behandlungsverlaeufe b ON ml.Leistungs_ID = b.Leistungs_ID
GROUP BY ml.Komplexitaet;

-- 29. Patient retention analysis
SELECT 
    p.Herkunftsland,
    COUNT(DISTINCT p.Patienten_ID) AS eindeutige_patienten,
    COUNT(b.Behandlungs_ID) AS gesamt_behandlungen
FROM patienten p
LEFT JOIN behandlungsverlaeufe b ON p.Patienten_ID = b.Patienten_ID
GROUP BY p.Herkunftsland;

-- 30. Quality level vs patient satisfaction
SELECT 
    ml.Qualitaetsstufe,
    b.Patientenzufriedenheit,
    COUNT(*) AS anzahl_behandlungen,
    AVG(b.Gesamtkosten_EUR) AS durchschnittliche_kosten
FROM medizinische_leistungen ml
JOIN behandlungsverlaeufe b ON ml.Leistungs_ID = b.Leistungs_ID
GROUP BY ml.Qualitaetsstufe, b.Patientenzufriedenheit;

-- 31. Staff language skills utilization
SELECT 
    bp.Sprachkombination,
    COUNT(b.Behandlungs_ID) AS anzahl_behandlungen,
    AVG(b.Dolmetscherstunden) AS durchschnittliche_stunden
FROM begleitpersonal bp
JOIN behandlungsverlaeufe b ON bp.Mitarbeiter_ID = b.Mitarbeiter_ID
GROUP BY bp.Sprachkombination;

-- 32. Treatment type by age and gender
SELECT 
    p.Geschlecht,
    CASE 
        WHEN p.Alter_bei_Anmeldung < 40 THEN 'Jung'
        WHEN p.Alter_bei_Anmeldung BETWEEN 40 AND 60 THEN 'Mittleres Alter'
        ELSE 'Aelter'
    END AS altersgruppe,
    ml.Kategorie,
    COUNT(*) AS anzahl_behandlungen
FROM patienten p
JOIN behandlungsverlaeufe b ON p.Patienten_ID = b.Patienten_ID
JOIN medizinische_leistungen ml ON b.Leistungs_ID = ml.Leistungs_ID
GROUP BY p.Geschlecht, altersgruppe, ml.Kategorie;

-- 33. Follow-up care requirements by service
SELECT 
    ml.Leistungsname,
    ml.Nachsorge_erforderlich AS service_nachsorge,
    b.Nachsorge_erforderlich AS actual_nachsorge,
    COUNT(*) AS anzahl_behandlungen
FROM medizinische_leistungen ml
JOIN behandlungsverlaeufe b ON ml.Leistungs_ID = b.Leistungs_ID
GROUP BY ml.Leistungsname, ml.Nachsorge_erforderlich, b.Nachsorge_erforderlich;

-- 34. Revenue trends by quarter
SELECT 
    YEAR(b.Behandlungsdatum) AS jahr,
    QUARTER(b.Behandlungsdatum) AS quartal,
    SUM(b.Gesamtkosten_EUR) AS quartalsumsatz,
    COUNT(*) AS anzahl_behandlungen
FROM behandlungsverlaeufe b
WHERE b.Behandlungsdatum IS NOT NULL
GROUP BY YEAR(b.Behandlungsdatum), QUARTER(b.Behandlungsdatum)
ORDER BY jahr, quartal;

-- 35. Treatment complexity vs duration analysis
SELECT 
    ml.Komplexitaet,
    AVG(ml.Dauer_Stunden) AS durchschnittliche_dauer,
    AVG(b.Begleitungstage) AS durchschnittliche_begleitungstage,
    AVG(b.Gesamtkosten_EUR) AS durchschnittliche_kosten
FROM medizinische_leistungen ml
JOIN behandlungsverlaeufe b ON ml.Leistungs_ID = b.Leistungs_ID
GROUP BY ml.Komplexitaet;

-- 36. Patient education level vs treatment choices
SELECT 
    p.Bildungsgrad,
    ml.Qualitaetsstufe,
    COUNT(*) AS anzahl_behandlungen,
    AVG(b.Gesamtkosten_EUR) AS durchschnittliche_kosten
FROM patienten p
JOIN behandlungsverlaeufe b ON p.Patienten_ID = b.Patienten_ID
JOIN medizinische_leistungen ml ON b.Leistungs_ID = ml.Leistungs_ID
GROUP BY p.Bildungsgrad, ml.Qualitaetsstufe;

-- 37. Staff experience vs treatment outcomes
SELECT 
    bp.Berufserfahrung_Jahre,
    AVG(CASE WHEN b.Patientenzufriedenheit = 'Zufrieden' THEN 1 ELSE 0 END) AS zufriedenheitsrate,
    COUNT(*) AS anzahl_behandlungen
FROM begleitpersonal bp
JOIN behandlungsverlaeufe b ON bp.Mitarbeiter_ID = b.Mitarbeiter_ID
GROUP BY bp.Berufserfahrung_Jahre
ORDER BY bp.Berufserfahrung_Jahre;

-- 38. Treatment location preferences by insurance type
SELECT 
    p.Versicherungstyp,
    b.Behandlungsort,
    COUNT(*) AS anzahl_behandlungen,
    AVG(b.Gesamtkosten_EUR) AS durchschnittliche_kosten
FROM patienten p
JOIN behandlungsverlaeufe b ON p.Patienten_ID = b.Patienten_ID
GROUP BY p.Versicherungstyp, b.Behandlungsort
ORDER BY p.Versicherungstyp, anzahl_behandlungen DESC;

-- 39. Marital status impact on treatment decisions
SELECT 
    p.Familienstand,
    ml.Kategorie,
    COUNT(*) AS anzahl_behandlungen,
    AVG(b.Gesamtkosten_EUR) AS durchschnittliche_kosten
FROM patienten p
JOIN behandlungsverlaeufe b ON p.Patienten_ID = b.Patienten_ID
JOIN medizinische_leistungen ml ON b.Leistungs_ID = ml.Leistungs_ID
GROUP BY p.Familienstand, ml.Kategorie;

-- 40. Previous treatment experience impact
SELECT 
    p.Vorherige_Behandlung_Deutschland,
    AVG(b.Gesamtkosten_EUR) AS durchschnittliche_kosten,
    AVG(CASE WHEN b.Patientenzufriedenheit = 'Zufrieden' THEN 1 ELSE 0 END) AS zufriedenheitsrate,
    COUNT(*) AS anzahl_behandlungen
FROM patienten p
JOIN behandlungsverlaeufe b ON p.Patienten_ID = b.Patienten_ID
GROUP BY p.Vorherige_Behandlung_Deutschland;
