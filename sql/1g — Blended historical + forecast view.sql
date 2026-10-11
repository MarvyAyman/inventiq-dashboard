CREATE OR REPLACE VIEW
  `sigma-hydra-385214.inventory_analysis.vw_forecast_blended` AS
SELECT
  SaleDay      AS DataDate,
  ProductName,
  DailyQty     AS Qty,
  NULL         AS LowerBound,
  NULL         AS UpperBound,
  'Historical' AS DataType
FROM `sigma-hydra-385214.inventory_analysis.vw_daily_sales`
UNION ALL
SELECT
  ForecastDate AS DataDate,
  ProductName,
  ForecastQty  AS Qty,
  LowerBound,
  UpperBound,
  'Forecast'   AS DataType
FROM `sigma-hydra-385214.inventory_analysis.forecast_output`;