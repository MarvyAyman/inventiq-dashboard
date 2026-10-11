CREATE OR REPLACE VIEW
  `sigma-hydra-385214.inventory_analysis.vw_inventory_master` AS

WITH sales AS (
  SELECT
    InventoryId,
    Brand,
    Description                                                AS ProductName,
    Store,
    SalesQuantity                                              AS Quantity,
    SalesDollars                                               AS Revenue,
    SalesPrice                                                 AS UnitPrice,
    SalesDate                                                  AS TxDate,
    FORMAT_DATE('%Y-%m', PARSE_DATE('%m/%d/%Y', SalesDate))   AS YearMonth
  FROM `sigma-hydra-385214.inventory_analysis.SalesFINAL12312016`
  WHERE SalesDate IS NOT NULL
),
beg AS (
  SELECT
    InventoryId, Brand, Description AS ProductName,
    Store, onHand AS BegQty, Price AS UnitCost
  FROM `sigma-hydra-385214.inventory_analysis.BegInvFINAL12312016`
),
ending AS (
  SELECT InventoryId, onHand AS EndQty
  FROM `sigma-hydra-385214.inventory_analysis.EndInvFINAL12312016`
)
SELECT
  s.InventoryId, s.Brand, s.ProductName, s.Store,
  s.Quantity, s.Revenue, s.UnitPrice, s.TxDate, s.YearMonth,
  b.UnitCost, b.BegQty,
  COALESCE(e.EndQty, 0)                                       AS EndQty,
  ROUND(b.UnitCost * b.BegQty, 2)                            AS BegInventoryValue,
  ROUND(b.UnitCost * COALESCE(e.EndQty, 0), 2)              AS EndInventoryValue,
  ROUND((b.UnitCost * b.BegQty
       + b.UnitCost * COALESCE(e.EndQty, 0)) / 2, 2)        AS AvgInventoryValue,
  ROUND(s.Quantity * b.UnitCost, 2)                          AS COGS,
  CASE
    WHEN b.UnitCost * b.BegQty >= 2000 THEN 'A'
    WHEN b.UnitCost * b.BegQty >= 500  THEN 'B'
    ELSE 'C'
  END                                                         AS ABCClass,
  CASE
    WHEN COALESCE(e.EndQty, 0) = 0                THEN 'Critically Low'
    WHEN COALESCE(e.EndQty, 0) < 10               THEN 'Reorder Warning'
    WHEN COALESCE(e.EndQty, 0) BETWEEN 10 AND 100 THEN 'Optimal'
    ELSE 'Overstocked'
  END                                                         AS StockStatus,
  DATE_DIFF(
    DATE '2017-01-01',
    PARSE_DATE('%m/%d/%Y', s.TxDate),
    DAY
  )                                                           AS DaysSinceLastSale
FROM sales s
LEFT JOIN beg b    USING (InventoryId, Brand, Store)
LEFT JOIN ending e ON s.InventoryId = e.InventoryId;