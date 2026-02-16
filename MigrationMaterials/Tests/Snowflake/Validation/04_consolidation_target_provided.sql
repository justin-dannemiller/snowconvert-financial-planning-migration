-- Consolidation into an existing target budget (append semantics)
CALL PLANNING.USP_PROCESSBUDGETCONSOLIDATION(
    (SELECT BudgetHeaderID
     FROM PLANNING.BUDGETHEADER
     WHERE BudgetCode = 'BUD25_BASE'),
    (SELECT BudgetHeaderID
     FROM PLANNING.BUDGETHEADER
     WHERE BudgetCode = 'BUD25_TARGET'),
    'FULL',
    TRUE,
    TRUE,
    PARSE_JSON('{
        "IncludeZeroBalances": false
    }'),
    1,
    TRUE
);
