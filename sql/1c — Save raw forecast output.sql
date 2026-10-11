CREATE OR REPLACE TABLE
  `sigma-hydra-385214.inventory_analysis.forecast_output_raw` AS
SELECT
  CAST(forecast_timestamp AS DATE)          AS ForecastDate,
  ProductName,
  ROUND(forecast_value, 0)                  AS ForecastQty,
  ROUND(prediction_interval_lower_bound, 0) AS LowerBound,
  ROUND(prediction_interval_upper_bound, 0) AS UpperBound,
  'Forecast'                                AS DataType
FROM ML.FORECAST(
  MODEL `sigma-hydra-385214.inventory_analysis.demand_forecast_model`,
  STRUCT(30 AS horizon, 0.9 AS confidence_level)
);