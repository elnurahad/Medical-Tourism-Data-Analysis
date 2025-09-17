-- =====================================================
-- MEDICAL TOURISM DATABASE SCHEMA
-- MEDIZINTOURISMUS-DATENBANK SCHEMA
-- Based on real German medical tourism data
-- Basierend auf echten deutschen Medizintourismus-Daten
-- =====================================================

DROP DATABASE IF EXISTS medizintourismus;
CREATE DATABASE medizintourismus CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE medizintourismus;

-- =====================================================
-- TABLE 1: PATIENTS / PATIENTEN
-- =====================================================
CREATE TABLE patienten (
    Patienten_ID VARCHAR(10) PRIMARY KEY,
    Vorname VARCHAR(50) NOT NULL,
    Nachname VARCHAR(50) NOT NULL,
    Herkunftsland VARCHAR(50) NOT NULL,
    Alter_bei_Anmeldung INT NOT NULL,
    Geschlecht ENUM('M', 'W') NOT NULL,
    Anmeldedatum DATE NOT NULL,
    Sprache VARCHAR(30) NOT NULL,
    Vorherige_Behandlung_Deutschland ENUM('Ja', 'Nein') NOT NULL,
    Versicherungstyp ENUM('Privat', 'Gesetzlich', 'Ausland', 'Selbstzahler') NOT NULL,
    Familienanamnese VARCHAR(100),
    Familienstand ENUM('Ledig', 'Verheiratet', 'Geschieden', 'Verwitwet') NOT NULL,
    Bildungsgrad ENUM('Grundschule', 'Hauptschule', 'Realschule', 'Abitur', 'Studium') NOT NULL,
    Berufsstatus ENUM('Angestellt', 'Selbststaendig', 'Rentner', 'Arbeitslos', 'Student') NOT NULL,
    INDEX idx_herkunftsland (Herkunftsland),
    INDEX idx_anmeldedatum (Anmeldedatum),
    INDEX idx_versicherungstyp (Versicherungstyp)
);

-- =====================================================
-- TABLE 2: MEDICAL SERVICES / MEDIZINISCHE LEISTUNGEN
-- =====================================================
CREATE TABLE medizinische_leistungen (
    Leistungs_ID VARCHAR(10) PRIMARY KEY,
    Leistungsname VARCHAR(100) NOT NULL,
    Kategorie VARCHAR(50) NOT NULL,
    Kosten_EUR DECIMAL(10,2) NOT NULL,
    Dauer_Stunden INT NOT NULL,
    Behandlungsart ENUM('Ambulant', 'Stationaer', 'Tagesklinik') NOT NULL,
    Nachsorge_erforderlich ENUM('Ja', 'Nein') NOT NULL,
    Qualitaetsstufe ENUM('Standard', 'Premium') NOT NULL,
    Komplexitaet ENUM('Niedrig', 'Mittel', 'Hoch') NOT NULL,
    Narkose_erforderlich ENUM('Ja', 'Nein') NOT NULL,
    Nachsorge_Tage INT DEFAULT 0,
    INDEX idx_kategorie (Kategorie),
    INDEX idx_kosten (Kosten_EUR),
    INDEX idx_qualitaetsstufe (Qualitaetsstufe)
);

-- =====================================================
-- TABLE 3: STAFF / BEGLEITPERSONAL
-- =====================================================
CREATE TABLE begleitpersonal (
    Mitarbeiter_ID VARCHAR(10) PRIMARY KEY,
    Vorname VARCHAR(50) NOT NULL,
    Nachname VARCHAR(50) NOT NULL,
    Geschlecht ENUM('M', 'W') NOT NULL,
    Sprachkombination VARCHAR(50) NOT NULL,
    Verfuegbarkeit ENUM('Vollzeit', 'Teilzeit') NOT NULL,
    Stundenlohn_EUR DECIMAL(6,2) NOT NULL,
    Status ENUM('Aktiv', 'Inaktiv') NOT NULL,
    Einstellungsjahr YEAR NOT NULL,
    Berufserfahrung_Jahre INT NOT NULL,
    Qualifikation VARCHAR(100) NOT NULL,
    Fuehrerscheinklasse VARCHAR(10),
    Medizinische_Grundkenntnisse ENUM('Ja', 'Nein') NOT NULL,
    Patienten_pro_Jahr INT DEFAULT 0,
    Durchschnittsbewertung DECIMAL(3,2) DEFAULT 0.00,
    INDEX idx_qualifikation (Qualifikation),
    INDEX idx_verfuegbarkeit (Verfuegbarkeit),
    INDEX idx_bewertung (Durchschnittsbewertung)
);

