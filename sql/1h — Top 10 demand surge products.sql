CREATE OR REPLACE TABLE
  `sigma-hydra-385214.inventory_analysis.vw_forecast_surge` AS
WITH hist_avg AS (
  SELECT ProductName, AVG(DailyQty) AS AvgHistoricalQty
  FROM `sigma-hydra-385214.inventory_analysis.vw_daily_sales`
  GROUP BY ProductName
),
forecast_avg AS (
  SELECT
    ProductName,
    AVG(ForecastQty) AS AvgForecastQty,
    SUM(ForecastQty) AS TotalForecastQty
  FROM `sigma-hydra-385214.inventory_analysis.forecast_output`
  GROUP BY ProductName
)
SELECT
  f.ProductName,
  ROUND(h.AvgHistoricalQty, 1)                              AS AvgHistoricalQty,
  ROUND(f.AvgForecastQty, 1)                                AS AvgForecastQty,
  ROUND(f.TotalForecastQty, 0)                              AS TotalForecastQty,
  ROUND(
    (f.AvgForecastQty - h.AvgHistoricalQty)
    / NULLIF(h.AvgHistoricalQty, 0) * 100
  , 1)                                                      AS SurgePct
FROM forecast_avg f
JOIN hist_avg h USING (ProductName)
WHERE f.AvgForecastQty > h.AvgHistoricalQty
ORDER BY SurgePct DESC
LIMIT 10;