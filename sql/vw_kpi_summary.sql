CREATE OR REPLACE TABLE
  `sigma-hydra-385214.inventory_analysis.vw_kpi_summary` AS
WITH agg AS (
  SELECT
    SUM(b.Price * b.onHand)                                   AS TotalBegValue,
    SUM(e.Price * e.onHand)                                   AS TotalEndValue,
    (SUM(b.Price * b.onHand) + SUM(e.Price * e.onHand)) / 2  AS TotalAvgInvValue
  FROM `sigma-hydra-385214.inventory_analysis.BegInvFINAL12312016` b
  LEFT JOIN `sigma-hydra-385214.inventory_analysis.EndInvFINAL12312016` e
    USING (InventoryId)
),
sales_agg AS (
  SELECT
    SUM(SalesDollars)                    AS TotalRevenue,
    SUM(SalesQuantity)                   AS TotalQtySold,
    -- Gross margin = (SalesPrice - PurchasePrice) / SalesPrice per unit
    -- Join to purchase prices to get unit cost
    SUM(s.SalesDollars - (s.SalesQuantity * p.PurchasePrice)) AS GrossProfit,
    SUM(s.SalesQuantity * p.PurchasePrice)                    AS TotalCOGS
  FROM `sigma-hydra-385214.inventory_analysis.SalesFINAL12312016` s
  LEFT JOIN `sigma-hydra-385214.inventory_analysis.2017PurchasePricesDec` p
    ON s.Brand = p.Brand
),
purchase_agg AS (
  SELECT SUM(Dollars) AS TotalPurchases
  FROM `sigma-hydra-385214.inventory_analysis.PurchasesFINAL12312016`
)
SELECT
  ROUND(agg.TotalEndValue, 2)                                       AS TotalInventoryValue,
  ROUND(pa.TotalPurchases / NULLIF(agg.TotalAvgInvValue, 0), 2)    AS InventoryTurnoverRatio,
  ROUND(agg.TotalEndValue / NULLIF(agg.TotalAvgInvValue / 52.0, 0), 1) AS WeeksOfSupply,
  ROUND(agg.TotalEndValue * 0.225, 2)                              AS TotalCarryingCosts,
  ROUND(sa.TotalRevenue / NULLIF(agg.TotalAvgInvValue, 0), 2)     AS GMROI,
  ROUND(sa.TotalRevenue, 2)                                        AS TotalRevenue,
  ROUND(sa.GrossProfit / NULLIF(sa.TotalRevenue, 0), 3)           AS GrossMarginPct,
  ROUND(sa.TotalCOGS, 2)                                          AS TotalCOGS
FROM agg, sales_agg sa, purchase_agg pa;