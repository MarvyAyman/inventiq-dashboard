CREATE OR REPLACE TABLE
  `sigma-hydra-385214.inventory_analysis.vw_daily_sales` AS
SELECT
  PARSE_DATE('%m/%d/%Y', SalesDate)  AS SaleDay,
  Description                         AS ProductName,
  SUM(SalesQuantity)                  AS DailyQty,
  ROUND(SUM(SalesDollars), 2)         AS DailyRevenue
FROM `sigma-hydra-385214.inventory_analysis.SalesFINAL12312016`
WHERE SalesDate IS NOT NULL
GROUP BY 1, 2;