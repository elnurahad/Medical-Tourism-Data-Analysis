-- =====================================================
-- BASIC SQL QUERIES (40 queries)
-- Medical Tourism Database 
-- Grundlegende SQL-Abfragen für medizinische Tourismusdatenbank
-- =====================================================

-- 1. Select all patients / Alle Patienten auswählen
SELECT * FROM patienten;

-- 2. Count total number of patients / Gesamtzahl der Patienten zählen
SELECT COUNT(*) AS total_patients FROM patienten;

-- 3. Show all medical services / Alle medizinischen Leistungen anzeigen
SELECT * FROM medizinische_leistungen;

-- 4. List all staff members / Alle Mitarbeiter auflisten
SELECT Vorname, Nachname, Status FROM begleitpersonal;

-- 5. Show patients from Russia / Patienten aus Russland anzeigen
SELECT * FROM patienten WHERE Herkunftsland = 'Russland';

-- 6. Find patients older than 50 / Patienten über 50 Jahre finden
SELECT Vorname, Nachname, Alter_bei_Anmeldung FROM patienten WHERE Alter_bei_Anmeldung > 50;

-- 7. Show all cardiology services / Alle kardiologischen Leistungen anzeigen
SELECT * FROM medizinische_leistungen WHERE Kategorie = 'Kardiologie';

-- 8. List female patients / Weibliche Patienten auflisten
SELECT * FROM patienten WHERE Geschlecht = 'W';

-- 9. Show services costing more than 25000 EUR / Leistungen über 25000 EUR anzeigen
SELECT Leistungsname, Kosten_EUR FROM medizinische_leistungen WHERE Kosten_EUR > 25000;

-- 10. Find active staff members / Aktive Mitarbeiter finden
SELECT * FROM begleitpersonal WHERE Status = 'Aktiv';

-- 11. Show patients with private insurance / Patienten mit Privatversicherung anzeigen
SELECT * FROM patienten WHERE Versicherungstyp = 'Privat';

-- 12. List treatments in Berlin / Behandlungen in Berlin auflisten
SELECT * FROM behandlungsverlaeufe WHERE Behandlungsort = 'Berlin';

-- 13. Show completed treatments / Abgeschlossene Behandlungen anzeigen
SELECT * FROM behandlungsverlaeufe WHERE Status = 'Abgeschlossen';

-- 14. Find accommodations in Munich / Unterkünfte in München finden
SELECT * FROM unterkuenfte WHERE Stadt = 'Munich';

-- 15. Show 5-star hotels / 5-Sterne-Hotels anzeigen
SELECT * FROM unterkuenfte WHERE Sterne = 5;

-- 16. List patients by registration date / Patienten nach Anmeldedatum sortieren
SELECT * FROM patienten ORDER BY Anmeldedatum;

-- 17. Show most expensive services / Teuerste Leistungen anzeigen
SELECT * FROM medizinische_leistungen ORDER BY Kosten_EUR DESC;

-- 18. Find youngest patients / Jüngste Patienten finden
SELECT * FROM patienten ORDER BY Alter_bei_Anmeldung ASC LIMIT 10;

-- 19. Show staff with highest hourly rate / Mitarbeiter mit höchstem Stundenlohn anzeigen
SELECT * FROM begleitpersonal ORDER BY Stundenlohn_EUR DESC;

-- 20. List treatments by total cost / Behandlungen nach Gesamtkosten sortieren
SELECT * FROM behandlungsverlaeufe ORDER BY Gesamtkosten_EUR DESC;

-- 21. Count patients by country / Patienten nach Land zählen
SELECT Herkunftsland, COUNT(*) AS anzahl_patienten FROM patienten GROUP BY Herkunftsland;

-- 22. Average age of patients / Durchschnittsalter der Patienten
SELECT AVG(Alter_bei_Anmeldung) AS durchschnittsalter FROM patienten;

-- 23. Total cost of all services / Gesamtkosten aller Leistungen
SELECT SUM(Kosten_EUR) AS gesamtkosten FROM medizinische_leistungen;

-- 24. Count treatments by status / Behandlungen nach Status zählen
SELECT Status, COUNT(*) AS anzahl FROM behandlungsverlaeufe GROUP BY Status;

-- 25. Maximum service cost / Maximale Leistungskosten
SELECT MAX(Kosten_EUR) AS max_kosten FROM medizinische_leistungen;

-- 26. Minimum patient age / Minimales Patientenalter
SELECT MIN(Alter_bei_Anmeldung) AS min_alter FROM patienten;

-- 27. Count services by category / Leistungen nach Kategorie zählen
SELECT Kategorie, COUNT(*) AS anzahl_leistungen FROM medizinische_leistungen GROUP BY Kategorie;

-- 28. Average treatment duration / Durchschnittliche Behandlungsdauer
SELECT AVG(Dauer_Stunden) AS durchschnittsdauer FROM medizinische_leistungen;

-- 29. Count patients by gender / Patienten nach Geschlecht zählen
SELECT Geschlecht, COUNT(*) AS anzahl FROM patienten GROUP BY Geschlecht;

-- 30. Show unique countries / Eindeutige Länder anzeigen
SELECT DISTINCT Herkunftsland FROM patienten;

-- 31. List unique treatment locations / Eindeutige Behandlungsorte auflisten
SELECT DISTINCT Behandlungsort FROM behandlungsverlaeufe;

-- 32. Show unique service categories / Eindeutige Leistungskategorien anzeigen
SELECT DISTINCT Kategorie FROM medizinische_leistungen;

-- 33. Count accommodations by type / Unterkünfte nach Typ zählen
SELECT Typ, COUNT(*) AS anzahl FROM unterkuenfte GROUP BY Typ;

-- 34. Average accommodation price / Durchschnittlicher Unterkunftspreis
SELECT AVG(Preis_pro_Nacht_EUR) AS durchschnittspreis FROM unterkuenfte;

-- 35. Show patients with university education / Patienten mit Hochschulbildung anzeigen
SELECT * FROM patienten WHERE Bildungsgrad = 'Hochschulabschluss';

-- 36. Find treatments requiring anesthesia / Behandlungen mit Narkose finden
SELECT ml.Leistungsname, ml.Narkose_erforderlich 
FROM medizinische_leistungen ml 
WHERE ml.Narkose_erforderlich = 'Ja';

-- 37. Show married patients / Verheiratete Patienten anzeigen
SELECT * FROM patienten WHERE Familienstand = 'Verheiratet';

-- 38. List premium quality services / Premium-Qualitätsleistungen auflisten
SELECT * FROM medizinische_leistungen WHERE Qualitaetsstufe = 'Premium';

-- 39. Show treatments with complications / Behandlungen mit Komplikationen anzeigen
SELECT * FROM behandlungsverlaeufe WHERE Komplikationen = 'Ja';

-- 40. Find satisfied patients / Zufriedene Patienten finden
SELECT * FROM behandlungsverlaeufe WHERE Patientenzufriedenheit = 'Zufrieden';
