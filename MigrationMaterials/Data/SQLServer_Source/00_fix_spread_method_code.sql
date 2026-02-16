-- fixes issue with SpreadMethodCode not being long enough to store the automatically code
ALTER TABLE Planning.BudgetLineItem
ALTER COLUMN SpreadMethodCode VARCHAR(20) NULL;