# datefilter


## Usage

    datefilter
    
    Usage: datefilter [-F DELIMITER] [-i FMT] [-r FMT] FIELD COMPARISION-OP REFDATE
                      [-v]
      Filters DSV input by reference date
    
    Available options:
      -h,--help                Show this help text
      -F DELIMITER             Input delimiter. Default whitespace
      -i FMT                   Input date parse format. Default %Y-%m-%d
      -r FMT                   Ref date parse format. Default %Y-%m-%d
      FIELD                    Field position. Starts at 1.
      COMPARISION-OP           =, >, <, >=, OR <=. Enclose in quotes to prevent
                               clash with shell redirection ops
      REFDATE                  Reference date for comparison. Parsed with ref date
                               fmt
      -v                       Verbose logging
    
    Homepage: https://github.com/danchoi/datefilter. See
    http://hackage.haskell.org/package/time-1.5.0.1/docs/Data-Time-Format.html for
    format codes

Sample input:

    cat 2016-05-01
    dog 2016-05-03

Command and output:

    $ cat test | datefilter 2 '=' 2016-05-01 
    cat 2016-05-01

    $ cat test | datefilter 2 '>' 2016-05-01 
    dog 2016-05-03

Verbose logging:

    $ cat test | datefilter 2 '>' 2016-05-01 -v
    Log: Parsed reference date: 2016-05-01
    Log: Field value: "2016-05-01"
    Log: Parsed field date: Just 2016-05-01
    Log: Comparision result: Just False
    Log: Field value: "2016-05-03"
    Log: Parsed field date: Just 2016-05-03
    Log: Comparision result: Just True
    dog 2016-05-03

## Install

    stack install


