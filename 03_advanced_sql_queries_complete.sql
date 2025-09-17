-- =====================================================
-- ADVANCED SQL QUERIES (15 queries)
-- Medical Tourism Database 
-- =====================================================

-- 1. Complex patient journey analysis with multiple CTEs
-- Komplexe Analyse des Patientenpfads mit mehreren CTEs
WITH patient_stats AS (
    SELECT 
        p.Patienten_ID,
        p.Herkunftsland,
        p.Alter_bei_Anmeldung,
        COUNT(b.Behandlungs_ID) AS total_treatments,
        AVG(b.Gesamtkosten_EUR) AS avg_cost,
        MIN(b.Anfragedatum) AS first_inquiry,
        MAX(b.Abschlussdatum) AS last_completion
    FROM patienten p
    LEFT JOIN behandlungsverlaeufe b ON p.Patienten_ID = b.Patienten_ID
    GROUP BY p.Patienten_ID, p.Herkunftsland, p.Alter_bei_Anmeldung
),
country_benchmarks AS (
    SELECT 
        Herkunftsland,
        AVG(total_treatments) AS country_avg_treatments,
        AVG(avg_cost) AS country_avg_cost
    FROM patient_stats
    GROUP BY Herkunftsland
)
SELECT 
    ps.*,
    cb.country_avg_treatments,
    cb.country_avg_cost,
    CASE 
        WHEN ps.total_treatments > cb.country_avg_treatments THEN 'Above Average'
        WHEN ps.total_treatments = cb.country_avg_treatments THEN 'Average'
        ELSE 'Below Average'
    END AS treatment_frequency_category
FROM patient_stats ps
JOIN country_benchmarks cb ON ps.Herkunftsland = cb.Herkunftsland
WHERE ps.total_treatments > 0;

-- 2. Window functions for ranking and running totals
-- Fensterfunktionen für Rangfolgen und kumulierte Summen
SELECT 
    p.Herkunftsland,
    p.Nachname,
    b.Behandlungsdatum,
    b.Gesamtkosten_EUR,
    ROW_NUMBER() OVER (PARTITION BY p.Herkunftsland ORDER BY b.Gesamtkosten_EUR DESC) AS cost_rank_in_country,
    RANK() OVER (ORDER BY b.Gesamtkosten_EUR DESC) AS overall_cost_rank,
    SUM(b.Gesamtkosten_EUR) OVER (PARTITION BY p.Herkunftsland ORDER BY b.Behandlungsdatum) AS running_total_by_country,
    LAG(b.Gesamtkosten_EUR, 1) OVER (PARTITION BY p.Patienten_ID ORDER BY b.Behandlungsdatum) AS previous_treatment_cost,
    LEAD(b.Behandlungsdatum, 1) OVER (PARTITION BY p.Patienten_ID ORDER BY b.Behandlungsdatum) AS next_treatment_date
FROM patienten p
JOIN behandlungsverlaeufe b ON p.Patienten_ID = b.Patienten_ID
WHERE b.Behandlungsdatum IS NOT NULL;

-- 3. Advanced pivot analysis using conditional aggregation
-- Fortgeschrittene Pivot-Analyse mit bedingter Aggregation
SELECT 
    p.Herkunftsland,
    COUNT(*) AS total_patients,
    SUM(CASE WHEN p.Geschlecht = 'M' THEN 1 ELSE 0 END) AS male_patients,
    SUM(CASE WHEN p.Geschlecht = 'W' THEN 1 ELSE 0 END) AS female_patients,
    SUM(CASE WHEN p.Alter_bei_Anmeldung < 30 THEN 1 ELSE 0 END) AS young_patients,
    SUM(CASE WHEN p.Alter_bei_Anmeldung BETWEEN 30 AND 60 THEN 1 ELSE 0 END) AS middle_age_patients,
    SUM(CASE WHEN p.Alter_bei_Anmeldung > 60 THEN 1 ELSE 0 END) AS senior_patients,
    SUM(CASE WHEN p.Versicherungstyp = 'Privat' THEN 1 ELSE 0 END) AS private_insurance,
    SUM(CASE WHEN p.Versicherungstyp = 'Gesetzlich' THEN 1 ELSE 0 END) AS public_insurance,
    SUM(CASE WHEN p.Versicherungstyp = 'Selbstzahler' THEN 1 ELSE 0 END) AS self_pay,
    ROUND(AVG(CASE WHEN b.Gesamtkosten_EUR IS NOT NULL THEN b.Gesamtkosten_EUR END), 2) AS avg_treatment_cost
