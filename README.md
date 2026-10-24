# Traveloka New Year Hotel Analysis: Pricing, Ratings & Statistics

An end-to-end analysis of Traveloka hotel listings for the New Year period. The project cleans raw data in **PostgreSQL**, runs statistical analysis in **Python**, and presents the results in an interactive **Tableau** dashboard.

**[View the Tableau Dashboard]**

<img width="1910" height="848" alt="Screenshot 2026-10-24 181054" src="https://github.com/user-attachments/assets/20d21574-1503-4e18-82e0-ae173366bd43" />

---

## Table of Contents
1. [Project Overview](#project-overview)
2. [Tech Stack](#tech-stack)
3. [Dataset](#dataset)
4. [Workflow](#workflow)
5. [Data Cleaning & Validation (SQL)](#data-cleaning--validation-sql)
6. [Statistical Analysis (Python)](#statistical-analysis-python)
7. [Dashboard (Tableau)](#dashboard-tableau)
8. [Key Insights](#key-insights)
9. [Repository Structure](#repository-structure)
10. [How to Reproduce](#how-to-reproduce)
11. [Author](#author)

---

## Project Overview

**Problem statement:** Analyze the pattern and positioning of hotel rates available on Traveloka during the New Year period, based on location, star rating, and the difference between the original rate and the cheapest rate, to understand the price competitiveness of hotels.

**Questions answered:**
1. How are hotels distributed across cities?
2. What is the composition of hotels by star rating?
3. Which city has the highest median nightly rate?
4. How are hotel locations and rates distributed geographically? *(answered in Tableau)*
5. What are the characteristics of the nightly rate distribution during the New Year period?
6. Is there a significant difference in nightly rates across star ratings?
7. How large is the gap between the original rate and the cheapest rate?

**Approach:** Load raw hotel listings into PostgreSQL, validate and clean them with SQL, analyze the cleaned data statistically in Python, and communicate the results through an interactive Tableau dashboard.

**Outcome:** Hotel rates during the New Year period are strongly right-skewed (median Rp 972,604 per night), differ significantly across star ratings (Kruskal-Wallis, p < 0.05), and are typically discounted by about 25% from the original rate. Yogyakarta has the highest median nightly rate (Rp 1.81 million).

## Tech Stack

| Purpose | Tool |
|---|---|
| Data storage & cleaning | PostgreSQL, SQL |
| Statistical analysis | Python (Jupyter Notebook) [add libraries: pandas, numpy, scipy, matplotlib, seaborn ...] |
| Visualization | Tableau Public |

## Dataset

- **Source:** Traveloka hotel listings for the New Year period (https://www.kaggle.com/datasets/datasciencerikiakbar/new-year-hotel-rooms-availability-from-traveloka)
- **Size:** 904 rows
- **Raw table:** `traveloka_raw` with 35 columns (hotel info, location, stay dates, ratings, and a detailed price breakdown: base fare, fees, taxes, total fare)
- **Clean table:** `traveloka_clean` with the columns used in the analysis:

| Column | Description |
|---|---|
| `name` | Hotel name |
| `city`, `region` | Location |
| `latitude`, `longitude` | Coordinates |
| `star_rating` | Star classification (0 = no star classification, up to 5) |
| `checkin`, `checkout` | Stay dates (converted to `DATE`) |
| `num_staying_nights` | Length of stay |
| `cheapest_rate_all`, `cheapest_rate_pern` | Cheapest total fare, for the whole stay and per night |
| `original_all`, `original_pern` | Original (pre-discount) total fare, for the whole stay and per night |

## Workflow

```
traveloka_raw (CSV)
      │
      ▼
 PostgreSQL ── validate & clean ──▶ traveloka_clean
                                          │
                                          ▼
                              Python: statistical analysis
                                          │
                                          ▼
                              Tableau: interactive dashboard
```

## Data Cleaning & Validation (SQL)

All queries are in [`Query milestone.sql`](Query%20milestone.sql). Steps performed on the database `milestone_2`:

| Check | Result |
|---|---|
| Missing values in key columns | None found |
| Duplicates | Repeated hotel names are different offers for the same hotel, not true duplicates; records that differ only by scrape time were reviewed further in Python |
| Zero or negative prices | None found |
| Star rating range | 0 to 5 (0 = no star classification) |
| Stay length vs. dates | `checkout - checkin` matches `num_staying_nights` in every row |
| Cheapest rate vs. original rate | Cheapest rate never exceeds the original rate |

**Cleaning:** a new table `traveloka_clean` was created from the raw table. Date text columns were converted to `DATE`, columns were renamed to snake_case, and only the columns needed for analysis were kept. Row count was verified (904 rows in both tables).

## Statistical Analysis (Python)

Notebook: [`P1M2_raka_airlangga.ipynb`](P1M2_raka_airlangga.ipynb)

- **Descriptive statistics:**
  - Median nightly rate (`cheapest_rate_pern`) is Rp 972,604, so half of the hotels charge below this value.
  - The median is used instead of the mean because `df.describe()` shows outliers in the rate column.
  - City medians range from Rp 440k (Banda Aceh) to Rp 1.81 million (Yogyakarta).
  - Discount from original to cheapest rate: mean 24.43%, median 25%, std 6.84%, min 1.46%, max 70%.

- **Distribution analysis:**
  - Nightly rates are strongly right-skewed (skewness = 7.72) with a very sharp peak and long right tail (kurtosis = 99.36).
  - Histogram and boxplot confirm this: most hotels are in the low-to-mid range, while a few have very high rates that appear as outliers above the upper whisker.
  - The Shapiro-Wilk test shows most star-rating groups are not normally distributed (p < 0.05). Only the 1.5 and 2.5 star groups are normal.

- **Inferential statistics:**
  - Test: Kruskal-Wallis (non-parametric), chosen because the normality assumption required by ANOVA is not met.
  - H0: The median nightly rate is the same across all star ratings.
  - H1: At least one star rating has a different nightly rate.
  - Result: statistic = 613.115, p-value = 3.54e-127 (< 0.05), so H0 is rejected.
  - Conclusion: Star rating has a significant effect on the nightly hotel rate during the New Year period.

## Dashboard (Tableau)

Interactive dashboard published on Tableau Public: **[Open dashboard](https://public.tableau.com/shared/Z5H9T7W2M?:display_count=n&:origin=viz_share_link)**

It shows: [e.g. price by city, price by star rating, hotel locations on a map, discount levels]

## Key Insights

1. **Hotel distribution is uneven.** Jakarta has the most hotels (66), followed by Bandung and Surabaya (55 each). Denpasar has only 1 hotel in the dataset, so its results should not be generalized.
2. **Mid-to-upper class dominates.** There are 135 four-star and 118 three-star hotels. 49 hotels have a star rating of 0, assumed to be properties without a star classification.
3. **Yogyakarta has the highest median nightly rate** at Rp 1.81 million, followed by Jakarta and Bandung. The gap between cities is large: Banda Aceh's median is Rp 440k.
4. **Geographic pattern:**
5. **Rates are heavily right-skewed** (skewness 7.72, kurtosis 99.36) with clear outliers, so the median (Rp 972,604) is a better measure than the mean.
6. **Star rating significantly affects the nightly rate.** The Kruskal-Wallis test rejects H0 (statistic = 613.115, p < 0.05).
7. **Discounts are consistent.** The average discount is 24.43% and the median is 25%. A few hotels offer much deeper discounts, up to 70%.

## Data Notes & Limitations

- Cities with very few hotels (e.g. Denpasar, 1 hotel) are not representative; their median rates describe the sample, not the whole city.
- Hotels with a star rating of 0 are treated as unclassified accommodations.
- Outliers were kept in the data and handled by using the median instead of the mean.

## Recommendations

**For hotel operators / Traveloka partners**
1. **Benchmark against the city and star class, not the overall average.** Rates are heavily right-skewed (skewness 7.72), so the mean is misleading. Use the median per city (e.g. Rp 1.81 million in Yogyakarta vs Rp 440k in Banda Aceh) and per star rating as the pricing reference.
2. **Treat the ~25% discount as the market norm.** Most hotels (median 25%, mean 24.43%) discount by about the same amount. A hotel offering the same 25% gains no price advantage; to stand out, it needs a differentiator (e.g. a bundle or perk) or a targeted deeper discount, since only a few hotels go beyond 40-70%.
3. **Price according to star class.** Star rating has a significant effect on nightly rates (Kruskal-Wallis, p < 0.05). Three- and four-star hotels dominate the market (118 and 135 hotels), so competition is highest there. A hotel in this segment should compare itself with its direct peers.
4. **Review unclassified listings.** 49 hotels have no star rating. Getting classified (or clearly stating their facilities) would make them easier to compare and position.

**For travelers**
5. **Compare the nightly rate within the same city and star class.** Rates vary widely between cities, so the same budget buys very different quality in Yogyakarta, Jakarta, or Bandung compared with other cities.
6. **Expect about 25% off the original rate as a typical deal.** A much smaller discount is below the norm, while a discount above 40% is rare and worth a closer look at the offer.

**For further analysis**
7. Collect more hotels for cities with very few listings (e.g. Denpasar has only 1 hotel) and add data from other periods to see whether these patterns are specific to New Year.

## Repository Structure

```
Statistic-and-Visualization/
├── traveloka_raw.sql              # Raw data loaded into PostgreSQL
├── Query milestone.sql            # Validation and cleaning queries
├── traveloka_clean.csv            # Cleaned dataset
├── P1M2_raka_airlangga.ipynb      # Statistical analysis notebook
└── README.md
```

## How to Reproduce

1. Create a PostgreSQL database and load `traveloka_raw.sql` (or the raw CSV).
2. Run the queries in `Query milestone.sql` to build `traveloka_clean`.
3. Open the notebook in Jupyter and run all cells (it can also start from `traveloka_clean.csv`).
4. Open the Tableau dashboard link above.

```bash
pip install pandas numpy scipy matplotlib seaborn jupyter
```

## Author

**Raka Airlangga**
[LinkedIn](https://linkedin.com/in/your-profile) · [Email](mailto:your-email@example.com)
