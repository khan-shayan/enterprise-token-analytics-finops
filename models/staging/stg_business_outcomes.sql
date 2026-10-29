-- models/staging/stg_business_outcomes.sql
-- Standardizes downstream business outcomes from Zendesk, GitHub, Salesforce, and Ironclad

SELECT
    session_id,
    outcome_id,
    department,
    outcome_type, -- 'ticket_resolved', 'pr_merged', 'lead_qualified', 'contract_reviewed'
    CAST(outcome_achieved AS BOOL) AS is_successful_outcome,
    CAST(human_escalation_required AS BOOL) AS human_escalation_required,
    CAST(minutes_saved_estimate AS FLOAT64) AS minutes_saved_estimate,
    CAST(hourly_loaded_wage_usd AS FLOAT64) AS hourly_loaded_wage_usd,
    ROUND((minutes_saved_estimate / 60.0) * hourly_loaded_wage_usd, 2) AS gross_labor_value_usd
FROM {{ source('enterprise_apps', 'raw_business_outcomes') }}
