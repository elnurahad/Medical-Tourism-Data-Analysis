-- =====================================================
-- MASTER LEVEL SQL QUERIES (15 queries)
-- Medical Tourism Database 
-- =====================================================

-- 1. Advanced machine learning feature engineering for patient outcome prediction
-- Fortgeschrittenes Feature Engineering für maschinelles Lernen zur Prognose von Behandlungsergebnissen
WITH patient_features AS (
    SELECT 
        p.Patienten_ID,
        p.Alter_bei_Anmeldung,
        CASE WHEN p.Geschlecht = 'M' THEN 1 ELSE 0 END AS is_male,
        CASE WHEN p.Versicherungstyp = 'Privat' THEN 1 ELSE 0 END AS has_private_insurance,
        CASE WHEN p.Vorherige_Behandlung_Deutschland = 'Ja' THEN 1 ELSE 0 END AS has_previous_treatment,
        -- Country risk encoding based on historical success rates
        COALESCE(country_risk.risk_score, 0.5) AS country_risk_score,
        -- Family history encoding
        CASE 
            WHEN p.Familienanamnese LIKE '%Herz%' OR p.Familienanamnese LIKE '%Kardio%' THEN 1 
            ELSE 0 
        END AS family_cardiac_history,
        CASE 
            WHEN p.Familienanamnese LIKE '%Krebs%' OR p.Familienanamnese LIKE '%Tumor%' THEN 1 
            ELSE 0 
        END AS family_cancer_history,
        -- Education level encoding
        CASE 
            WHEN p.Bildungsgrad IN ('Hochschule', 'Universitaet') THEN 3
            WHEN p.Bildungsgrad = 'Abitur' THEN 2
            WHEN p.Bildungsgrad = 'Realschule' THEN 1
            ELSE 0
        END AS education_level
    FROM patienten p
    LEFT JOIN (
        SELECT 
            p2.Herkunftsland,
            AVG(CASE WHEN b2.Status = 'Abgeschlossen' THEN 1.0 ELSE 0.0 END) AS risk_score
        FROM patienten p2
        JOIN behandlungsverlaeufe b2 ON p2.Patienten_ID = b2.Patienten_ID
        GROUP BY p2.Herkunftsland
    ) country_risk ON p.Herkunftsland = country_risk.Herkunftsland
),
treatment_complexity_features AS (
    SELECT 
        b.Patienten_ID,
        b.Behandlungs_ID,
        ml.Kategorie,
        -- Treatment complexity scoring
        CASE 
            WHEN ml.Komplexitaet = 'Sehr hoch' THEN 4
            WHEN ml.Komplexitaet = 'Hoch' THEN 3
            WHEN ml.Komplexitaet = 'Mittel' THEN 2
            ELSE 1
        END AS complexity_score,
        -- Duration risk factor
        CASE 
            WHEN ml.Dauer_Stunden > 10 THEN 3
            WHEN ml.Dauer_Stunden > 5 THEN 2
            ELSE 1
        END AS duration_risk,
        -- Anesthesia risk
        CASE WHEN ml.Narkose_erforderlich = 'Ja' THEN 1 ELSE 0 END AS anesthesia_risk,
        -- Cost percentile within category
        PERCENT_RANK() OVER (PARTITION BY ml.Kategorie ORDER BY b.Gesamtkosten_EUR) AS cost_percentile,
        -- Staff experience factor
        bp.Berufserfahrung_Jahre / 20.0 AS staff_experience_factor,
        -- Language barrier indicator
        CASE WHEN p.Sprache != 'Deutsch' AND bp.Sprachkombination NOT LIKE '%' || p.Sprache || '%' 
             THEN 1 ELSE 0 END AS language_barrier,
        -- Seasonal factor
        CASE 
            WHEN strftime('%m', b.Behandlungsdatum) IN ('12', '01', '02') THEN 'Winter'
            WHEN strftime('%m', b.Behandlungsdatum) IN ('03', '04', '05') THEN 'Spring'
            WHEN strftime('%m', b.Behandlungsdatum) IN ('06', '07', '08') THEN 'Summer'
            ELSE 'Autumn'
        END AS treatment_season
    FROM behandlungsverlaeufe b
    JOIN medizinische_leistungen ml ON b.Leistungs_ID = ml.Leistungs_ID
    JOIN begleitpersonal bp ON b.Mitarbeiter_ID = bp.Mitarbeiter_ID
    JOIN patienten p ON b.Patienten_ID = p.Patienten_ID
    WHERE b.Behandlungsdatum IS NOT NULL
),
outcome_features AS (
    SELECT 
        pf.*,
        tcf.*,
        -- Historical patient patterns
        LAG(tcf.complexity_score, 1) OVER (PARTITION BY pf.Patienten_ID ORDER BY b.Behandlungsdatum) AS prev_complexity,
        COUNT(*) OVER (PARTITION BY pf.Patienten_ID ORDER BY b.Behandlungsdatum ROWS UNBOUNDED PRECEDING) AS treatment_sequence_number,
        -- Interaction features
        pf.Alter_bei_Anmeldung * tcf.complexity_score AS age_complexity_interaction,
        pf.country_risk_score * tcf.duration_risk AS country_duration_risk,
        -- Target variable
        CASE 
            WHEN b.Status = 'Abgeschlossen' AND b.Patientenzufriedenheit = 'Zufrieden' THEN 1
            ELSE 0
        END AS successful_outcome
    FROM patient_features pf
    JOIN treatment_complexity_features tcf ON pf.Patienten_ID = tcf.Patienten_ID
    JOIN behandlungsverlaeufe b ON tcf.Behandlungs_ID = b.Behandlungs_ID
)
SELECT * FROM outcome_features
WHERE successful_outcome IS NOT NULL
ORDER BY Patienten_ID, treatment_sequence_number;

