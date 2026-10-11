CREATE OR REPLACE TABLE
  `sigma-hydra-385214.inventory_analysis.vw_monthly_sales` AS
SELECT
  YearMonth,
  Brand,
  ProductName,
  Store,
  ABCClass,
  ROUND(SUM(COGS), 2)              AS MonthlyCOGS,
  ROUND(AVG(AvgInventoryValue), 2) AS AvgInventoryValue,
  SUM(Quantity)                    AS TotalQuantity,
  ROUND(SUM(Revenue), 2)           AS TotalRevenue,
  ROUND(
    SUM(COGS) / NULLIF(AVG(AvgInventoryValue), 0), 2
  )                                AS MonthlyTurnoverRate
FROM `sigma-hydra-385214.inventory_analysis.vw_inventory_master`
WHERE YearMonth IS NOT NULL
GROUP BY 1, 2, 3, 4, 5;