-- models/staging/stg_llm_api_logs.sql
-- Normalizes raw LLM gateway telemetry and computes exact call-level cost in USD

WITH raw_logs AS (
    SELECT
        request_id,
        session_id,
        CAST(timestamp AS TIMESTAMP) AS requested_at,
        department,
        workflow_name,
        model_name,
        prompt_Complexity_tier,
        agent_step_number,
        CAST(input_tokens AS INT64) AS uncached_input_tokens,
        CAST(cached_input_tokens AS INT64) AS cached_input_tokens,
        CAST(output_tokens AS INT64) AS output_tokens,
        CAST(latency_ms AS INT64) AS latency_ms,
        status_code
    FROM {{ source('ai_gateway', 'raw_llm_api_logs') }}
),

pricing AS (
    SELECT 'gpt-4o' AS model_name, 2.50 AS in_rate, 1.25 AS cache_rate, 10.00 AS out_rate UNION ALL
    SELECT 'claude-3-5-sonnet', 3.00, 0.30, 15.00 UNION ALL
    SELECT 'claude-3-5-haiku', 0.80, 0.08, 4.00 UNION ALL
    SELECT 'gemini-2.5-flash', 0.15, 0.0375, 0.60
)

SELECT
    l.*,
    (l.uncached_input_tokens + l.cached_input_tokens) AS total_input_tokens,
    SAFE_DIVIDE(l.cached_input_tokens, (l.uncached_input_tokens + l.cached_input_tokens)) AS prompt_cache_hit_rate,
    ROUND(
        (l.uncached_input_tokens / 1e6) * p.in_rate +
        (l.cached_input_tokens / 1e6) * p.cache_rate +
        (l.output_tokens / 1e6) * p.out_rate,
        6
    ) AS total_call_cost_usd
FROM raw_logs l
LEFT JOIN pricing p
    ON l.model_name = p.model_name
