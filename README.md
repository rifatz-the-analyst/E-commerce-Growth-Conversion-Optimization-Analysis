# E-commerce-Growth-Conversion-Optimization-Analysis

## 1. Project Background

### 1.1 Business Context

This project analyzes an e-commerce business to understand its revenue growth, product performance, customer purchasing behavior, and website conversion performance. The analysis focuses on identifying the factors driving growth, uncovering conversion bottlenecks, evaluating profitable product combinations, and improving marketing and website performance.

The analysis covers FY2012–FY2014, with additional deep dives into the most recent six-month period for selected product and funnel metrics. The findings are translated into actionable recommendations for improving revenue, profitability, and conversion efficiency.

### 1.2 Business Questions

This analysis aims to answer the following questions:

1. What factors drive the company's revenue growth?
2. Which products and product combinations contribute most to revenue and profitability?
3. How dependent is the business on its leading product?
4. Which products offer opportunities for profitable growth?
5. Where is the largest bottleneck in the customer conversion funnel?
6. How much revenue could potentially be recovered by improving add-to-cart conversion?
7. How do acquisition campaigns, landing pages, and devices relate to conversion performance?
8. Did the new billing page improve purchase conversion?
9. When does revenue tend to peak, and how can the business prepare for these periods?

## 2. Data Preparation & Data Structure

### 2.1 Data Sources

The analysis uses e-commerce data covering website traffic, product interactions, orders, product details, refunds, marketing attribution, and purchasing behavior.

The SQL workflow references the following source tables:

- `products`: product identifiers, names, and launch dates.
- `order_items`: individual products purchased, item prices, costs, and primary-item indicators.
- `orders`: order dates, customer and session identifiers, purchased-item counts, revenue, and costs.
- `order_item_refunds`: refund transactions and refund amounts.
- `website_sessions`: session dates, customer identifiers, marketing attribution, device categories, and referring URLs.
- `website_pageviews`: website pageviews, session identifiers, and page URLs.

The exact source-data provenance and original database schema documentation were not included in the supplied materials.

### 2.2 Data Cleaning & Preparation

Data preparation was performed primarily in MySQL, followed by additional formatting and feature engineering in Python.

**MySQL — Data Cleaning and Transformation**

The SQL workflow includes the following steps:

- **Duplicate checks:** Checked repeated identifiers in product, order-item, order, refund, pageview, and session records using `GROUP BY` and `HAVING COUNT(*) > 1`.
- **Data type standardization:** Converted date fields into `DATETIME` and financial fields into numeric formats.
- **Marketing attribution cleaning:** Standardized invalid or empty referring URLs to `NULL` and classified sessions into paid, direct/unknown, and organic/referral traffic.
- **Funnel-step classification:** Categorized pageviews into Landing, Products, Item, Cart, Shipping, Billing, and Thank You stages.
- **Refund aggregation:** Aggregated refund amounts and associated product costs at the order level.
- **Relational data integration:** Joined product, order-item, order, refund, session, and pageview data to create analytical datasets.
- **Product-level preparation:** Combined individual order items with product names, prices, costs, refund information, and session attributes.
- **Funnel preparation:** Created session-level funnel-stage indicators and product-level purchasing indicators.
- **Landing-page preparation:** Created a landing-page dataset filtered to records from August 2, 2014, corresponding to the period when the three active landing pages were used.

The main derived tables are summarized below.

| Derived Table | Purpose |
|---|---|
| `products_clean` | Standardized product identifiers, names, and launch dates. |
| `order_items_clean` | Prepared individual order-item records, prices, costs, and primary-item indicators. |
| `orders_clean` | Prepared order-level transaction records. |
| `order_item_refunds_clean` | Standardized refund records and refund amounts. |
| `website_pageviews_clean` | Classified website pageviews into funnel stages. |
| `website_sessions_clean` | Cleaned session attributes and marketing attribution. |
| `product_detail` | Integrated order items with products, orders, sessions, and refunds. |
| `session_detail` | Combined session and order information, including net revenue and profit. |
| `funnel_detail` | Integrated pageviews, session attributes, and order-level metrics. |
| `product_funnel` | Prepared product-level funnel stages and purchase outcomes. |
| `landing_product` | Filtered landing-page activity and associated transaction information for the selected period. |