FROM patienten p
LEFT JOIN behandlungsverlaeufe b ON p.Patienten_ID = b.Patienten_ID
GROUP BY p.Herkunftsland
HAVING COUNT(*) >= 100
ORDER BY total_patients DESC;

-- 4. Complex subquery with EXISTS and correlated subqueries
-- Komplexe Unterabfrage mit EXISTS und korrelierten Unterabfragen
SELECT 
    p.Patienten_ID,
    p.Vorname,
    p.Nachname,
    p.Herkunftsland,
    (SELECT COUNT(*) FROM behandlungsverlaeufe b1 WHERE b1.Patienten_ID = p.Patienten_ID) AS total_treatments,
    (SELECT AVG(b2.Gesamtkosten_EUR) FROM behandlungsverlaeufe b2 WHERE b2.Patienten_ID = p.Patienten_ID) AS avg_cost
FROM patienten p
WHERE EXISTS (
    SELECT 1 FROM behandlungsverlaeufe b3 
    WHERE b3.Patienten_ID = p.Patienten_ID 
    AND b3.Gesamtkosten_EUR > (
        SELECT AVG(b4.Gesamtkosten_EUR) * 1.5
        FROM behandlungsverlaeufe b4
        JOIN patienten p2 ON b4.Patienten_ID = p2.Patienten_ID
        WHERE p2.Herkunftsland = p.Herkunftsland
    )
)
AND NOT EXISTS (
    SELECT 1 FROM behandlungsverlaeufe b5
    WHERE b5.Patienten_ID = p.Patienten_ID
    AND b5.Status = 'Abgebrochen'
);

-- 5. Advanced date calculations and temporal analysis
-- Fortgeschrittene Datumsberechnungen und zeitliche Analysen
SELECT 
    strftime('%Y', b.Behandlungsdatum) AS treatment_year,
    strftime('%m', b.Behandlungsdatum) AS treatment_month,
    COUNT(*) AS treatments_count,
    AVG(julianday(b.Behandlungsdatum) - julianday(b.Anfragedatum)) AS avg_days_inquiry_to_treatment,
    AVG(julianday(b.Abschlussdatum) - julianday(b.Behandlungsdatum)) AS avg_days_treatment_to_completion,
    AVG(b.Gesamtkosten_EUR) AS avg_cost,
    MIN(b.Gesamtkosten_EUR) AS min_cost,
    MAX(b.Gesamtkosten_EUR) AS max_cost
FROM behandlungsverlaeufe b
WHERE b.Behandlungsdatum IS NOT NULL
AND b.Behandlungsdatum >= '2015-01-01'
GROUP BY strftime('%Y', b.Behandlungsdatum), strftime('%m', b.Behandlungsdatum)
ORDER BY treatment_year, treatment_month;

-- 6. Complex multi-table join with advanced filtering
-- Komplexes Join mehrerer Tabellen mit fortgeschrittener Filterung
SELECT 
    p.Herkunftsland,
    ml.Kategorie,
    bp.Sprachkombination,
    COUNT(DISTINCT p.Patienten_ID) AS unique_patients,
    COUNT(b.Behandlungs_ID) AS total_treatments,
    AVG(b.Gesamtkosten_EUR) AS avg_cost,
    SUM(b.Dolmetscherkosten_EUR) AS total_interpreter_costs,
    AVG(b.Begleitungstage) AS avg_accompaniment_days