-- =====================================================
-- TABLE 4: TREATMENT PROCESSES / BEHANDLUNGSVERLÄUFE
-- =====================================================
CREATE TABLE behandlungsverlaeufe (
    Behandlungs_ID VARCHAR(10) PRIMARY KEY,
    Patienten_ID VARCHAR(10) NOT NULL,
    Leistungs_ID VARCHAR(10) NOT NULL,
    Mitarbeiter_ID VARCHAR(10) NOT NULL,
    Anfragedatum DATE NOT NULL,
    Beratungsdatum DATE,
    Behandlungsdatum DATE,
    Abschlussdatum DATE,
    Status ENUM('Anfrage', 'Beratung_geplant', 'Behandlung_geplant', 'Behandlung_laufend', 'Behandlung_abgeschlossen', 'Abgeschlossen', 'Storniert') NOT NULL,
    Behandlungsort VARCHAR(50) NOT NULL,
    Transportart ENUM('PKW', 'Taxi', 'Oeffentlich', 'Flugzeug', 'Zug') NOT NULL,
    Begleitungstage INT DEFAULT 0,
    Dolmetscherstunden DECIMAL(5,1) DEFAULT 0.0,
    Leistungskosten_EUR DECIMAL(10,2) NOT NULL,
    Dolmetscherkosten_EUR DECIMAL(8,2) DEFAULT 0.00,
    Transportkosten_EUR DECIMAL(8,2) DEFAULT 0.00,
    Unterkunftskosten_EUR DECIMAL(8,2) DEFAULT 0.00,
    Zusatzkosten_EUR DECIMAL(8,2) DEFAULT 0.00,
    Gesamtkosten_EUR DECIMAL(10,2) NOT NULL,
    Komplikationen ENUM('Ja', 'Nein') NOT NULL,
    Patientenzufriedenheit ENUM('Sehr_zufrieden', 'Zufrieden', 'Neutral', 'Unzufrieden', 'Sehr_unzufrieden') NOT NULL,
    Nachsorge_erforderlich ENUM('Ja', 'Nein', 'Teilweise') NOT NULL,
    FOREIGN KEY (Patienten_ID) REFERENCES patienten(Patienten_ID),
    FOREIGN KEY (Leistungs_ID) REFERENCES medizinische_leistungen(Leistungs_ID),
    FOREIGN KEY (Mitarbeiter_ID) REFERENCES begleitpersonal(Mitarbeiter_ID),
    INDEX idx_behandlungsdatum (Behandlungsdatum),
    INDEX idx_status (Status),
    INDEX idx_gesamtkosten (Gesamtkosten_EUR),
    INDEX idx_zufriedenheit (Patientenzufriedenheit)
);

-- =====================================================
-- TABLE 5: ACCOMMODATIONS / UNTERKÜNFTE
-- =====================================================
CREATE TABLE unterkuenfte (
    Unterkunft_ID VARCHAR(10) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Stadt VARCHAR(50) NOT NULL,
    Typ ENUM('Hotel', 'Pension', 'Apartment', 'Klinik') NOT NULL,
    Sterne INT CHECK (Sterne BETWEEN 1 AND 5),
    Preis_pro_Nacht_EUR DECIMAL(6,2) NOT NULL,
    Medizinische_Betreuung ENUM('Ja', 'Nein') NOT NULL,
    Russischsprachiges_Personal ENUM('Ja', 'Nein') NOT NULL,
    Transfer_Service ENUM('Ja', 'Nein') NOT NULL,
    Kuechenzeile_verfuegbar ENUM('Ja', 'Nein') NOT NULL,
    Anzahl_Zimmer INT NOT NULL,
    INDEX idx_stadt (Stadt),
    INDEX idx_preis (Preis_pro_Nacht_EUR),
    INDEX idx_sterne (Sterne)
);

-- =====================================================
-- TABLE 6: MEDICAL REPORTS / MEDIZINISCHE BERICHTE
-- =====================================================
CREATE TABLE medizinische_berichte (
    Bericht_ID VARCHAR(10) PRIMARY KEY,
    Behandlungs_ID VARCHAR(10) NOT NULL,
    Berichtstyp ENUM('Laborergebnisse', 'Radiologischer_Befund', 'Arztbrief', 'Entlassungsbericht', 'Nachsorgebericht') NOT NULL,
    Erstellungsdatum DATE NOT NULL,
    Sprache ENUM('Deutsch', 'Russisch', 'Englisch') NOT NULL,
    Format ENUM('PDF', 'DOC', 'Papier') NOT NULL,
    An_Patient_gesendet ENUM('Ja', 'Nein') NOT NULL,
    Befund_Status ENUM('Unauffaellig', 'Auffaellig', 'Kontrollbeduertig') NOT NULL,
    FOREIGN KEY (Behandlungs_ID) REFERENCES behandlungsverlaeufe(Behandlungs_ID),
    INDEX idx_berichtstyp (Berichtstyp),
    INDEX idx_erstellungsdatum (Erstellungsdatum),
    INDEX idx_sprache (Sprache)
);

-- =====================================================
-- SAMPLE DATA LOADING COMMANDS
-- BEISPIEL-DATENLADE-BEFEHLE
-- =====================================================
-- Use these commands to load your CSV data:
-- Verwenden Sie diese Befehle zum Laden Ihrer CSV-Daten:

/*
LOAD DATA INFILE 'patienten.csv'
INTO TABLE patienten
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'medizinische_leistungen.csv'
INTO TABLE medizinische_leistungen
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'begleitpersonal_erweitert.csv'
INTO TABLE begleitpersonal
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'behandlungsverlaeufe.csv'
INTO TABLE behandlungsverlaeufe
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'unterkuenfte.csv'
INTO TABLE unterkuenfte
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'medizinische_berichte.csv'
INTO TABLE medizinische_berichte
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
*/

-- =====================================================
-- DATABASE STATISTICS / DATENBANKSTATISTIKEN
-- =====================================================
-- Total records in database / Gesamtanzahl Datensätze:
-- Patients: 12,200 / Patienten: 12.200
-- Medical Services: 80 / Medizinische Leistungen: 80
-- Staff: 10 / Personal: 10
-- Treatments: 8,750 / Behandlungen: 8.750
-- Accommodations: 10 / Unterkünfte: 10
-- Medical Reports: 5,000 / Medizinische Berichte: 5.000
-- =====================================================
