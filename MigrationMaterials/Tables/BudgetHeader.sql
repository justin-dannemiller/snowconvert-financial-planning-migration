CREATE OR REPLACE TABLE BUDGETHEADER (
  BudgetHeaderID        INT            NOT NULL,
  BudgetCode            VARCHAR        NOT NULL,
  BudgetName            VARCHAR        NOT NULL,
  BudgetType            VARCHAR        NOT NULL,
  ScenarioType          VARCHAR        NOT NULL,
  FiscalYear            INT            NOT NULL,
  StartPeriodID         INT            NOT NULL,
  EndPeriodID           INT            NOT NULL,
  BaseBudgetHeaderID    INT            NULL,
  StatusCode            VARCHAR        NOT NULL,
  SubmittedByUserID     INT            NULL,
  SubmittedDateTime     TIMESTAMP_NTZ  NULL,
  ApprovedByUserID      INT            NULL,
  ApprovedDateTime      TIMESTAMP_NTZ  NULL,
  LockedDateTime        TIMESTAMP_NTZ  NULL,
  IsLocked              INT            NOT NULL,  -- keep as INT since your source says int
  VersionNumber         INT            NOT NULL,
  Notes                 VARCHAR        NULL,
  ExtendedProperties    VARCHAR        NULL,      -- XML as string for now
  CreatedDateTime       TIMESTAMP_NTZ  NOT NULL,
  ModifiedDateTime      TIMESTAMP_NTZ  NOT NULL
);

CREATE OR REPLACE SEQUENCE PLANNING.BUDGETHEADERID_SEQ START = 1 INCREMENT = 1;