FROM patienten p
JOIN behandlungsverlaeufe b ON p.Patienten_ID = b.Patienten_ID
JOIN medizinische_leistungen ml ON b.Leistungs_ID = ml.Leistungs_ID
JOIN begleitpersonal bp ON b.Mitarbeiter_ID = bp.Mitarbeiter_ID
LEFT JOIN medizinische_berichte mr ON b.Behandlungs_ID = mr.Behandlungs_ID
WHERE b.Status = 'Abgeschlossen'
AND b.Behandlungsdatum BETWEEN '2015-01-01' AND '2023-12-31'
AND ml.Komplexitaet IN ('Hoch', 'Sehr hoch')
GROUP BY p.Herkunftsland, ml.Kategorie, bp.Sprachkombination
HAVING COUNT(b.Behandlungs_ID) >= 5
ORDER BY total_treatments DESC;

-- 7. Advanced statistical analysis with variance calculations
-- Fortgeschrittener statistischer Analyse mit Varianzberechnung
WITH cost_stats AS (
    SELECT 
        p.Herkunftsland,
        ml.Kategorie,
        COUNT(*) AS treatment_count,
        AVG(b.Gesamtkosten_EUR) AS mean_cost,
        MIN(b.Gesamtkosten_EUR) AS min_cost,
        MAX(b.Gesamtkosten_EUR) AS max_cost,
        AVG(b.Gesamtkosten_EUR * b.Gesamtkosten_EUR) - (AVG(b.Gesamtkosten_EUR) * AVG(b.Gesamtkosten_EUR)) AS variance_cost
    FROM patienten p
    JOIN behandlungsverlaeufe b ON p.Patienten_ID = b.Patienten_ID
    JOIN medizinische_leistungen ml ON b.Leistungs_ID = ml.Leistungs_ID
    WHERE b.Gesamtkosten_EUR IS NOT NULL
    GROUP BY p.Herkunftsland, ml.Kategorie
    HAVING COUNT(*) >= 10
)
SELECT 
    *,
    SQRT(variance_cost) AS std_dev_cost,
    CASE 
        WHEN SQRT(variance_cost) / mean_cost < 0.2 THEN 'Low Variability'
        WHEN SQRT(variance_cost) / mean_cost BETWEEN 0.2 AND 0.5 THEN 'Medium Variability'
        ELSE 'High Variability'
    END AS cost_variability_category,
    max_cost - min_cost AS cost_range
FROM cost_stats
ORDER BY variance_cost DESC;

-- 8. Patient cohort analysis with retention metrics
-- Kohortenanalyse von Patienten mit Retentionsmetriken
WITH patient_cohorts AS (
    SELECT 
        p.Patienten_ID,
        p.Herkunftsland,
        strftime('%Y-%m', p.Anmeldedatum) AS registration_cohort,
        MIN(b.Behandlungsdatum) AS first_treatment_date,
        MAX(b.Behandlungsdatum) AS last_treatment_date,
        COUNT(b.Behandlungs_ID) AS total_treatments,
        SUM(b.Gesamtkosten_EUR) AS total_spent
    FROM patienten p
    LEFT JOIN behandlungsverlaeufe b ON p.Patienten_ID = b.Patienten_ID
    GROUP BY p.Patienten_ID, p.Herkunftsland, strftime('%Y-%m', p.Anmeldedatum)
),
cohort_metrics AS (
    SELECT 
        registration_cohort,
        Herkunftsland,
        COUNT(*) AS cohort_size,
        COUNT(CASE WHEN total_treatments > 0 THEN 1 END) AS active_patients,
        COUNT(CASE WHEN total_treatments > 1 THEN 1 END) AS repeat_patients,
        AVG(total_treatments) AS avg_treatments_per_patient,
        AVG(total_spent) AS avg_revenue_per_patient,
        AVG(julianday(last_treatment_date) - julianday(first_treatment_date)) AS avg_patient_lifespan_days
    FROM patient_cohorts
    GROUP BY registration_cohort, Herkunftsland
)
SELECT 
    *,
    ROUND(100.0 * active_patients / cohort_size, 2) AS activation_rate_percent,
    ROUND(100.0 * repeat_patients / NULLIF(active_patients, 0), 2) AS retention_rate_percent
