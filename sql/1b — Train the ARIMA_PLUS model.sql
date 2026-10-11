CREATE OR REPLACE MODEL
  `sigma-hydra-385214.inventory_analysis.demand_forecast_model`
OPTIONS(
  model_type                = 'ARIMA_PLUS',
  time_series_timestamp_col = 'SaleDay',
  time_series_data_col      = 'DailyQty',
  time_series_id_col        = 'ProductName',
  data_frequency            = 'DAILY',
  decompose_time_series     = TRUE,
  horizon                   = 30
) AS
SELECT
  SaleDay,
  ProductName,
  DailyQty
FROM `sigma-hydra-385214.inventory_analysis.vw_daily_sales`
WHERE ProductName IN (
  SELECT ProductName
  FROM `sigma-hydra-385214.inventory_analysis.vw_daily_sales`
  GROUP BY ProductName
  HAVING COUNT(DISTINCT SaleDay) >= 10
);