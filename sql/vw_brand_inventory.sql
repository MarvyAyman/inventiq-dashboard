CREATE OR REPLACE VIEW
  `sigma-hydra-385214.inventory_analysis.vw_brand_inventory` AS

SELECT
  COALESCE(p.VendorName, CAST(b.Brand AS STRING)) AS BrandName,
  COUNT(DISTINCT b.InventoryId)                    AS SKUCount,
  ROUND(SUM(b.Price * b.onHand), 2)               AS InventoryValue,
  ROUND(
    SUM(b.Price * b.onHand) * 100.0
    / SUM(SUM(b.Price * b.onHand)) OVER()
  , 1)                                             AS PctOfTotal

FROM `sigma-hydra-385214.inventory_analysis.BegInvFINAL12312016` b
LEFT JOIN `sigma-hydra-385214.inventory_analysis.2017PurchasePricesDec` p
  ON b.Brand = p.Brand

GROUP BY 1
ORDER BY InventoryValue DESC;