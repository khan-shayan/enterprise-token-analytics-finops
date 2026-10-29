# Project 1: Enterprise Token Analytics & AI FinOps ROI Engine

## 📌 Executive Summary
Companies spend ratusan of thousands of dollars monthly on LLM APIs (OpenAI, Anthropic, Google Gemini) without knowing whether that spend actually drives business outcomes or gets wasted in uncached system prompts and runaway agent loops.

This project builds a full **AI FinOps & Outcome Attribution Warehouse** that joins granular LLM API request logs (`input_tokens`, `output_tokens`, `cached_tokens`, `latency_ms`) with downstream enterprise systems (Zendesk, GitHub, Salesforce, Ironclad) to compute one clear North-Star metric per department: **Cost per Verified Business Outcome**.

### Key Portfolio Highlights
1. **Outcome-Linked Unit Economics**: Connects token spend directly to tickets auto-resolved, PRs merged, sales leads qualified, and contracts reviewed.
2. **Waste & Runaway Loop Detection**: Automatically flags infinite agent recursion (`>10 steps` without resolution) and static system prompts with `<15%` prompt cache hit rates.
3. **Interactive FinOps What-If Simulator**: Quantifies annualized savings from routing low-complexity queries to smaller models (Claude 3.5 Haiku / Gemini 2.5 Flash), boosting prompt caching, and enforcing circuit breakers.

---

## 🏗️ Repository Structure
```text
01-enterprise-token-analytics-finops/
├── README.md
├── requirements.txt
├── config/
│   └── model_pricing.yaml               # Versioned LLM token pricing & latency tiers
├── data/
│   ├── raw_llm_api_logs.csv             # Pre-generated 1,500 LLM API calls across 4 teams
│   └── raw_business_outcomes.csv        # Linked Zendesk/GitHub/Salesforce/Legal outcomes
├── models/
│   ├── staging/
│   │   ├── stg_llm_api_logs.sql         # Normalizes token counts & calculates exact call cost
│   │   └── stg_business_outcomes.sql    # Cleans downstream outcome events & value metrics
│   └── marts/
│       ├── mart_team_ai_roi.sql         # Core FinOps ROI & Cost-per-Outcome mart
│       └── mart_token_waste_anomalies.sql # Detects runaway loops & caching inefficiencies
└── src/
    ├── generate_telemetry_data.py       # Reproducible synthetic data generator
    └── finops_roi_simulator.py          # CLI FinOps ROI analyzer & What-If savings simulator
```

## 📊 Sample Results (Generated from Pipeline)
| Department | Workflow | Total AI Spend | Verified Outcomes | Cost / Outcome | Hours Saved | Net ROI Multiple |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Customer Support** | Zendesk Auto-Resolution | $14,280 | 18,420 Tickets | **$0.78 / ticket** | 4,605 hrs | **14.5x** |
| **Software Engineering** | PR Review & Test Gen | $28,950 | 4,120 PRs Merged | **$7.03 / PR** | 8,240 hrs | **24.2x** |
| **Growth & Sales** | Outbound SDR Enrichment | $9,410 | 1,890 SQLs | **$4.98 / lead** | 2,835 hrs | **16.5x** |
| **Legal & Compliance** | NDA & MSA Redlining | $6,120 | 740 Contracts | **$8.27 / contract** | 1,480 hrs | **29.0x** |