The duplicate checks identify potential data-quality issues, but the supplied SQL does not explicitly remove duplicates or demonstrate that every source table passed validation. These checks should therefore be interpreted as validation steps rather than proof that all duplicates were eliminated.

**Python — Data Formatting and Feature Engineering**

Python was used to continue preparing the datasets for exploratory analysis and visualization.

The notebook imports Pandas, NumPy, Matplotlib, and Seaborn and loads four analytical CSV files: products, sessions, funnel, and product funnel.

The preparation steps include:

- Converting order, session, and refund dates into datetime formats.
- Extracting year and month attributes from relevant date columns.
- Creating financial-year attributes, with the financial year beginning in March.
- Classifying orders as `single-item` or `double-item` based on the number of purchased items.
- Replacing missing UTM source, campaign, and content values with `n/a` for consistent segmentation.
- Inspecting dataframe structures and data types to validate the prepared datasets.

The financial-year transformation is defined as:

```python
financial_year = date.year - (date.month < 3)
```

This assigns January and February to the preceding financial year.

### 2.3 Data Structure

The prepared datasets support three principal levels of analysis.

**Product and Transaction Analysis**

`product_detail` combines order-item records with product, order, session, and refund information. It supports product-level analysis of revenue, costs, margins, refunds, order volume, and purchasing combinations.

**Session and Website Analysis**

`session_detail` combines website sessions with associated order and refund metrics. It provides a session-level analytical foundation for traffic, conversion, customer acquisition, revenue, and profit analysis.

`funnel_detail` integrates pageview events with session and transaction information, supporting analysis of the customer journey and landing-page performance.

**Product-Level Funnel Analysis**

`product_funnel` records product-page visits, subsequent funnel-stage progression, and whether the associated primary product was purchased. This supports product-specific add-to-cart conversion analysis and revenue recovery scenarios.

The SQL workflow also creates aggregated product combinations at the order level, including the number of items purchased, product names, combined selling prices, and costs.

These datasets form a relational analytical structure rather than a formally documented star schema. The analysis combines transaction-level, session-level, pageview-level, and product-funnel data according to the business question being investigated.

### 2.4 Key Metrics

The analysis uses the following metrics:

- Gross revenue and net revenue
- Gross orders and completed purchases
- Website traffic and product-page visits
- Average Order Value (AOV)
- Conversion rate and funnel drop-off rate
- Product-level add-to-cart conversion
- Product margin and refund rate
- Product-combination revenue and order volume
- Daily revenue and daily orders
- 95% confidence intervals for conversion rates
- Billing-to-purchase conversion
- Modeled revenue recovery
- Monthly revenue and seasonal patterns

Net revenue is calculated after deducting refunds from revenue. Profit calculations account for product costs and refunded costs according to the prepared SQL logic.

Gross orders, completed purchases, net orders, gross revenue, and net revenue are distinct metrics and should not be used interchangeably.

### 2.5 Analytical Approach & Tools

The analysis follows an end-to-end workflow using three tools:

- **MySQL** was used for data-quality checks, data cleaning, relational joins, refund aggregation, funnel preparation, and construction of analytical datasets.
- **Python** was used for date standardization, financial-year feature engineering, order categorization, missing-value standardization, data inspection, and statistical analysis.
- **Power BI** was used to present the findings through an interactive dashboard covering business performance, product and revenue drivers, funnel conversion, marketing and website optimization, and seasonal planning.

The investigative process moves from overall business performance to product-level drivers, funnel bottlenecks, marketing and website performance, and finally seasonal opportunities.

## 3. Executive Summary

