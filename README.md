# Secrets of Darkwood: Player Monetization and Purchasing Behavior Analysis

**Research Objective:** Analyze player monetization and purchasing behavior, determine the proportion of paying users, and identify differences in in-game purchasing patterns across character races.

**Tools:** SQL (PostgreSQL), DBeaver.

## Project Overview

"Secrets of Darkwood" is an online game where players create characters, complete quests, explore the game world, and purchase various items.

The game uses two currencies:

- **Regular coins** - earned through gameplay and used to purchase ordinary items.
- **Paradise Petals** - a premium currency used to purchase epic items. Players can earn it by completing challenging quests or buy it with real money.

The analysis distinguishes between two categories of users:

- **Payers** - players who have purchased premium currency with real money (`payer` field in the `users` table).
- **Buyers** - players who have made at least one non-zero-value purchase of an epic item using premium currency.

A player can be a buyer without being a payer, since Paradise Petals can also be earned through quests.

Premium currency sales are the developers' main source of revenue. The game team therefore plans to attract more paying users and encourage purchases of epic items through advertising.

## Data

The analysis is based on a relational database consisting of seven tables:

- `users` - player information and character attributes;
- `events` - in-game purchase history;
- `race`, `classes`, `skills`, `country` - reference tables for character races, classes, legendary abilities, and registration countries;
- `items` - reference table of epic items.

**Main relationships:**

- The `users` table is linked to `race`, `classes`, `skills`, and `country` through their corresponding identifiers.
- The `events` table is linked to `users` by player ID (`id`) and to `items` by item code (`item_code`).
- Each record in `events` represents an individual in-game transaction.

The database contains information on 22,214 players and more than 1.3 million in-game purchases.

## Analytical Approach

- Zero-value purchases were excluded from buyer and item-level calculations (`amount > 0`). There are 907 such transactions (0.07%), and their nature is unknown.
- Explicit type casting was used in division to prevent integer truncation when calculating the average number of purchases per buyer.

The analysis was divided into two stages: exploratory data analysis (payer share, purchase statistics, and item popularity) and a comparison of purchasing behavior across races using a CTE-based query.

## Key Findings

**Monetization.** Approximately 17.7% of players purchase premium currency with real money. The share of payers varies only slightly across races, ranging from 17.1% among Elves to 19.4% among Demons. These differences are relatively small and do not indicate a strong relationship in the descriptive analysis.

**Purchase amounts.** A total of 1,307,678 purchases were recorded, ranging in value from 0 to 486,615 units of premium currency.  
The mean purchase amount (526.06) is substantially higher than the median (74.86), with a standard deviation of approximately 2,517. This indicates a strongly right-skewed distribution: most purchases have relatively low values, while occasional expensive transactions increase the average.  
Additionally, 907 zero-value purchases (0.07%) were identified. Further information about game mechanics is needed to interpret these transactions, as they may represent gifts or bonuses.

**Item popularity.** Purchases of epic items are highly concentrated: approximately 98% are attributed to *Book of Legends* (76.9%) and *Bag of Holding* (20.8%). Both items are purchased by the majority of buyers (88.4% and 86.8%, respectively), suggesting that they may play an important role in gameplay. Meanwhile, 39 out of 184 items (approximately 21%) have no recorded purchases with a non-zero value.

**Purchasing behavior by race.** Approximately 62% of players make in-game purchases. Buyer shares are similar across races, ranging from 60.0% among Demons to 62.9% among Orcs.

However, purchasing patterns differ:

- Humans and Angels make more purchases per buyer (121 and 107, compared with 78–86 for other races), but their average transaction values are lower (403 and 456, compared with 511–761).
- Northmen have the highest average total purchase amount per buyer (approximately 62,500, compared with 41,000–54,000 for other races).
- Demons have the highest share of payers among buyers, but the lowest average total spending per buyer.

## Conclusions and Recommendations

Payer and buyer shares are relatively similar across character races. Therefore, using character race as the primary criterion for advertising campaigns aimed at attracting paying users is unlikely to be effective. However, differences in purchasing behavior could be considered when promoting epic items to existing active players.

**Potential directions for marketing campaigns:**

- Northmen: Consider special offers and retention programs for players with high total in-game spending.
- Humans and Angels: Analyze preferred items and evaluate opportunities to increase the average transaction value.
- Demons: Further investigate the reasons for relatively low spending despite a high share of payers.
- Item assortment: Explore the reasons behind the concentration of purchases on two items and assess opportunities to promote less popular items.

Testing these hypotheses will require additional analysis of player activity, character attributes, and purchasing patterns.

**Directions for further research:**

- Player preferences: Analyze purchases by race and item to identify differences in demand across player segments.
- Segmentation: Compare purchasing behavior by character class, legendary abilities, and registration country.
- Player activity: Assess how inactive and exceptionally active players affect overall metrics.
- Spending distribution: Compare median spending values and examine the impact of high-value purchases on the results.
- Zero-value purchases: Investigate whether these transactions are related to game mechanics or data-specific issues.

## Limitations

Differences between character races were analyzed without statistical significance testing. The findings are descriptive and do not establish causal relationships.

In-game purchase amounts are expressed in premium currency and do not represent the developers' actual monetary revenue.

The source database and connection details are not publicly available in accordance with the terms of access to the educational materials.

*This project was completed independently as part of data analytics training.*