-- 2. Dynamic pricing optimization with elasticity analysis
-- Dynamische Preisoptimierung mit Elastizitätsanalyse
WITH price_elasticity_analysis AS (
    SELECT 
        ml.Kategorie,
        ml.Leistungsname,
        -- Price segments
        NTILE(10) OVER (PARTITION BY ml.Kategorie ORDER BY b.Gesamtkosten_EUR) AS price_decile,
        COUNT(*) AS demand_volume,
        AVG(b.Gesamtkosten_EUR) AS avg_price,
        STDDEV(b.Gesamtkosten_EUR) AS price_stddev,
        -- Quality metrics
        AVG(CASE WHEN b.Patientenzufriedenheit = 'Zufrieden' THEN 1.0 ELSE 0.0 END) AS satisfaction_rate,
        AVG(CASE WHEN b.Status = 'Abgeschlossen' THEN 1.0 ELSE 0.0 END) AS completion_rate,
        -- Time-based demand patterns
        AVG(CASE WHEN strftime('%m', b.Behandlungsdatum) IN ('06', '07', '08') THEN 1.0 ELSE 0.0 END) AS summer_demand_ratio,
        -- Patient characteristics
        AVG(p.Alter_bei_Anmeldung) AS avg_patient_age,
        COUNT(CASE WHEN p.Versicherungstyp = 'Privat' THEN 1 END) * 100.0 / COUNT(*) AS private_insurance_pct,
        -- Geographic demand
        COUNT(DISTINCT p.Herkunftsland) AS country_diversity,
        -- Competition proxy (similar treatments in same category)
        COUNT(*) OVER (PARTITION BY ml.Kategorie) AS category_competition
    FROM medizinische_leistungen ml
    JOIN behandlungsverlaeufe b ON ml.Leistungs_ID = b.Leistungs_ID
    JOIN patienten p ON b.Patienten_ID = p.Patienten_ID
    WHERE b.Behandlungsdatum >= '2020-01-01'
    AND b.Status IN ('Abgeschlossen', 'Abgebrochen')
    GROUP BY ml.Kategorie, ml.Leistungsname, 
             NTILE(10) OVER (PARTITION BY ml.Kategorie ORDER BY b.Gesamtkosten_EUR)
),
elasticity_calculations AS (
    SELECT 
        Kategorie,
        Leistungsname,
        price_decile,
        demand_volume,
        avg_price,
        satisfaction_rate,
        completion_rate,
        -- Price elasticity approximation
        CASE 
            WHEN LAG(avg_price) OVER (PARTITION BY Kategorie, Leistungsname ORDER BY price_decile) IS NOT NULL
            THEN (
                (demand_volume - LAG(demand_volume) OVER (PARTITION BY Kategorie, Leistungsname ORDER BY price_decile)) * 100.0 / 
                NULLIF(LAG(demand_volume) OVER (PARTITION BY Kategorie, Leistungsname ORDER BY price_decile), 0)
            ) / (
                (avg_price - LAG(avg_price) OVER (PARTITION BY Kategorie, Leistungsname ORDER BY price_decile)) * 100.0 / 
                NULLIF(LAG(avg_price) OVER (PARTITION BY Kategorie, Leistungsname ORDER BY price_decile), 0)
            )
            ELSE NULL
        END AS price_elasticity,
        -- Revenue optimization metrics
        demand_volume * avg_price AS revenue,
        demand_volume * avg_price * satisfaction_rate AS quality_adjusted_revenue,
        -- Market positioning
        RANK() OVER (PARTITION BY Kategorie ORDER BY avg_price) AS price_rank_in_category,
        RANK() OVER (PARTITION BY Kategorie ORDER BY satisfaction_rate DESC) AS quality_rank_in_category
    FROM price_elasticity_analysis
)
SELECT 
    *,
    -- Optimal pricing recommendations
    CASE 
        WHEN price_elasticity > -0.5 AND satisfaction_rate > 0.8 THEN 'Increase Price'
        WHEN price_elasticity < -2.0 AND satisfaction_rate < 0.6 THEN 'Decrease Price'
        WHEN price_elasticity BETWEEN -2.0 AND -0.5 THEN 'Optimize Quality'
        ELSE 'Maintain Current Strategy'
    END AS pricing_recommendation,
    -- Revenue potential
    CASE 
        WHEN price_rank_in_category <= 3 AND quality_rank_in_category <= 3 THEN 'Premium Positioning'
        WHEN price_rank_in_category >= 8 AND quality_rank_in_category >= 8 THEN 'Budget Positioning'
        ELSE 'Mid-Market Positioning'
    END AS market_positioning
FROM elasticity_calculations
WHERE price_elasticity IS NOT NULL
ORDER BY Kategorie, revenue DESC;
