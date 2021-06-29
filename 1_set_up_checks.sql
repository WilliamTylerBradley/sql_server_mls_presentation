/* EXEC sp_configure  'external scripts enabled', 1
RECONFIGURE WITH OVERRIDE */

-- EXECUTE sp_configure  'external scripts enabled'

EXEC sp_execute_external_script  @language = N'R',
@script = N'
OutputDataSet <- InputDataSet;
',
@input_data_1 = N'SELECT 1 AS hello'
WITH RESULT SETS (([hello] int not null));
GO

-- Check Version
EXECUTE sp_execute_external_script @language = N'R'
    , @script = N'print(version)';
GO

-- R Packages
EXEC sp_execute_external_script @language = N'R'
    , @script = N'
OutputDataSet <- data.frame(installed.packages()[,c("Package", "Version", "Depends", "License", "LibPath")]);'
WITH result sets((
            Package NVARCHAR(255)
            , Version NVARCHAR(100)
            , Depends NVARCHAR(4000)
            , License NVARCHAR(1000)
            , LibPath NVARCHAR(2000)
            ));