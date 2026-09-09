
# Revenue & Sales Performance Analysis — Olist E-commerce

## 1. Project Overview

End-to-end data pipeline combining **MySQL 8.0** and **Python** (`pandas`, `matplotlib`, `sqlalchemy`) for relational modeling, ETL sanitization, and historical revenue visualization of the Olist e-commerce dataset.

The pipeline ingests raw relational entities, sanitizes missing timestamps, calculates core financial metrics (Gross Revenue, Freight Share, Average Ticket), and renders a visual sales trajectory.

---

## 2. Technical Modeling & ETL Decisions

* **Missing Values Sanitization (`NULLIF`):**
  Delivery and approval timestamps contained empty strings in raw CSV extractions. Using session variables (`@variable`) with `NULLIF(@variable, '')`, empty fields were loaded as native MySQL `NULL` values, preserving `DATETIME` constraints.
* **Composite Primary Key Modeling:**
  The `order_items` table implements `PRIMARY KEY (order_id, order_item_id)` to handle multi-item carts ($1:N$) without redundancy anomalies.
* **Financial Precision:**
  Monetary columns use `DECIMAL(10, 2)` instead of floating-point types (`FLOAT`/`DOUBLE`) to prevent rounding errors in accounting calculations.
* **Cart-Level Metric Accuracy:**
  Queries apply `COUNT(DISTINCT orders.order_id)` to prevent multi-item orders from artificially multiplying total sales counts.

---

## 3. Visual Performance & Insights

![Monthly Revenue Trajectory](metricas_mensais_olist.png)

### 3.1. Trend Analysis & Seasonality

* **Consistent Growth Trajectory (2017 – 2018):**
  Platform operations scaled steadily from early 2017, breaking past **BRL 1 million in monthly revenue** in the second half of 2017.
* **Black Friday Peak (November 2017):**
  `2017-11` presents a distinct upward spike visible in the chart above, capturing the annual demand surge driven by Brazilian Black Friday promotions.

### 3.2. Low-Volume Outliers & Data Truncation

* **Pilot / Ramp-Up Phase (Late 2016):**
  September and October 2016 show nominal order volume (under 300 delivered orders), reflecting the company's early market testing phase.
* **Dataset Cutoff Truncation (Late 2018):**
  September and October 2018 drop sharply due to the public dataset snapshot cutoff date; in-transit orders had not yet transitioned to `delivered` status at extraction time.

### 3.3. Unit Economics

* **Stable Average Ticket (AOV):**
  Despite high volumetric growth, the average order value hovered consistently around **BRL 150.00 – BRL 170.00**, indicating that revenue scaled via user acquisition and transaction count rather than basket price inflation.
* **Freight Overhead:**
  Shipping fees accounted for **15% to 20%** of total transacted volume throughout the measured timeline.
