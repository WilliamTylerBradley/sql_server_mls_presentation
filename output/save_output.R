# decktape command
# `npm bin`/decktape --screenshots --screenshots-size=960x700 --screenshots-format=png --screenshots-directory=Documents/github/sql_server_mls_presentation/output --slides 1-29 reveal https://williamtylerbradley.github.io/sql_server_mls_presentation/sql_server_mls_presentation.html slide.pdf
# this just keeps going if max slides are included

library(stringr)
file.rename(file.path("output", list.files(path="output/", pattern="slide_*")),
            file.path("output", sub("_960x700", "", list.files(path="output/", pattern="slide_*"))))
