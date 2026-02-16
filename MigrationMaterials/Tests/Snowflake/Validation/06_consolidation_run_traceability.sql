-- Validate run-level traceability
SELECT
    SourceSystem,
    SourceReference,
    COUNT(*) AS cnt,
    SUM(OriginalAmount + AdjustedAmount) AS total
FROM PLANNING.BUDGETLINEITEM
WHERE BudgetHeaderID = (
    SELECT BudgetHeaderID
    FROM PLANNING.BUDGETHEADER
    WHERE BudgetCode = 'BUD25_TARGET'
)
GROUP BY SourceSystem, SourceReference
ORDER BY cnt DESC;
