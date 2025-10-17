Debt and Deadlines (Rounds)
Deadlines are rounds with spin limits and debt targets to meet.
Description
Each deadline has base spins + bonuses; earn coins to pay fixed/escalating debt. Pay via ATM; success advances, failure ends run.
Key Components

Deadline Tracking: Current level, debt amount.
Debt Calculation: Fixed for 1-9, exponential after.
End Round: Compare coins to debt.

Step-by-Step Implementation

State Management: Track current deadline and debt.
Debt Function: Compute based on level (array for fixed, formula for higher).
Round End Logic: When spins zero, show pay option; if sufficient, deduct and advance; else game over.
Reset: On advance, reset spins, shop, restock cost.
UI: Progress vs. debt, ATM button at end.