FROM cohort_metrics
WHERE cohort_size >= 10
ORDER BY registration_cohort, Herkunftsland;

-- 9. Treatment outcome prediction model data preparation
-- Datenvorbereitung für das Prognosemodell der Behandlungsergebnisse
SELECT 
    p.Patienten_ID,
    p.Alter_bei_Anmeldung,
    p.Geschlecht,
    p.Herkunftsland,
    p.Versicherungstyp,
    p.Bildungsgrad,
    p.Familienanamnese,
    ml.Kategorie AS treatment_category,
    ml.Komplexitaet AS treatment_complexity,
    ml.Dauer_Stunden AS treatment_duration,
    ml.Narkose_erforderlich AS anesthesia_required,
    bp.Berufserfahrung_Jahre AS staff_experience,
    bp.Sprachkombination AS language_support,
    b.Begleitungstage AS accompaniment_days,
    b.Dolmetscherstunden AS interpreter_hours,
    b.Transportart AS transport_type,
    b.Behandlungsort AS treatment_location,
    CASE 
        WHEN b.Status = 'Abgeschlossen' AND b.Patientenzufriedenheit = 'Zufrieden' THEN 1
        ELSE 0
    END AS successful_outcome,
    b.Gesamtkosten_EUR AS total_cost,
    julianday(b.Behandlungsdatum) - julianday(b.Anfragedatum) AS days_to_treatment,
    CASE WHEN b.Nachsorge_erforderlich = 'Ja' THEN 1 ELSE 0 END AS followup_required
FROM patienten p
JOIN behandlungsverlaeufe b ON p.Patienten_ID = b.Patienten_ID
JOIN medizinische_leistungen ml ON b.Leistungs_ID = ml.Leistungs_ID
JOIN begleitpersonal bp ON b.Mitarbeiter_ID = bp.Mitarbeiter_ID
WHERE b.Status IN ('Abgeschlossen', 'Abgebrochen')
AND b.Behandlungsdatum IS NOT NULL;

-- 10. Revenue optimization analysis with price elasticity
-- Umsatzoptimierungsanalyse mit Preiselastizität
WITH price_segments AS (
    SELECT 
        ml.Kategorie,
        ml.Leistungsname,
        NTILE(5) OVER (PARTITION BY ml.Kategorie ORDER BY b.Gesamtkosten_EUR) AS price_quintile,
        COUNT(*) AS treatment_count,
        AVG(b.Gesamtkosten_EUR) AS avg_price,
        SUM(b.Gesamtkosten_EUR) AS total_revenue,
        AVG(CASE WHEN b.Patientenzufriedenheit = 'Zufrieden' THEN 1.0 ELSE 0.0 END) AS satisfaction_rate
    FROM medizinische_leistungen ml
    JOIN behandlungsverlaeufe b ON ml.Leistungs_ID = b.Leistungs_ID
    WHERE b.Status = 'Abgeschlossen'
    AND b.Gesamtkosten_EUR IS NOT NULL
    GROUP BY ml.Kategorie, ml.Leistungsname, 
             NTILE(5) OVER (PARTITION BY ml.Kategorie ORDER BY b.Gesamtkosten_EUR)
)
SELECT 
    Kategorie,
    price_quintile,
    COUNT(*) AS service_count,
    SUM(treatment_count) AS total_treatments,
    AVG(avg_price) AS avg_price_in_quintile,
    SUM(total_revenue) AS quintile_revenue,
    AVG(satisfaction_rate) AS avg_satisfaction_rate,
    SUM(total_revenue) / SUM(treatment_count) AS revenue_per_treatment