- **Revenue growth:** Net revenue increased from $164,627.48 in FY2012 to $1,162,275.97 in FY2014, supported by higher traffic, improving conversion rates, and increasing net AOV.
- **Product concentration:** The Original Mr. Fuzzy accounts for approximately 45.23% of total orders, making it a major business driver and a potential source of product concentration risk.
- **Product and bundle opportunities:** The Hudson River Mini Bear has attractive observed margin and refund characteristics. The Forever Love Bear–Hudson River Mini Bear combination offers a promising balance of margin and refund rate but has relatively low order volume.
- **Funnel bottleneck:** Product view to add-to-cart is the largest bottleneck, with approximately 54%–55% drop-off. The Original Mr. Fuzzy and The Birthday Sugar Panda consistently record below-average add-to-cart conversion.
- **Revenue recovery potential:** A modeled increase in add-to-cart conversion to 55% for these two products estimates a six-month net revenue recovery of $123,273.11, including secondary-product contributions.
- **Campaign, landing-page, and device performance:** Desktop conversion rates range from 9.85% to 10.92%, compared with 3.03%–3.53% on mobile across the reported campaign combinations. The findings support investigating mobile conversion, particularly on `/home`, and testing landing pages under comparable conditions.
- **Billing-page improvement:** The A/B test indicates a statistically significant increase in billing-to-purchase conversion for `/billing-2` compared with `/billing`.
- **Seasonal planning:** Revenue tends to accelerate around September and peak around December/January, suggesting a potential year-end demand window.

## 4. Analysis and Insights

### Investigation Flow

The analysis followed a top-down investigative process:

1. Evaluated financial-year revenue growth and decomposed performance into traffic, conversion, and AOV.
2. Investigated product-level order volume, daily revenue, margin, and refund performance.
3. Compared product combinations to identify opportunities for profitable basket growth.
4. Analyzed funnel drop-off and identified products with consistently weak add-to-cart conversion.
5. Modeled potential revenue recovery from improving product-level conversion.
6. Examined statistical confidence and the reliability of product-level conversion estimates.
7. Investigated campaign, landing-page, and device performance.
8. Evaluated billing-page A/B testing results.
9. Reviewed monthly revenue patterns to inform seasonal planning.

### 4.1 Revenue Growth and Business Performance

Net revenue increased consistently across the three financial years.

| Metric | FY2012 | FY2013 | FY2014 |
|---|---:|---:|---:|
| Net Revenue | $164,627.48 | $450,009.99 | $1,162,275.97 |
| Net Revenue Growth | — | 173.35% | 158.28% |
| Gross Orders | 3,474 | 8,563 | 19,022 |
| Website Traffic | 76,039 | 130,322 | 251,427 |
| Conversion Rate | 4.57% | 6.57% | 7.57% |
| Net AOV | $50.62 | $54.74 | $63.01 |

Net revenue grew by 173.35% in FY2013 and a further 158.28% in FY2014. Over the same period, website traffic increased from 76,039 to 251,427, while conversion rate improved from 4.57% to 7.57%. Net AOV also rose from $50.62 to $63.01.

Gross orders increased from 3,474 to 8,563 in FY2013, representing approximately 146.43% growth, and reached 19,022 in FY2014, representing approximately 122.14% growth.

Traffic growth indicates that the business expanded its reach, while the improvement in conversion rate suggests that a larger proportion of visitors completed purchases. Increasing AOV further strengthened revenue performance.

The company also expanded its product portfolio from one product to four products during the analysis period. Additional product choices and opportunities for double-item purchases may have contributed to higher transaction values, although the independent impact of product launches cannot be established from the aggregate trends alone.

The monthly revenue trend shows recurring acceleration around September, followed by peaks around December and January.

This pattern suggests a potential year-end demand window that could inform marketing campaigns, product promotions, and operational planning.

The business should prepare campaigns and website experiments before the anticipated peak period, allowing sufficient time to evaluate their performance before traffic increases.

