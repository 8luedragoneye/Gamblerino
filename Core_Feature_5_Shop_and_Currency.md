Shop and Currency
The shop sells charms using tickets; restocking costs coins.
Description
Shop displays 4 charms randomly based on rarities. Tickets from modifiers or charms; coins from spins. Restock increases cost progressively per deadline.
Key Components

Currencies: Tickets and coins.
Inventory Generation: Random with rarity rerolls.
Restock: Cost based on debt; free from modifiers.
Discounts: From phone calls.

Step-by-Step Implementation

State Management: Track tickets, coins, shop items, restock cost.
Generate Inventory: Function to pick charms weighted by rarity, with reroll logic.
Buy Handler: Check tickets and slot space; add to equipped, deduct tickets.
Restock Handler: Deduct coins if paid, regenerate shop, increase cost.
UI: Panel showing items with costs, buy buttons, restock option.