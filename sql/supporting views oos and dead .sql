-- OOS risk view
CREATE OR REPLACE VIEW
  `sigma-hydra-385214.inventory_analysis.vw_oos_risk` AS
SELECT * FROM `sigma-hydra-385214.inventory_analysis.vw_reorder_matrix`
WHERE CurrentStock < ReorderPoint;

-- Dead stock view  
CREATE OR REPLACE VIEW
  `sigma-hydra-385214.inventory_analysis.vw_dead_stock` AS
SELECT * FROM `sigma-hydra-385214.inventory_analysis.vw_reorder_matrix`
WHERE IsDeadStock = TRUE;