CREATE TABLE [dbo].[customers] (
    [customerid]           UNIQUEIDENTIFIER   NOT NULL,
    [first_name]           VARCHAR (50)       NULL,
    [last_name]            VARCHAR (50)       NULL,
    [create_datetime]      DATETIMEOFFSET (7) NULL,
    [last_update_datetime] DATETIMEOFFSET (7) NULL,
    CONSTRAINT [PK_customers] PRIMARY KEY CLUSTERED ([customerid] ASC)
);

