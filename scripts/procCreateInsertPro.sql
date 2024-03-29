USE [TokenShop]
GO
/****** Object:  StoredProcedure [dbo].[procCreateInsertPro]    Script Date: 11/17/2018 10:05:45 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER Procedure [dbo].[procCreateInsertPro]
AS

DECLARE @table nvarchar(500)
DECLARE @sql nvarchar(2520)
DECLARE @sqlUpdate nvarchar(2520)
DECLARE @sqlDelete nvarchar(520)

DECLARE CursorSelect CURSOR FOR
    select table_name from INFORMATION_SCHEMA.tables where table_name not like 'sys%'

OPEN CursorSelect
FETCH NEXT FROM CursorSelect
INTO @table


WHILE @@FETCH_STATUS = 0
BEGIN
        DECLARE CursorSelectFiled CURSOR FOR
            SELECT COLUMN_NAME,DATA_TYPE,CHARACTER_MAXIMUM_LENGTH FROM TokenShop.INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_NAME = @table
		Declare @id nvarchar(50)=''
       DECLARE @field nvarchar(100)=''
       DECLARE @len nvarchar(100)=''
       DECLARE @type nvarchar(100)=''
       DECLARE @propert nvarchar(2000)=''
       DECLARE @fields nvarchar(2000)=''
       DECLARE @varfields nvarchar(2000)=''
       DECLARE @updatefields nvarchar(2000)=''
        OPEN CursorSelectFiled
        FETCH NEXT FROM CursorSelectFiled
        INTO @field,@type,@len
        WHILE @@FETCH_STATUS = 0
        BEGIN

		if(@field<>'Id')
		begin
        	set @propert=(SELECT CONCAT(@propert+',', @field));
        	set @fields=(SELECT CONCAT(@fields+',@', @field));
        	set @updatefields=(SELECT CONCAT(@updatefields,','+@field+'=@', @field));

		  if(@len='-1') set @len='Max'
		  if(@type='int' or @type='bigint' or @type='bit'  or @type='datetime' or @type='date'  or @type='float') 
			set @varfields=(SELECT CONCAT(@varfields,',@'+@field+' as '+@type+' = null'));
			else
			set @varfields=(SELECT CONCAT(@varfields,',@'+@field+' as '+@type+'('+@len+')'+' = null'));
		END
		else
		set @id='@Id as '+@type;
            FETCH NEXT FROM CursorSelectFiled
            INTO @field,@type,@len 
        END
        CLOSE CursorSelectFiled
        DEALLOCATE CursorSelectFiled
		set @varfields=RIGHT(@varfields,LEN(@varfields)-1)
		set @propert=RIGHT(@propert,LEN(@propert)-1)
		set @fields=RIGHT(@fields,LEN(@fields)-1)
		set @updatefields=RIGHT(@updatefields,LEN(@updatefields)-1)

            SET @sql = ' CREATE Procedure dbo.Insert_'+@table +'  '+
			@varfields+
        ' AS BEGIN 
        insert into [dbo].[' + @table +'] ('+
		@propert+')'
		+'  VALUES
           ('+@fields+')'+
        ' select @@IDENTITY END'
		print @sql
         exec(@sql)
		   SET @sqlUpdate = ' CREATE Procedure dbo.Update_'+@table +'  '+
			'  '+ @id+','+@varfields+
        ' AS BEGIN 
        update [dbo].[' + @table +']'+
		' SET '+
		@updatefields + '
		 where Id=@Id '+
         'END'
		 	--print @sqlUpdate
			exec(@sqlUpdate)
		SET @sqlDelete = ' CREATE Procedure dbo.Delete_'+@table +
			  '  '+ @id+
        ' AS BEGIN 
        Delete from [dbo].[' + @table +']'+
		 ' where Id=@Id '+
         'END'
		 	--print @sqlDelete
			exec(@sqlDelete)

            FETCH NEXT FROM CursorSelect
            INTO @table     
END
CLOSE CursorSelect
DEALLOCATE CursorSelect
RETURN