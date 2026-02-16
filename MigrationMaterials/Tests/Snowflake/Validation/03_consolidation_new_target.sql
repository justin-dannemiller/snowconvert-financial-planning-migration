-- Baseline consolidation: creates a new target budget
CALL PLANNING.USP_PROCESSBUDGETCONSOLIDATION(
    (SELECT BudgetHeaderID
     FROM PLANNING.BUDGETHEADER
     WHERE BudgetCode = 'BUD25_BASE'),
    NULL,
    'FULL',
    TRUE,
    TRUE,
    PARSE_JSON('{
        "IncludeZeroBalances": true,
        "RoundingPrecision": 2
    }'),
    1,
    TRUE
);
