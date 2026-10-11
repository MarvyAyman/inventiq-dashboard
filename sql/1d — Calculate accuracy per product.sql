CREATE OR REPLACE TABLE
  `sigma-hydra-385214.inventory_analysis.vw_forecast_accuracy` AS
WITH actuals AS (
  SELECT ProductName, AVG(DailyQty) AS AvgActual
  FROM `sigma-hydra-385214.inventory_analysis.vw_daily_sales`
  GROUP BY ProductName
),
forecasts AS (
  SELECT ProductName, AVG(ForecastQty) AS AvgForecast
  FROM `sigma-hydra-385214.inventory_analysis.forecast_output_raw`
  GROUP BY ProductName
)
SELECT
  a.ProductName,
  ROUND(a.AvgActual, 1)                                      AS AvgActual,
  ROUND(f.AvgForecast, 1)                                    AS AvgForecast,
  ROUND(
    ABS(a.AvgActual - f.AvgForecast)
    / NULLIF(a.AvgActual, 0) * 100
  , 1)                                                       AS MAPE_Pct,
  ROUND(
    GREATEST(
      (1 - ABS(a.AvgActual - f.AvgForecast)
      / NULLIF(a.AvgActual, 0)) * 100
    , 0)
  , 1)                                                       AS AccuracyPct
FROM actuals a
JOIN forecasts f USING (ProductName);