Luck Mechanics
Luck guarantees symbol matches on spins.
Description
Base luck from charms + spontaneous (ILS for first debt, OLS intervals, Pity after misses). 7+ guarantees win, 15+ jackpot (unless sixes).
Key Components

Calculation: Sum base + spontaneous.
Spontaneous: Fixed sequences or random intervals; pity scaling.
Application: Force matches in grid based on luck value.

Step-by-Step Implementation

State Management: Track base luck, spin count, miss streak.
Luck Calculator: Function adding spontaneous based on algorithms (e.g., modulos for ILS/OLS).
Apply in Generation: During grid fill, select a symbol and force minimum luck matches in positions.
UI: Show luck before spin with sparks for bonuses.
Integration: Call in spin; disable via certain charms.