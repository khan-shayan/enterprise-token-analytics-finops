-- models/marts/mart_token_waste_anomalies.sql
-- Identifies runaway agent loops, uncached static system prompts, and over-provisioned frontier calls

WITH session_summary AS (
    SELECT
        session_id,
        department,
        workflow_name,
        model_name,
        prompt_complexity_tier,
        MAX(agent_step_number) AS max_step_depth,
        SUM(uncached_input_tokens) AS uncached_tokens,
        SUM(cached_input_tokens) AS cached_tokens,
        SUM(total_call_cost_usd) AS session_cost_usd
    FROM {{ ref('stg_llm_api_logs') }}
    GROUP BY 1, 2, 3, 4, 5
)

SELECT
    session_id,
    department,
    workflow_name,
    model_name,
    max_step_depth,
    session_cost_usd,
    CASE
        WHEN max_step_depth >= 10 THEN 'RUNAWAY_AGENT_LOOP'
        WHEN SAFE_DIVIDE(cached_tokens, uncached_tokens + cached_tokens) < 0.15
             AND (uncached_tokens + cached_tokens) > 8000 THEN 'LOW_PROMPT_CACHE_HIT'
        WHEN prompt_complexity_tier = 'simple_classification'
             AND model_name IN ('gpt-4o', 'claude-3-5-sonnet') THEN 'FRONTIER_MODEL_OVERKILL'
        ELSE 'HEALTHY'
    END AS anomaly_category
FROM session_summary
WHERE max_step_depth >= 10
   OR (SAFE_DIVIDE(cached_tokens, uncached_tokens + cached_tokens) < 0.15 AND (uncached_tokens + cached_tokens) > 8000)
   OR (prompt_complexity_tier = 'simple_classification' AND model_name IN ('gpt-4o', 'claude-3-5-sonnet'))
ORDER BY session_cost_usd DESC
