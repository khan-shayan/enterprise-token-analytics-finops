-- models/marts/mart_team_ai_roi.sql
-- Executive FinOps Mart: Connects departmental AI token spend to verified business outcomes

WITH session_tokens AS (
    SELECT
        session_id,
        department,
        workflow_name,
        COUNT(request_id) AS llm_calls_in_session,
        MAX(agent_step_number) AS max_agent_depth,
        SUM(uncached_input_tokens) AS uncached_input_tokens,
        SUM(cached_input_tokens) AS cached_input_tokens,
        SUM(output_tokens) AS output_tokens,
        SUM(total_call_cost_usd) AS session_token_cost_usd,
        AVG(latency_ms) AS avg_call_latency_ms
    FROM {{ ref('stg_llm_api_logs') }}
    GROUP BY 1, 2, 3
),

joined_outcomes AS (
    SELECT
        s.*,
        o.outcome_type,
        COALESCE(o.is_successful_outcome, FALSE) AS is_successful_outcome,
        COALESCE(o.minutes_saved_estimate, 0) AS minutes_saved,
        COALESCE(o.gross_labor_value_usd, 0) AS gross_value_usd
    FROM session_tokens s
    LEFT JOIN {{ ref('stg_business_outcomes') }} o
        ON s.session_id = o.session_id
)

SELECT
    department,
    workflow_name,
    outcome_type,
    COUNT(DISTINCT session_id) AS total_ai_sessions,
    COUNT(DISTINCT CASE WHEN is_successful_outcome THEN session_id END) AS verified_outcomes_count,
    ROUND(SUM(session_token_cost_usd), 2) AS total_ai_spend_usd,
    ROUND(
        SAFE_DIVIDE(
            SUM(session_token_cost_usd),
            COUNT(DISTINCT CASE WHEN is_successful_outcome THEN session_id END)
        ),
        4
    ) AS cost_per_verified_outcome_usd,
    ROUND(
        SAFE_DIVIDE(
            SUM(cached_input_tokens),
            SUM(uncached_input_tokens + cached_input_tokens)
        ) * 100,
        1
    ) AS prompt_cache_hit_pct,
    ROUND(SUM(minutes_saved) / 60.0, 1) AS total_hours_saved,
    ROUND(SUM(gross_value_usd), 2) AS total_value_generated_usd,
    ROUND(SUM(gross_value_usd) - SUM(session_token_cost_usd), 2) AS net_dollar_savings_usd,
    ROUND(SAFE_DIVIDE(SUM(gross_value_usd), SUM(session_token_cost_usd)), 2) AS roi_multiple
FROM joined_outcomes
GROUP BY 1, 2, 3
ORDER BY total_ai_spend_usd DESC
