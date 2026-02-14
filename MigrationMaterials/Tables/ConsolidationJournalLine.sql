CREATE OR REPLACE TABLE PLANNING.CONSOLIDATIONJOURNALLINE (
  JournalLineID          NUMBER(38,0)   NOT NULL,
  JournalID              NUMBER(38,0)   NOT NULL,
  LineNumber             INT            NOT NULL,

  GLAccountID            INT            NOT NULL,
  CostCenterID           INT            NOT NULL,

  DebitAmount            NUMBER(19,4)   NOT NULL,
  CreditAmount           NUMBER(19,4)   NOT NULL,

  -- Persisted computed in SQL Server; here either store or compute. We'll store for simplicity.
  NetAmount              NUMBER(19,4)   NOT NULL,

  LocalCurrencyCode      VARCHAR(3)     NOT NULL,
  LocalCurrencyAmount    NUMBER(19,4)   NULL,
  ExchangeRate           NUMBER(18,10)  NULL,

  Description            VARCHAR(255)   NULL,
  ReferenceNumber        VARCHAR(50)    NULL,

  PartnerEntityCode      VARCHAR(20)    NULL,
  PartnerAccountID       INT            NULL,

  StatisticalQuantity    NUMBER(18,6)   NULL,
  StatisticalUOM         VARCHAR(10)    NULL,

  AllocationRuleID       INT            NULL,

  CreatedDateTime        TIMESTAMP_NTZ  NOT NULL
);
