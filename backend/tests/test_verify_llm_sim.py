# Small test harness to simulate Jac LLM parsing and fallback behavior
# Run: python3 tests/test_verify_llm_sim.py

def parse_score(raw: str):
    """Simulate the Jac parsing logic used after calling the LLM.
    Returns float score if parseable, otherwise None.
    """
    if raw is None:
        return None
    s = raw.strip()
    if len(s) == 0:
        return None
    dot_count = 0
    for ch in s:
        if ch == '.':
            dot_count += 1
        else:
            if ch not in '0123456789':
                return None
    if dot_count > 1:
        return None
    try:
        score = float(s)
    except Exception:
        return None
    if score < 0.0:
        score = 0.0
    if score > 1.0:
        score = 1.0
    return score


def fallback_score(content: str):
    # replicate heuristic: min(0.95, len(content)/500.0)
    if content is None:
        return 0.0
    score = min(0.95, len(content) / 500.0)
    return score


if __name__ == '__main__':
    cases = [
        ("0.82", "Normal decimal"),
        (" 0.75\n", "Whitespace around number"),
        (".5", "Leading dot"),
        ("1", "Integer 1"),
        ("0", "Integer 0"),
        ("score:0.9", "Prefixed text, invalid"),
        ("0..5", "Multiple dots, invalid"),
        ("not a number", "Invalid text"),
        ("", "Empty string"),
        (None, "None value"),
        ("2.0", "Above 1.0, should clamp to 1.0"),
    ]

    content_example = "This is a reasonably long article content." * 10  # ~420 chars

    print("Running LLM parsing simulation tests:\n")
    for raw, desc in cases:
        parsed = parse_score(raw)
        if parsed is None:
            fb = fallback_score(content_example)
            print(f"Input: {repr(raw):20}  | {desc:30} -> PARSE FAIL, fallback score={fb:.4f}")
        else:
            print(f"Input: {repr(raw):20}  | {desc:30} -> PARSED score={parsed:.4f}")

    # Show fallback for short content
    short_content = "Short"
    print("\nFallback examples:")
    print(f"Short content fallback: {fallback_score(short_content):.4f}")
    print(f"Long content fallback:  {fallback_score(content_example):.4f}")
