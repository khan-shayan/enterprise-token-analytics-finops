"""
Generates synthetic enterprise LLM API gateway logs and downstream business outcomes
(Zendesk, GitHub, Salesforce, Ironclad) for the Token Analytics & FinOps ROI portfolio project.
"""
import os
import numpy as np
import pandas as pd

def generate_datasets(output_dir="data", n_sessions=600, seed=42):
    np.random.seed(seed)
    os.makedirs(output_dir, exist_ok=True)
    
    depts = [
        ("Customer Support", "Zendesk Auto-Resolution", "ticket_resolved", 35.0, 15.0, 0.78),
        ("Software Engineering", "PR Review & Test Gen", "pr_merged", 85.0, 120.0, 0.82),
        ("Growth & Sales", "Outbound SDR Enrichment", "lead_qualified", 55.0, 90.0, 0.64),
        ("Legal & Compliance", "NDA & MSA Redlining", "contract_reviewed", 120.0, 120.0, 0.88),
    ]
    models_pricing = {
        "gpt-4o": (2.50, 1.25, 10.00),
        "claude-3-5-sonnet": (3.00, 0.30, 15.00),
        "claude-3-5-haiku": (0.80, 0.08, 4.00),
        "gemini-2.5-flash": (0.15, 0.0375, 0.60),
    }

    llm_logs, outcomes = [], []
    req_counter = 10000

    for session_idx in range(1, n_sessions + 1):
        session_id = f"sess_{session_idx:04d}"
        dept, workflow, outcome_type, wage, mins_saved, success_prob = depts[session_idx % 4]
        is_runaway = (session_idx % 23 == 0)
        num_steps = np.random.randint(11, 16) if is_runaway else np.random.randint(1, 4)

        if dept in ["Software Engineering", "Legal & Compliance"]:
            model = np.random.choice(["claude-3-5-sonnet", "gpt-4o"], p=[0.65, 0.35])
        else:
            model = np.random.choice(["gpt-4o", "claude-3-5-haiku", "gemini-2.5-flash"], p=[0.55, 0.25, 0.20])

        complexity = np.random.choice(
            ["simple_classification", "multi_hop_reasoning", "code_or_legal_synthesis"],
            p=[0.45, 0.35, 0.20]
        )
        in_rate, cache_rate, out_rate = models_pricing[model]

        for step in range(1, num_steps + 1):
            req_counter += 1
            uncached_in = int(np.random.randint(1800, 9500))
            cached_in = int(np.random.randint(0, 1200) if (session_idx % 7 == 0) else np.random.randint(2000, 8500))
            out_tok = int(np.random.randint(350, 2200))
            cost = (uncached_in / 1e6) * in_rate + (cached_in / 1e6) * cache_rate + (out_tok / 1e6) * out_rate

            llm_logs.append({
                "request_id": f"req_{req_counter}",
                "session_id": session_id,
                "timestamp": f"2027-01-{(session_idx % 28) + 1:02d}T10:{(step*7)%60:02d}:00Z",
                "department": dept,
                "workflow_name": workflow,
                "model_name": model,
                "prompt_complexity_tier": complexity,
                "agent_step_number": step,
                "input_tokens": uncached_in,
                "cached_input_tokens": cached_in,
                "output_tokens": out_tok,
                "latency_ms": int(np.random.randint(420, 3800)),
                "status_code": 200,
                "call_cost_usd": round(cost, 6)
            })

        achieved = False if is_runaway else (np.random.rand() < success_prob)
        outcomes.append({
            "session_id": session_id,
            "outcome_id": f"out_{session_idx:04d}",
            "department": dept,
            "outcome_type": outcome_type,
            "outcome_achieved": achieved,
            "human_escalation_required": not achieved,
            "minutes_saved_estimate": mins_saved if achieved else 0.0,
            "hourly_loaded_wage_usd": wage
        })

    pd.DataFrame(llm_logs).to_csv(os.path.join(output_dir, "raw_llm_api_logs.csv"), index=False)
    pd.DataFrame(outcomes).to_csv(os.path.join(output_dir, "raw_business_outcomes.csv"), index=False)
    print(f"Generated {len(llm_logs)} LLM API log events across {len(outcomes)} sessions.")

if __name__ == "__main__":
    generate_datasets()
