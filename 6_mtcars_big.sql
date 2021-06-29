-- mtcars big table
CREATE TABLE dbo.mtcars_big(
    mpg decimal(10, 1) NOT NULL,
    cyl int NOT NULL,
    disp decimal(10, 1) NOT NULL,
    hp int NOT NULL,
    drat decimal(10, 2) NOT NULL,
    wt decimal(10, 3) NOT NULL,
    qsec decimal(10, 2) NOT NULL,
    vs int NOT NULL,
    am int NOT NULL,
    gear int NOT NULL,
    carb int NOT NULL
);

INSERT INTO dbo.mtcars_big
EXEC sp_execute_external_script @language = N'R'
    , @script = N'MTCars <- mtcars[sample(1:nrow(mtcars), 1000000, replace = TRUE), ];'
    , @input_data_1 = N''
    , @output_data_1_name = N'MTCars';

--DROP TABLE dbo.mtcars_big;

CREATE TABLE #mtcars_big_predictions (
	cyl INT, 
	hp INT, 
	wt DECIMAL(10, 2), 
	mpg_Pred FLOAT)


/* SQL */ -------------------------------------------------------------------------------------------	   
DECLARE @lmmodel varbinary(max) = 
    (SELECT model FROM dbo.predictive_models WHERE model_name = 'lm_17-11-20'); -- MAKE SURE TO CHANGE THE MODEL NAME

INSERT INTO #mtcars_big_predictions

EXEC sp_execute_external_script
    @language = N'R'
    , @script = N'
            current_model <- unserialize(as.raw(lmmodel));
            new <- data.frame(mtcars_data);
            predicted.am <- predict(current_model, new, type = "response");
            str(predicted.am);
            OutputDataSet <- cbind(new, predicted.am);
            '
    , @input_data_1 = N'SELECT cyl, hp, wt FROM dbo.mtcars_big'
    , @input_data_1_name = N'mtcars_data'
    , @params = N'@lmmodel varbinary(max)'
    , @lmmodel = @lmmodel;

-- Seconds: 16

-- check results 
SELECT TOP 1000 * FROM #mtcars_big_predictions;
TRUNCATE TABLE #mtcars_big_predictions;


/* Native Scoring */ -------------------------------------------------------------------------------------------
DECLARE @model varbinary(max) = (
  SELECT model
  FROM [master].[dbo].[predictive_models]
  WHERE model_name = 'native_scoring');

INSERT INTO #mtcars_big_predictions

SELECT d.cyl, d.hp, d.wt, p.*
  FROM PREDICT(MODEL = @model, DATA = dbo.mtcars_big as d)
  WITH(mpg_Pred float) as p;

-- Seconds: 8

-- check results 
SELECT TOP 1000 * FROM #mtcars_big_predictions;
TRUNCATE TABLE #mtcars_big_predictions;

/* R Package */ ---------------------------------------------------------------------------------------------
INSERT INTO #mtcars_big_predictions

EXEC sp_execute_external_script
    @language = N'R'
    , @script = N'
            library(mtcarsmodel)
            OutputDataSet <- mtcarsmodel::predict_mtcars(mtcars_data);'
    , @input_data_1 = N'SELECT cyl, hp, wt FROM dbo.mtcars_big'
    , @input_data_1_name = N'mtcars_data';
--WITH RESULT SETS ((cyl INT, hp INT, wt DECIMAL(10, 2), predicted_mpg DECIMAL(10, 2)));

-- Seconds: 14

-- check results 
SELECT TOP 1000 * FROM #mtcars_big_predictions;
TRUNCATE TABLE #mtcars_big_predictions;

-- DROP TABLE dbo.mtcars_big;

-- Try this with clearing cache