However, the available trend alone does not establish a stable seasonal pattern. Additional historical data and comparisons of monthly traffic, conversion rates, AOV, and product mix would help distinguish recurring seasonality from campaign-driven growth.

**Key Insight:** Seasonal planning should account for the observed year-end revenue acceleration while validating the pattern against additional historical data.

**Key Insight:** Revenue growth was supported by both acquisition and monetization improvements, rather than traffic expansion alone.

### 4.2 Product Performance and Concentration Risk

The Original Mr. Fuzzy, priced at $49.99, contributes approximately 45.23% of total orders across single-item and double-item purchases. It also generates the highest daily revenue, at $1,050.48, and the highest daily order volume, at 21.01 orders.

Its leading position is consistent with its earlier launch and substantially greater traffic than other products. The supplied product analysis records a conversion rate of 14.68%.

This performance makes The Original Mr. Fuzzy a central business driver. However, dependence on a single product may expose the business to changes in customer demand, customer satisfaction, competition, or acquisition efficiency.

The Hudson River Mini Bear presents a different opportunity. Despite generating the lowest daily revenue among the analyzed products, at $365.94, it records the second-highest daily order volume, at 12.20 orders.

Its lower price may contribute to its relatively high order volume. The product also has a margin of approximately 68.36% and the lowest reported product refund rate, at 1.38%.

The product was introduced in February 2014, but its first recorded traffic appeared in December 2014. One possible explanation is that earlier purchases occurred through bundles without requiring customers to visit the product page. This interpretation requires validation against product-page and event-tracking history.

The Birthday Sugar Panda has the highest reported product-level margin, at approximately 68.49%, but its higher refund rate and below-average add-to-cart conversion indicate that profitability should be considered alongside customer experience.

**Key Insight:** The Hudson River Mini Bear is a promising candidate for gradual expansion, while diversification beyond The Original Mr. Fuzzy could reduce product concentration risk.

### 4.3 Product Combination Performance

The product-combination analysis shows that the highest-revenue bundle is not necessarily the most attractive combination in terms of margin and refunds.

| Product Combination | Combined Price | Net Revenue | Orders | Margin | Refund Rate |
|---|---:|---:|---:|---:|---:|
| The Original Mr. Fuzzy + The Hudson River Mini Bear | $79.98 | $242,589.05 | 1,003 | — | — |
| The Forever Love Bear + The Hudson River Mini Bear | $89.98 | — | 680 | 64.46% | 1.81% |
| The Birthday Sugar Panda + The Hudson River Mini Bear | — | — | — | 68.44% | 4.71% |

*Note: Dashes indicate metrics not supplied for the respective combinations. The net revenue and order count for the leading combination are reported from the supplied analysis.*

The Original Mr. Fuzzy–Hudson River Mini Bear combination generates the highest net revenue among the analyzed combinations.

By contrast, The Forever Love Bear–Hudson River Mini Bear combination has a relatively attractive margin and low refund rate, but substantially lower order volume than the leading revenue-generating combination.

The Birthday Sugar Panda–Hudson River Mini Bear combination has a higher reported margin of 68.44%, but also a higher refund rate of 4.71%.

These findings show why product combinations should be evaluated using order volume, revenue, margin, and refund rate together. Higher margins alone do not guarantee the best overall business outcome.

**Key Insight:** The business should maintain its leading revenue-generating bundle while testing whether the Forever Love Bear–Hudson River Mini Bear combination can attract more orders without compromising its favorable refund profile.

### 4.4 Funnel Bottleneck, Conversion Reliability, and Revenue Recovery

The overall funnel analysis identifies product view to add-to-cart as the largest bottleneck, with a drop-off rate of 54.83%. The six-month analysis confirms a similar pattern, with approximately 54% drop-off.

The historical average product-level add-to-cart conversion rate is 52.52%, compared with 52.67% in the six-month period. Two products consistently underperform against these averages: The Original Mr. Fuzzy and The Birthday Sugar Panda.

