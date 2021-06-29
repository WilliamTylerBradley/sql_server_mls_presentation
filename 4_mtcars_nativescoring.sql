-- Input data set
SELECT mpg, cyl, hp, wt FROM dbo.mtcars;

-- Build the model -----------------------------------------------------------------------
DECLARE @model varbinary(max);
EXECUTE sp_execute_external_script
  @language = N'R'
  , @script = N'
    cars_model <- rxLinMod(mpg ~ cyl + hp + wt, data = mtcars_data)
    model <- rxSerializeModel(cars_model, realtimeScoringOnly = TRUE)'
  , @input_data_1 = N'SELECT mpg, cyl, hp, wt FROM dbo.mtcars'
  , @input_data_1_name = N'mtcars_data'
  , @params = N'@model varbinary(max) OUTPUT'
  , @model = @model OUTPUT
  INSERT [dbo].[predictive_models]([model_name], [model])
  VALUES('native_scoring', @model) ;

SELECT * FROM [master].[dbo].[predictive_models];

--DROP TABLE dbo.predictive_models;

-- Run model ---------------------------------------------------------------------------
DECLARE @model varbinary(max) = (
  SELECT model
  FROM [master].[dbo].[predictive_models]
  WHERE model_name = 'native_scoring');

SELECT d.*, p.*
  FROM PREDICT(MODEL = @model, DATA = dbo.mtcars as d)
  WITH(mpg_Pred float) as p;

--DROP TABLE dbo.predictive_models;