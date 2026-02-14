CREATE OR REPLACE TABLE PLANNING.CONSOLIDATIONJOURNAL (
  JournalID              NUMBER(38,0)   NOT NULL,  -- BIGINT
  JournalNumber          VARCHAR(30)    NOT NULL,
  JournalType            VARCHAR(20)    NOT NULL,

  BudgetHeaderID         INT            NOT NULL,
  FiscalPeriodID         INT            NOT NULL,
  PostingDate            DATE           NOT NULL,
  Description            VARCHAR(500)   NULL,

  StatusCode             VARCHAR(15)    NOT NULL,

  SourceEntityCode       VARCHAR(20)    NULL,
  TargetEntityCode       VARCHAR(20)    NULL,

  IsAutoReverse          BOOLEAN        NOT NULL,
  ReversalPeriodID       INT            NULL,
  ReversedFromJournalID  NUMBER(38,0)   NULL,
  IsReversed             BOOLEAN        NOT NULL,

  TotalDebits            NUMBER(19,4)   NOT NULL,
  TotalCredits           NUMBER(19,4)   NOT NULL,

  IsBalanced             BOOLEAN        NOT NULL,

  PreparedByUserID       INT            NULL,
  PreparedDateTime       TIMESTAMP_NTZ  NULL,
  ReviewedByUserID       INT            NULL,
  ReviewedDateTime       TIMESTAMP_NTZ  NULL,
  ApprovedByUserID       INT            NULL,
  ApprovedDateTime       TIMESTAMP_NTZ  NULL,
  PostedByUserID         INT            NULL,
  PostedDateTime         TIMESTAMP_NTZ  NULL,

  -- FILESTREAM replacement: store external reference or omit usage
  AttachmentDataRef      VARCHAR        NULL,

  AttachmentRowGuid      VARCHAR(36)    NOT NULL
);