FROM price_segments
GROUP BY Kategorie, price_quintile
ORDER BY Kategorie, price_quintile;

-- 11. Geographic clustering analysis with distance calculations
-- Geografische Clusteranalyse mit Distanzberechnung
WITH country_treatment_patterns AS (
    SELECT 
        p.Herkunftsland,
        ml.Kategorie,
        COUNT(*) AS treatment_frequency,
        AVG(b.Gesamtkosten_EUR) AS avg_cost,
        AVG(b.Begleitungstage) AS avg_stay_duration
    FROM patienten p
    JOIN behandlungsverlaeufe b ON p.Patienten_ID = b.Patienten_ID
    JOIN medizinische_leistungen ml ON b.Leistungs_ID = ml.Leistungs_ID
    WHERE b.Status = 'Abgeschlossen'
    GROUP BY p.Herkunftsland, ml.Kategorie
),
country_profiles AS (
    SELECT 
        Herkunftsland,
        SUM(CASE WHEN Kategorie = 'Kardiologie' THEN treatment_frequency ELSE 0 END) AS cardiology_freq,
        SUM(CASE WHEN Kategorie = 'Onkologie' THEN treatment_frequency ELSE 0 END) AS oncology_freq,
        SUM(CASE WHEN Kategorie = 'Orthopaedie' THEN treatment_frequency ELSE 0 END) AS orthopedics_freq,
        SUM(CASE WHEN Kategorie = 'Neurologie' THEN treatment_frequency ELSE 0 END) AS neurology_freq,
        AVG(avg_cost) AS overall_avg_cost,
        AVG(avg_stay_duration) AS overall_avg_stay
    FROM country_treatment_patterns
    GROUP BY Herkunftsland
)
SELECT 
    c1.Herkunftsland AS country1,
    c2.Herkunftsland AS country2,
    SQRT(
        (c1.cardiology_freq - c2.cardiology_freq) * (c1.cardiology_freq - c2.cardiology_freq) +
        (c1.oncology_freq - c2.oncology_freq) * (c1.oncology_freq - c2.oncology_freq) +
        (c1.orthopedics_freq - c2.orthopedics_freq) * (c1.orthopedics_freq - c2.orthopedics_freq) +
        (c1.neurology_freq - c2.neurology_freq) * (c1.neurology_freq - c2.neurology_freq)
    ) AS treatment_pattern_distance,
    ABS(c1.overall_avg_cost - c2.overall_avg_cost) AS cost_difference,
    ABS(c1.overall_avg_stay - c2.overall_avg_stay) AS stay_difference
FROM country_profiles c1
CROSS JOIN country_profiles c2
WHERE c1.Herkunftsland < c2.Herkunftsland
ORDER BY treatment_pattern_distance;

