
# LEGO Data Analysis with Rebrickable

This project explores the Rebrickable LEGO dataset to provide various insights, including the number of parts per theme, parts produced per year, set creation trends over centuries, and color distribution in terms of parts produced. The queries are structured to extract useful information for LEGO enthusiasts, researchers, or analysts working with LEGO data.

## Dataset

The dataset used for this analysis is from Rebrickable, focusing on the following tables:
- `sets`
- `themes`
- `inventory_parts`
- `colors`
- `parts`
- `part_categories`

## SQL Query Breakdown

### 1. **Total Number of Parts per Theme**

We create a view `analytics_view` to improve query performance and extract data across sets and themes. The first question answers the total number of parts per theme.

```sql
SELECT theme_name, SUM(set_number) AS total_num_parts
FROM analytics_view
GROUP BY theme_name
ORDER BY total_num_parts DESC;
```

**Key Findings**:
- **Technic** leads with over 2 million parts, followed by **City** and **Educational and Dacta**.

### 2. **Total Number of Parts per Year**

This query examines how the number of parts produced has changed over the years.

```sql
SELECT year, SUM(set_number) AS total_num_parts
FROM analytics_view
GROUP BY year
ORDER BY total_num_parts DESC;
```

**Key Findings**:
- **2024** saw the highest number of parts produced, followed by **2023** and **2022**, showing exponential growth over the last decade.

### 3. **Sets Created per Century**

This query explores the number of sets created in each century.

```sql
SELECT century, COUNT(set_num) AS total_sets
FROM analytics_view
GROUP BY century;
```

**Key Findings**:
- The **21st century** has over 47,000 sets, while the **20th century** had just over 8,000, indicating significant growth in set diversity and quantity.

### 4. **Percentage of Gear-Themed Sets in the 21st Century**

A Common Table Expression (CTE) is used to calculate the percentage of Gear-themed sets released in the 21st century.

```sql
WITH cte AS (
    SELECT century, theme_name, COUNT(set_num) AS total_set_num
    FROM analytics_view
    WHERE century = '21st century'
    GROUP BY century, theme_name
)
SELECT theme_name, (1.00 * total_set_num / SUM(total_set_num) OVER()) * 100 AS percentage
FROM cte
WHERE LOWER(theme_name) LIKE '%gear%';
```

**Key Findings**:
- Gear-themed sets account for **29.5%** of all sets released in the 21st century.

### 5. **Most Popular Theme by Year (21st Century)**

This query identifies the most popular theme each year based on the number of sets released.

```sql
SELECT year, theme_name, total_set_num
FROM (
    SELECT year, theme_name, COUNT(set_num) AS total_set_num,
           ROW_NUMBER() OVER (PARTITION BY year ORDER BY COUNT(set_num) DESC) AS row_num
    FROM analytics_view
    WHERE century = '21st century'
    GROUP BY year, theme_name
) AS ranked_themes
WHERE row_num = 1
ORDER BY year DESC;
```

**Key Findings**:
- **Gear** is consistently the most popular theme across multiple years.

### 6. **Most Produced Colors by Part Quantity**

This query analyzes which LEGO colors are produced the most in terms of quantity.

```sql
SELECT color_name, rgb, SUM(quantity) AS quantity_of_parts
FROM (
    SELECT ip.color_id, ip.quantity, c.name AS color_name, c.rgb
    FROM inventory_parts ip
    INNER JOIN colors c ON ip.color_id = c.id
) AS color_data
GROUP BY color_name, rgb
ORDER BY quantity_of_parts DESC;
```

**Key Findings**:
- The most produced colors are **black**, followed by **Light Bluish Gray** and **white**.

## How to Use

1. **Database Setup**: Ensure you have the Rebrickable dataset in your database.
2. **Create View**: Use the `analytics_view` to optimize queries for faster results.
3. **Run Queries**: Execute the SQL queries provided to extract insights from the LEGO dataset.

## Conclusion

This project provides valuable insights into LEGO set production, trends in parts, and color usage. It can help users understand the evolution of LEGO sets and how various themes have performed over the years.
