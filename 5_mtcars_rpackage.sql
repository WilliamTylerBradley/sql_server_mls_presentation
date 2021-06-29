CREATE EXTERNAL LIBRARY mtcarsmodel
FROM (CONTENT = 'mtcarsmodel_0.1.0.zip') WITH (LANGUAGE = 'R'); --pull from GitHub

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
-- !!! NOTE THE DIFFERENT LIBPATH !!! ---

-- DROP EXTERNAL LIBRARY mtcarsmodel;

EXEC sp_execute_external_script 
@language =N'R', 
@script=N'library(mtcarsmodel)';
-- Note the warning message about R 4.0.0

-- Run model ---------------------------------------------------------------------------
EXEC sp_execute_external_script
    @language = N'R'
    , @script = N'
            library(mtcarsmodel)
            OutputDataSet <- mtcarsmodel::predict_mtcars(mtcars_data);'
    , @input_data_1 = N'SELECT cyl, hp, wt FROM dbo.mtcars'
    , @input_data_1_name = N'mtcars_data'
WITH RESULT SETS ((cyl INT, hp INT, wt DECIMAL(10, 2), predicted_mpg DECIMAL(10, 2)));