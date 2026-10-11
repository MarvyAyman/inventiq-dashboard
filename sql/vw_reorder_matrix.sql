CREATE OR REPLACE TABLE
  `sigma-hydra-385214.inventory_analysis.vw_reorder_matrix` AS
WITH sales_stats AS (
  SELECT
    InventoryId,
    Brand,
    Store,
    SUM(SalesQuantity)                              AS AnnualDemand,
    AVG(SalesQuantity)                              AS AvgDailyDemand,
    SUM(SalesDollars)                               AS TotalRevenue,
    DATE_DIFF(DATE '2017-01-01',
      MAX(PARSE_DATE('%m/%d/%Y', SalesDate)), DAY)  AS DaysSinceLastSale
  FROM `sigma-hydra-385214.inventory_analysis.SalesFINAL12312016`
  GROUP BY 1, 2, 3
),
beg AS (
  SELECT
    InventoryId, Brand, Store,
    Description AS ProductName,
    onHand      AS BegQty,
    Price       AS UnitCost
  FROM `sigma-hydra-385214.inventory_analysis.BegInvFINAL12312016`
),
ending AS (
  SELECT InventoryId, onHand AS EndQty
  FROM `sigma-hydra-385214.inventory_analysis.EndInvFINAL12312016`
),
vendor AS (
  SELECT DISTINCT Brand, VendorName
  FROM `sigma-hydra-385214.inventory_analysis.2017PurchasePricesDec`
)
SELECT
  b.InventoryId,
  b.ProductName,
  b.Brand,
  COALESCE(v.VendorName, CAST(b.Brand AS STRING)) AS VendorName,
  b.Store,
  CASE
    WHEN b.UnitCost * b.BegQty >= 2000 THEN 'A'
    WHEN b.UnitCost * b.BegQty >= 500  THEN 'B'
    ELSE 'C'
  END                                               AS ABCClass,
  CASE
    WHEN COALESCE(e.EndQty, 0) = 0                THEN 'Critically Low'
    WHEN COALESCE(e.EndQty, 0) < 10               THEN 'Reorder Warning'
    WHEN COALESCE(e.EndQty, 0) BETWEEN 10 AND 100 THEN 'Optimal'
    ELSE 'Overstocked'
  END                                               AS StockStatus,
  COALESCE(e.EndQty, 0)                            AS CurrentStock,
  ROUND(COALESCE(s.AvgDailyDemand, 0) * 14, 0)    AS ReorderPoint,
  ROUND(SQRT(
    2 * COALESCE(s.AnnualDemand, 1) * 50
    / NULLIF(b.UnitCost * 0.25, 0)
  ), 0)                                             AS EOQ,
  b.UnitCost,
  ROUND(COALESCE(s.TotalRevenue, 0), 2)            AS TotalRevenue,
  ROUND(COALESCE(s.AnnualDemand, 0) * b.UnitCost, 2) AS TotalCOGS,
  ROUND(
    COALESCE(s.AnnualDemand, 0) * b.UnitCost
    / NULLIF((b.UnitCost * b.BegQty
            + b.UnitCost * COALESCE(e.EndQty, 0)) / 2, 0)
  , 2)                                              AS TurnoverRate,
  ROUND(b.UnitCost * COALESCE(e.EndQty, 0) * 0.225, 2) AS HoldingCost,
  -- Capital: use BegQty when EndQty is unmatched/zero
  ROUND(b.UnitCost * GREATEST(COALESCE(e.EndQty, 0), 
    CASE WHEN e.InventoryId IS NULL THEN b.BegQty ELSE 0 END), 2) AS CapitalValue,
  COALESCE(s.DaysSinceLastSale, 999)               AS DaysSinceLastSale,
  CASE WHEN COALESCE(s.DaysSinceLastSale, 999) >= 60
       THEN TRUE ELSE FALSE END                     AS IsDeadStock
FROM beg b
LEFT JOIN ending e      ON b.InventoryId = e.InventoryId
LEFT JOIN sales_stats s ON b.InventoryId = s.InventoryId 
                        AND b.Brand = s.Brand 
                        AND b.Store = s.Store
LEFT JOIN vendor v      ON b.Brand = v.Brand;