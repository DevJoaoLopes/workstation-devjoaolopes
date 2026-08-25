#!/usr/bin/env python3
import sys
import json
import subprocess
import select
from datetime import datetime

# ANSI Colors
RESET = "\033[0m"
BOLD = "\033[1m"
DIM = "\033[2m"
BLUE = "\033[34m"
CYAN = "\033[36m"
GREEN = "\033[32m"
YELLOW = "\033[33m"
RED = "\033[31m"
MAGENTA = "\033[35m"

def get_git_info():
    try:
        branch = subprocess.check_output(
            ["git", "rev-parse", "--abbrev-ref", "HEAD"],
            stderr=subprocess.DEVNULL,
            text=True
        ).strip()
        if not branch:
            return ""
        status = subprocess.check_output(
            ["git", "status", "--porcelain"],
            stderr=subprocess.DEVNULL,
            text=True
        ).strip()
        dirty = f"{YELLOW}*{RESET}" if status else ""
        return f"{MAGENTA} {branch}{dirty}{RESET}"
    except Exception:
        return ""

def format_reset_time(raw):
    if not raw:
        return ""
    if isinstance(raw, (int, float)):
        try:
            return datetime.fromtimestamp(raw).strftime("%H:%M")
        except Exception:
            return str(raw)
    raw_str = str(raw).strip()
    if "T" in raw_str:
        try:
            time_part = raw_str.split("T")[1]
            return time_part[:5]
        except Exception:
            pass
    return raw_str

def main():
    payload = {}
    rlist, _, _ = select.select([sys.stdin], [], [], 0.02)
    if rlist:
        try:
            content = sys.stdin.read().strip()
            if content:
                payload = json.loads(content)
        except Exception:
            pass

    parts = []

    # 1. Branch
    git_info = get_git_info()
    if git_info:
        parts.append(git_info)

    # 2. Modelo & Effort
    model = payload.get("model") or payload.get("model_name") or payload.get("current_model") or ""
    effort = payload.get("effort") or payload.get("reasoning_effort") or payload.get("thinking_effort") or ""

    if model and effort:
        parts.append(f"{BLUE}🤖 {model} ({effort}){RESET}")
    elif model:
        parts.append(f"{BLUE}🤖 {model}{RESET}")
    elif effort:
        parts.append(f"{BLUE}({effort}){RESET}")

    # 3. % do Contexto Total Usado
    context_pct = payload.get("context_percentage") or payload.get("context_percent")
    if context_pct is None:
        token_usage = payload.get("token_usage") or {}
        total_tokens = token_usage.get("total_tokens") or payload.get("tokens") or payload.get("context_tokens")
        context_window = payload.get("context_window") or {}
        max_tokens = context_window.get("max_tokens") or payload.get("max_tokens") or context_window.get("context_window_size")
        if total_tokens is not None and max_tokens and max_tokens > 0:
            context_pct = (total_tokens / max_tokens) * 100

    if context_pct is not None:
        pct_int = int(context_pct)
        color = GREEN
        if pct_int >= 90:
            color = RED
        elif pct_int >= 70:
            color = YELLOW
        parts.append(f"{color}🧠 {pct_int}% ctx{RESET}")

    # 4. Limite Usado e Horário de Reset
    quota = payload.get("quota") or payload.get("rate_limit") or payload.get("usage") or payload.get("credits") or {}
    used_val = ""
    reset_val = ""

    if isinstance(quota, dict):
        if "used_percentage" in quota:
            used_val = f"{quota['used_percentage']}%"
        elif "used" in quota:
            used_val = str(quota["used"])
        elif "remaining_percentage" in quota:
            try:
                used_val = f"{100 - int(quota['remaining_percentage'])}%"
            except Exception:
                pass
        elif "remaining" in quota:
            try:
                rem = float(str(quota["remaining"]).replace("%", ""))
                if rem <= 100:
                    used_val = f"{int(100 - rem)}%"
            except Exception:
                used_val = str(quota["remaining"])
        elif "percentage" in quota:
            used_val = f"{quota['percentage']}%"

        reset_raw = (
            quota.get("resets_at")
            or quota.get("reset_time")
            or quota.get("reset")
            or quota.get("window_resets_at")
            or payload.get("quota_reset_time")
            or payload.get("rate_limit_reset")
        )
        reset_val = format_reset_time(reset_raw)
    elif isinstance(quota, (str, int, float)):
        used_val = str(quota)
        reset_raw = payload.get("quota_reset_time") or payload.get("rate_limit_reset") or payload.get("reset_time")
        reset_val = format_reset_time(reset_raw)

    if used_val and reset_val:
        parts.append(f"{YELLOW}⚡ {used_val} usado (reseta às {reset_val}){RESET}")
    elif used_val:
        parts.append(f"{YELLOW}⚡ {used_val} usado{RESET}")
    elif reset_val:
        parts.append(f"{YELLOW}⚡ Reseta às {reset_val}{RESET}")

    # Se não houver nada no payload (standalone), mostra pelo menos o git
    if not parts and git_info:
        parts = [git_info]

    print(" | ".join(parts))

if __name__ == "__main__":
    main()
