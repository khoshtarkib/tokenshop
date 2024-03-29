USE [TokenShop]
GO
/****** Object:  StoredProcedure [dbo].[DeleteAllProcedureCreated]    Script Date: 11/17/2018 3:17:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[proDeleteAllProcedureCreated]
as
begin
DECLARE @spname sysname;

DECLARE SPCursor CURSOR FOR
SELECT  'dbo.' + name
FROM sys.objects
WHERE type = 'P';

OPEN SPCursor;
FETCH NEXT FROM SPCursor INTO @spname;
WHILE @@FETCH_STATUS = 0
BEGIN

if(@spname like 'dbo.Insert_%' or @spname like 'dbo.Update_%'  or @spname like 'dbo.Delete_%' or @spname like 'dbo.SelectAll_%' or @spname like 'dbo.SelectOne_%' )
  EXEC('DROP PROCEDURE ' + @spname);
  FETCH NEXT FROM SPCursor INTO @spname;
END
CLOSE SPCursor;
DEALLOCATE SPCursor;
end