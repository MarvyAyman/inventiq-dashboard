SELECT
  ROUND(AVG(AccuracyPct), 1) AS Forecastable_Accuracy,
  COUNT(*)                    AS Forecastable_Products
FROM `sigma-hydra-385214.inventory_analysis.vw_forecast_accuracy`
WHERE AccuracyPct BETWEEN 80 AND 100;