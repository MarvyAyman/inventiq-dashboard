CREATE OR REPLACE TABLE
  `sigma-hydra-385214.inventory_analysis.vw_top_forecast_products` AS
SELECT
  f.ProductName,
  ROUND(SUM(f.ForecastQty), 0)       AS TotalForecast30Days,
  ROUND(AVG(f.ForecastQty), 1)       AS AvgDailyForecast,
  ROUND(AVG(h.DailyQty), 1)          AS AvgDailyHistorical,
  ROUND(SUM(f.ForecastQty) * r.UnitCost, 2) AS ForecastedValue
FROM `sigma-hydra-385214.inventory_analysis.forecast_output` f
JOIN (
  SELECT ProductName, AVG(DailyQty) AS DailyQty
  FROM `sigma-hydra-385214.inventory_analysis.vw_daily_sales`
  GROUP BY ProductName
) h USING (ProductName)
LEFT JOIN (
  SELECT ProductName, AVG(UnitCost) AS UnitCost
  FROM `sigma-hydra-385214.inventory_analysis.vw_reorder_matrix`
  GROUP BY ProductName
) r USING (ProductName)
GROUP BY f.ProductName, r.UnitCost
ORDER BY TotalForecast30Days DESC
LIMIT 10;