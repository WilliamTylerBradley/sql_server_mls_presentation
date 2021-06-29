-- Input data set
SELECT mpg, cyl, hp, wt FROM dbo.mtcars;
-- 1974 Motor Trends
-- miles per gallon
-- number of cylinders
-- horse power
-- weight (1000 lbs)

-- Build the model -----------------------------------------------------------------------
EXEC sp_execute_external_script
    @language = N'R'
    , @script = N'cars_model <- lm(mpg ~ cyl + hp + wt, data = mtcars_data);
        trained_model <- data.frame(model = as.raw(serialize(cars_model, connection=NULL)));'
    , @input_data_1 = N'SELECT mpg, cyl, hp, wt FROM dbo.mtcars'
    , @input_data_1_name = N'mtcars_data'
    , @output_data_1_name = N'trained_model'
    WITH RESULT SETS ((model VARBINARY(max)))

CREATE TABLE predictive_models (
    model_name varchar(30) not null default('default model') primary key,
    model varbinary(max) not null
);

INSERT INTO predictive_models(model)
EXEC sp_execute_external_script
    @language = N'R'
    , @script = N'cars_model <- lm(mpg ~ cyl + hp + wt, data = mtcars_data);
        trained_model <- data.frame(model = as.raw(serialize(cars_model, connection=NULL)));'
    , @input_data_1 = N'SELECT mpg, cyl, hp, wt FROM MTCars'
    , @input_data_1_name = N'mtcars_data'
    , @output_data_1_name = N'trained_model';

SELECT * FROM [master].[dbo].[predictive_models];

UPDATE predictive_models
SET model_name = 'lm_' + format(getdate(), 'dd-MM-yy')
WHERE model_name = 'default model'

SELECT * FROM [master].[dbo].[predictive_models];

--DROP TABLE dbo.predictive_models;

-- Run model ---------------------------------------------------------------------------
DECLARE @selected_lmmodel varbinary(max) = 
    (SELECT model FROM dbo.predictive_models WHERE model_name = 'lm_17-11-20');

EXEC sp_execute_external_script
    @language = N'R'
    , @script = N'
            current_model <- unserialize(as.raw(lmmodel));
            new <- data.frame(mtcars_data);
            predicted.am <- predict(current_model, new);
            str(predicted.am);
            OutputDataSet <- cbind(new, predicted.am);
            '
    , @input_data_1 = N'SELECT cyl, hp, wt FROM dbo.mtcars'
    , @input_data_1_name = N'mtcars_data'
    , @params = N'@lmmodel varbinary(max)'
    , @lmmodel = @selected_lmmodel
WITH RESULT SETS ((cyl INT, hp INT, wt DECIMAL(10, 2), predicted_mpg DECIMAL(10, 2)));