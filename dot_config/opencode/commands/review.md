---
description: Actionable code review for a file, snippet, or focus area (optionally accepts a focus, e.g., `/review security`).
---

# Code Review Command

- Pass the code, filename, or paste a snippet as the main argument.
- Optionally add a focus topic (e.g. `/review security`, `/review performance`).
- The reviewer will:
  1. Prioritize bugs/correctness issues (quickly highlight high-severity problems)
  2. Highlight unclear/misleading code (readability/logic)
  3. Flag missed edge cases (robustness)
  4. Call out unnecessary complexity (simplification)
  5. Address focus area, if provided (e.g., security or performance)
- Skip praise and minor nitpicks unless they directly hurt readability or correctness.
- If file/code is good, just say so concisely!

$ARGUMENTS
