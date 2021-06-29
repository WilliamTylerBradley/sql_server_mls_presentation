-- mtcars database
CREATE TABLE dbo.mtcars(
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

INSERT INTO dbo.mtcars
EXEC sp_execute_external_script @language = N'R'
    , @script = N'MTCars <- mtcars;'
    , @input_data_1 = N''
    , @output_data_1_name = N'MTCars';

SELECT * FROM dbo.mtcars;

--DROP TABLE dbo.mtcars;