-- 12. Advanced time series analysis with moving averages
-- Fortgeschrittene Zeitreihenanalyse mit gleitenden Durchschnitten
WITH monthly_metrics AS (
    SELECT 
        strftime('%Y-%m', b.Behandlungsdatum) AS month_year,
        COUNT(*) AS monthly_treatments,
        AVG(b.Gesamtkosten_EUR) AS monthly_avg_cost,
        SUM(b.Gesamtkosten_EUR) AS monthly_revenue,
        COUNT(DISTINCT p.Herkunftsland) AS countries_served
    FROM behandlungsverlaeufe b
    JOIN patienten p ON b.Patienten_ID = p.Patienten_ID
    WHERE b.Behandlungsdatum IS NOT NULL
    AND b.Status = 'Abgeschlossen'
    GROUP BY strftime('%Y-%m', b.Behandlungsdatum)
),
moving_averages AS (
    SELECT 
        month_year,
        monthly_treatments,
        monthly_avg_cost,
        monthly_revenue,
        countries_served,
        AVG(monthly_treatments) OVER (
            ORDER BY month_year 
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS ma3_treatments,
        AVG(monthly_revenue) OVER (
            ORDER BY month_year 
            ROWS BETWEEN 5 PRECEDING AND CURRENT ROW
        ) AS ma6_revenue,
        LAG(monthly_treatments, 1) OVER (ORDER BY month_year) AS prev_month_treatments
    FROM monthly_metrics
)
SELECT 
    *,
    CASE 
        WHEN prev_month_treatments IS NOT NULL THEN 
            ROUND(100.0 * (monthly_treatments - prev_month_treatments) / prev_month_treatments, 2)
        ELSE NULL 
    END AS mom_growth_rate
FROM moving_averages
ORDER BY month_year;

-- 13. Complex patient segmentation with RFM analysis
-- Komplexe Patientensegmentierung mit RFM-Analyse
WITH patient_rfm AS (
    SELECT 
        p.Patienten_ID,
        p.Herkunftsland,
        p.Versicherungstyp,
        MAX(julianday('2023-12-31') - julianday(b.Behandlungsdatum)) AS recency_days,
        COUNT(b.Behandlungs_ID) AS frequency,
        SUM(b.Gesamtkosten_EUR) AS monetary_value,
        AVG(b.Gesamtkosten_EUR) AS avg_treatment_value
    FROM patienten p
    JOIN behandlungsverlaeufe b ON p.Patienten_ID = b.Patienten_ID
    WHERE b.Status = 'Abgeschlossen'
    AND b.Behandlungsdatum IS NOT NULL
    GROUP BY p.Patienten_ID, p.Herkunftsland, p.Versicherungstyp
),
rfm_scores AS (
    SELECT 
        *,
        NTILE(5) OVER (ORDER BY recency_days) AS recency_score,
        NTILE(5) OVER (ORDER BY frequency DESC) AS frequency_score,
        NTILE(5) OVER (ORDER BY monetary_value DESC) AS monetary_score
    FROM patient_rfm
),
rfm_segments AS (
    SELECT 
        *,
        CASE 
            WHEN frequency_score >= 4 AND monetary_score >= 4 THEN 'Champions'
            WHEN recency_score >= 3 AND frequency_score >= 3 AND monetary_score >= 3 THEN 'Loyal Customers'
            WHEN recency_score >= 4 AND frequency_score <= 2 THEN 'New Customers'
            WHEN recency_score >= 3 AND frequency_score <= 2 AND monetary_score >= 3 THEN 'Potential Loyalists'
            WHEN recency_score <= 2 AND frequency_score >= 3 THEN 'At Risk'
            WHEN recency_score <= 2 AND frequency_score <= 2 AND monetary_score >= 3 THEN 'Cannot Lose Them'
            WHEN recency_score <= 2 AND frequency_score <= 2 AND monetary_score <= 2 THEN 'Lost Customers'
            ELSE 'Others'
        END AS rfm_segment
    FROM rfm_scores
)
SELECT 
    rfm_segment,
    Herkunftsland,
    Versicherungstyp,
    COUNT(*) AS patient_count,
    AVG(recency_days) AS avg_recency,
    AVG(frequency) AS avg_frequency,
    AVG(monetary_value) AS avg_monetary_value,
    SUM(monetary_value) AS total_revenue
FROM rfm_segments
GROUP BY rfm_segment, Herkunftsland, Versicherungstyp
ORDER BY total_revenue DESC;

-- 14. Treatment pathway optimization with sequence mining
-- Optimierung von Behandlungspfaden mit Sequenzanalyse
WITH treatment_sequences AS (
    SELECT 
        b.Patienten_ID,
        b.Behandlungs_ID,
        ml.Kategorie,
        ml.Leistungsname,
        b.Behandlungsdatum,
        ROW_NUMBER() OVER (PARTITION BY b.Patienten_ID ORDER BY b.Behandlungsdatum) AS sequence_order,
        LEAD(ml.Kategorie, 1) OVER (PARTITION BY b.Patienten_ID ORDER BY b.Behandlungsdatum) AS next_category,
        LEAD(b.Behandlungsdatum, 1) OVER (PARTITION BY b.Patienten_ID ORDER BY b.Behandlungsdatum) AS next_treatment_date,
        b.Gesamtkosten_EUR,
        b.Status
    FROM behandlungsverlaeufe b
    JOIN medizinische_leistungen ml ON b.Leistungs_ID = ml.Leistungs_ID
    WHERE b.Behandlungsdatum IS NOT NULL
),
pathway_analysis AS (
    SELECT 
        Kategorie AS current_category,
        next_category,
        COUNT(*) AS transition_count,
        AVG(julianday(next_treatment_date) - julianday(Behandlungsdatum)) AS avg_days_between,
        AVG(Gesamtkosten_EUR) AS avg_current_cost,
        COUNT(CASE WHEN Status = 'Abgeschlossen' THEN 1 END) AS successful_transitions,
        COUNT(CASE WHEN Status = 'Abgebrochen' THEN 1 END) AS failed_transitions
    FROM treatment_sequences
    WHERE next_category IS NOT NULL
    GROUP BY Kategorie, next_category
    HAVING COUNT(*) >= 5
)
SELECT 
    *,
    ROUND(100.0 * successful_transitions / (successful_transitions + failed_transitions), 2) AS success_rate,
    ROUND(transition_count * 100.0 / SUM(transition_count) OVER (PARTITION BY current_category), 2) AS transition_probability
FROM pathway_analysis
ORDER BY current_category, transition_count DESC;

-- 15. Predictive churn analysis with survival metrics
-- Prognostische Churn-Analyse mit Überlebensmetriken
WITH patient_activity AS (
    SELECT 
        p.Patienten_ID,
        p.Anmeldedatum,
        p.Herkunftsland,
        p.Alter_bei_Anmeldung,
        p.Versicherungstyp,
        MIN(b.Behandlungsdatum) AS first_treatment,
        MAX(b.Behandlungsdatum) AS last_treatment,
        COUNT(b.Behandlungs_ID) AS total_treatments,
        SUM(b.Gesamtkosten_EUR) AS total_spent
    FROM patienten p
    LEFT JOIN behandlungsverlaeufe b ON p.Patienten_ID = b.Patienten_ID
    WHERE b.Status = 'Abgeschlossen'
    GROUP BY p.Patienten_ID, p.Anmeldedatum, p.Herkunftsland, p.Alter_bei_Anmeldung, p.Versicherungstyp
),
churn_indicators AS (
    SELECT 
        *,
        julianday('2023-12-31') - julianday(last_treatment) AS days_since_last_treatment,
        CASE 
            WHEN julianday('2023-12-31') - julianday(last_treatment) > 365 THEN 1 
            ELSE 0 
        END AS churned,
        CASE 
            WHEN total_treatments = 1 THEN 'One-time'
            WHEN total_treatments BETWEEN 2 AND 5 THEN 'Occasional'
            WHEN total_treatments > 5 THEN 'Frequent'
        END AS usage_pattern
    FROM patient_activity
    WHERE first_treatment IS NOT NULL
)
SELECT 
    Herkunftsland,
    Versicherungstyp,
    usage_pattern,
    COUNT(*) AS patient_count,
    SUM(churned) AS churned_patients,
    ROUND(100.0 * SUM(churned) / COUNT(*), 2) AS churn_rate,
    AVG(days_since_last_treatment) AS avg_days_since_last_treatment,
    AVG(total_spent) AS avg_lifetime_value,
    AVG(total_treatments) AS avg_treatments_per_patient
FROM churn_indicators
GROUP BY Herkunftsland, Versicherungstyp, usage_pattern
HAVING COUNT(*) >= 10
ORDER BY churn_rate DESC;
