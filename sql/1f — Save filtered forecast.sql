CREATE OR REPLACE TABLE
  `sigma-hydra-385214.inventory_analysis.forecast_output` AS
SELECT *
FROM `sigma-hydra-385214.inventory_analysis.forecast_output_raw`
WHERE ProductName IN (
  SELECT ProductName
  FROM `sigma-hydra-385214.inventory_analysis.vw_forecast_accuracy`
  WHERE AccuracyPct BETWEEN 80 AND 100
);