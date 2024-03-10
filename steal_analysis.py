#!/usr/bin/env python3

import pandas as pd
from datetime import datetime, timedelta

DAYS_BACK_DAILY = 10
DAYS_BACK_HOURLY = 1

print("\n***********************************")
print("* Steal checker - all values in % *")
print("***********************************\n")

#  date_limit_daily = (datetime.now() - timedelta(days=DAYS_BACK_DAILY)).date().strftime('%Y-%m-%d')
#  date_limit_hourly = (datetime.now() - timedelta(days=DAYS_BACK_HOURLY)).date().strftime('%Y-%m-%d')

date_limit_daily = (datetime.now() - timedelta(days=DAYS_BACK_DAILY))
date_limit_hourly = (datetime.now() - timedelta(days=DAYS_BACK_HOURLY))

#  print(date_limit_daily)
#  print(date_limit_hourly)

df = pd.read_csv("steal.csv", sep=",",
                 names=["datetime", "steal"],
                 #  names=["date", "hour", "minute", "steal"],
                 parse_dates=[0])

df["date"] = (df.datetime.dt.date)
df["hour"] = (df.datetime.dt.hour)

#  print(df.dtypes)
#  print(df)

filter_daily = df["datetime"] >= date_limit_daily
filter_hourly = df["datetime"] >= date_limit_hourly

print("*** Daily analysis ***\n")
df = df.where(filter_daily)

#  print("- Total items:", df.steal.count())
print("- Average Steal:", df.steal.mean().round(2))
print("- Maximum Steal:", df.steal.max(), "\n")
#  print(df.groupby(["date"])["steal"].mean().round(2))
print(df.groupby(["date"])["steal"].agg(['mean', 'max']).round(2))


print("\n\n*** Hourly analysis ***\n")
df = df.where(filter_hourly)

#  print("- Total items:", df.steal.count())
print("- Average Steal:", df.steal.mean().round(2))
print("- Maximum Steal:", df.steal.max(), "\n")
print(df.groupby(["date", "hour"])["steal"].agg(['mean', 'max']).round(2))