| Product | Historical Add-to-Cart Conversion | Six-Month Add-to-Cart Conversion | Six-Month Refund Rate |
|---|---:|---:|---:|
| The Original Mr. Fuzzy | 43.04% | 42.90% | 5.38% |
| The Birthday Sugar Panda | 46.26% | 46.38% | 6.43% |

Both products exhibit consistently low add-to-cart conversion alongside relatively high refund rates. This pattern warrants further investigation into product presentation, customer expectations, and potential friction in the purchasing journey. However, the relationship does not establish that refund-related trust issues directly cause low conversion.

#### Conversion Confidence and Statistical Reliability

The 95% confidence intervals provide additional context for interpreting the observed conversion rates.

| Product | Historical 95% Confidence Interval | Six-Month 95% Confidence Interval |
|---|---|---|
| The Original Mr. Fuzzy | 42.80%–43.28% | 42.47%–43.33% |
| The Birthday Sugar Panda | Not provided | 45.39%–47.38% |
| The Hudson River Mini Bear | 63.31%–66.96% | 63.29%–66.95% |

The Original Mr. Fuzzy has the narrowest reported confidence interval, reflecting its substantially larger traffic volume and more precise conversion estimate. Conversely, The Hudson River Mini Bear has the widest interval because its traffic volume is considerably lower.

Although The Hudson River Mini Bear demonstrates promising add-to-cart conversion, its estimate is less precise than that of The Original Mr. Fuzzy. Its conversion performance should therefore be monitored as traffic increases before making substantial scaling decisions.

The consistency of the results across the historical and six-month periods strengthens the case for investigating The Original Mr. Fuzzy and The Birthday Sugar Panda. Meanwhile, confidence intervals help distinguish promising observed performance from estimates that still require additional evidence.

#### Revenue Recovery Scenario

A recovery scenario was modeled by increasing the add-to-cart conversion rate of The Original Mr. Fuzzy and The Birthday Sugar Panda to 55%, while assuming that subsequent funnel conversion rates and refund amounts remain unchanged.

| Metric | The Original Mr. Fuzzy | The Birthday Sugar Panda |
|---|---:|---:|
| Actual Completed Purchases | 7,797 | 1,557 |
| Modeled Completed Purchases | 9,998 | 1,845 |
| Actual Gross Revenue | $389,772.03 | $71,606.43 |
| Modeled Gross Revenue | $499,800.02 | $84,851.55 |
| Actual Net Revenue | $376,624.66 | $67,375.35 |
| Modeled Net Revenue | $486,652.65 | $80,620.47 |

The modeled primary-product net revenue increases by $110,027.99 for The Original Mr. Fuzzy and $13,245.12 for The Birthday Sugar Panda.

When secondary-product contributions are included, the six-month results are:

| Scenario | Six-Month Net Revenue |
|---|---:|
| Actual | $727,739.16 |
| Recovery Scenario | $851,012.27 |
| Potential Increase | $123,273.11 |

The estimated recovery represents a 16.94% increase over actual six-month net revenue. However, this is a modeled opportunity rather than a guaranteed outcome, as actual performance depends on achieving the target conversion rates and maintaining the assumed downstream conversion and refund behavior.

**Key Insight:** The product-view-to-add-to-cart stage is the primary conversion bottleneck. The Original Mr. Fuzzy and The Birthday Sugar Panda are the clearest optimization priorities because their below-average conversion persists across periods. The Hudson River Mini Bear offers promising conversion performance but requires gradual scaling and continued monitoring due to its wider confidence interval. Improving conversion for the two underperforming products could potentially recover $123,273.11 in six-month net revenue, subject to validation through controlled experiments.

---

### 4.5 Billing-Page A/B Testing

The billing-page analysis evaluates the transition from billing to completed purchase. Historically, the billing-to-purchase conversion rate increased from 52.83% in FY2012 to 62.79% in FY2013 and 63.63% in FY2014.

