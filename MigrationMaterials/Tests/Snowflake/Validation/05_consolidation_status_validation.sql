-- Expected to fail: source budget not APPROVED / LOCKED
CALL PLANNING.USP_PROCESSBUDGETCONSOLIDATION(
    (SELECT BudgetHeaderID
     FROM PLANNING.BUDGETHEADER
     WHERE BudgetCode = 'BUDGET_2025_DRAFT'),
    NULL,
    'FULL',
    TRUE,
    TRUE,
    PARSE_JSON('{}'),
    1,
    TRUE
);
