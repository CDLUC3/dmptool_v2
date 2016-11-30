# Generate Statistics for every month in 2012-2016
# -------------------------------------------------
echo $PWD

for YEAR in 2012 2013 2014 2015 2016
do
  for MONTH in 1 2 3 4 5 6 7 8 9 10 11 12
  do
    echo "Generating statistics for $YEAR-$MONTH"
    bundle exec rake statistics:generate[$YEAR,$MONTH]
  done
done