The improvement followed the introduction of `/billing-2` in September 2012.

An A/B test conducted from September 10, 2012, to January 5, 2013, compared the original `/billing` page with the new `/billing-2` page.

| Metric | `/billing` | `/billing-2` |
|---|---:|---:|
| Visitors | 1,656 | 1,650 |
| Orders | 750 | 1,024 |
| Conversion Rate | 45.29% | 62.06% |
| Net Revenue | $35,142.97 | $47,290.54 |

The reported z-score is approximately -9.6687, with a p-value of approximately \(4.09 \times 10^{-22}\). This provides strong statistical evidence of a difference in conversion rates between the two billing-page variants.

The observed conversion-rate improvement is 16.77 percentage points. The new page also generated more orders and higher net revenue during the test period.

After the testing period, the business continued using the new billing page. The supplied historical analysis reports a conversion rate of 63.41% under the new page, compared with 44.52% under the old page.

These findings support retaining `/billing-2` as the established billing experience. However, the observed revenue difference should not automatically be interpreted as the exact incremental causal revenue impact without considering the experiment's implementation and other possible differences between the groups.

**Key Insight:** The A/B test demonstrates a statistically significant improvement in billing-to-purchase conversion and provides a useful precedent for testing other website improvements.

### 4.6 Campaign, Landing Page, and Device Performance

*Renumbered from the previous Section 4.7.*

The combined analysis evaluates website performance through the hierarchy **UTM Campaign → Landing Page → Device**.

| UTM Campaign | Landing Page | Device | Sessions | Orders | Conversion Rate |
|---|---|---|---:|---:|---:|
| Brand | `/home` | Desktop | 12K | 1,320 | 10.92% |
| Brand | `/home` | Mobile | 6,562 | 199 | 3.03% |
| N/A | `/home` | Desktop | 23K | 2,415 | 10.46% |
| N/A | `/home` | Mobile | 14K | 477 | 3.31% |
| Non-Brand | `/lander-5` | Desktop | 83K | 8,144 | 9.85% |
| Non-Brand | `/lander-3` | Mobile | 34K | 1,187 | 3.53% |

*Note: Session counts displayed in thousands are rounded dashboard values.*

Desktop conversion rates range from 9.85% to 10.92%, substantially higher than mobile conversion rates of 3.03%–3.53%.

For Brand and N/A campaigns, both devices use `/home`, allowing a more direct comparison of device-level performance. Desktop conversion is approximately 3.60 times the mobile rate for Brand traffic and 3.16 times the mobile rate for N/A traffic.

For Non-Brand traffic, desktop visitors directed to `/lander-5` convert at 9.85%, compared with 3.53% for mobile visitors directed to `/lander-3`. Since both device and landing page differ, this comparison cannot isolate their individual effects.

The broader landing-page analysis also reports `/lander-5` as the strongest of the three active landing pages, with a conversion rate of 10.17%, compared with 7.85% for `/home` and 3.53% for `/lander-3`.

**Key Insight:** Mobile conversion optimization should be prioritized on `/home`, while controlled tests comparing `/lander-5` and `/lander-3` under equivalent device and campaign conditions are needed before reallocating Non-Brand traffic.

---

## 5. Recommendations

### 5.1 Prioritize Funnel Conversion and Validate Revenue Recovery

**Finding:** The product-view-to-add-to-cart stage is the largest funnel bottleneck. The Original Mr. Fuzzy and The Birthday Sugar Panda consistently record below-average conversion rates, while The Hudson River Mini Bear shows promising but less precise conversion performance.

**Recommendation:** Audit the product pages of The Original Mr. Fuzzy and The Birthday Sugar Panda, focusing on product presentation, customer expectations, and add-to-cart interactions. Conduct controlled A/B tests and monitor completed purchases, refunds, and net revenue to validate the modeled six-month recovery opportunity of $123,273.11. Gradually scale The Hudson River Mini Bear while tracking conversion as traffic increases.

**Expected Impact:** Improve funnel efficiency, validate revenue recovery potential, and expand promising products without relying on uncertain conversion estimates.

### 5.2 Optimize Campaign, Landing Page, and Device Performance

**Finding:** Desktop conversion substantially exceeds mobile conversion across the reported segments. Brand and N/A traffic on `/home` show particularly large gaps, while the Non-Brand comparison combines different devices and landing pages.

**Recommendation:** Investigate mobile performance on `/home`, then conduct controlled tests comparing `/lander-5` and `/lander-3` on the same device and under comparable campaign conditions. Evaluate conversion rate, completed purchases, refund rate, and net revenue before adjusting traffic allocation.

**Expected Impact:** Identify the causes of conversion gaps and improve landing-page and device-level performance through evidence-based optimization.

### 5.3 Expand Profitable Products and Product Combinations

**Finding:** The Original Mr. Fuzzy contributes approximately 45.23% of total orders, while The Hudson River Mini Bear has attractive margin and refund characteristics. The Forever Love Bear–Hudson River Mini Bear combination also has a promising margin and refund profile but relatively low order volume.

**Recommendation:** Gradually expand The Hudson River Mini Bear and test targeted promotions for promising bundles, especially the Forever Love Bear–Hudson River Mini Bear combination. Evaluate performance using order volume, net revenue, margin, and refund rate.

**Expected Impact:** Diversify revenue sources and increase profitable product and bundle purchases.

### 5.4 Preserve Successful Website Improvements and Plan for Seasonal Demand

**Finding:** The `/billing-2` A/B test produced a statistically significant increase in billing-to-purchase conversion, while monthly revenue trends suggest acceleration around September and peaks around December/January.

**Recommendation:** Maintain `/billing-2` while monitoring its performance, apply controlled experimentation to other website improvements, and prepare campaign and landing-page tests ahead of the potential year-end demand window.

**Expected Impact:** Preserve conversion gains, support continuous experimentation, and improve readiness for periods of higher demand.

---

## 6. Limitations

- **Data-quality validation:** The SQL contains duplicate checks, but the supplied code does not explicitly remove duplicates or document the outcome of every check. Source-level data quality should be verified before production use.
- **Metric definitions:** Gross orders, completed purchases, net orders, gross revenue, and net revenue have different meanings. Their definitions and denominators should remain consistent across analyses.
- **Product-level funnel interpretation:** The product funnel identifies whether the primary product was purchased. Product-level funnel purchase counts should not be assumed to represent all purchases of that product, particularly when secondary products are included in the order.
- **Causal interpretation:** The association between refund rates and low add-to-cart conversion does not establish that refunds or customer trust issues cause the conversion gap.
- **Revenue recovery assumptions:** The recovery scenario assumes a 55% add-to-cart conversion rate, unchanged downstream conversion, and constant refund amounts. Actual results may differ.
- **Confidence intervals:** Products with lower traffic have less precise conversion estimates. Further monitoring is required before making substantial scaling decisions.
- **Landing-page and device effects:** The Brand and N/A segments compare devices on the same landing page, whereas the Non-Brand segment compares desktop `/lander-5` with mobile `/lander-3`. The latter comparison cannot isolate the independent effects of device and landing page.
- **Rounded traffic figures:** Some session counts in the campaign–landing page–device dashboard are rounded. Exact underlying counts should be used for independent recalculation and statistical testing.
- **Attribution uncertainty:** N/A traffic may contain multiple sources or attribution scenarios. Its composition should be investigated before it is treated as a homogeneous acquisition segment.
- **Seasonality:** The observed monthly revenue pattern suggests a year-end demand window, but additional historical data are required to establish the stability and strength of seasonality.
- **A/B testing scope:** The billing-page test provides strong statistical evidence of a conversion difference. The exact incremental business impact depends on the validity of the experiment setup and the comparability of the test groups.
