#!/usr/bin/env python3

import pandas as pd
from datetime import datetime, timedelta

DAYS_BACK_DAILY = 10
DAYS_BACK_HOURLY = 1
HOURS_BACK_ALERT = 1

LIMIT_ALERT_AVG = 2.0
LIMIT_ALERT_MAX = 20.0
#  LIMIT_ALERT_MAX = 0.5


print("\n***********************************")
print("* Steal checker - all values in % *")
print("***********************************\n")

#  date_limit_daily = (datetime.now() - timedelta(days=DAYS_BACK_DAILY)).date().strftime('%Y-%m-%d')
#  date_limit_hourly = (datetime.now() - timedelta(days=DAYS_BACK_HOURLY)).date().strftime('%Y-%m-%d')

date_limit_daily = (datetime.now() - timedelta(days=DAYS_BACK_DAILY))
date_limit_hourly = (datetime.now() - timedelta(days=DAYS_BACK_HOURLY))
date_limit_alert = (datetime.now() - timedelta(hours=HOURS_BACK_ALERT))

#  print(date_limit_daily)
#  print(date_limit_hourly)
#  print(date_limit_alert)

df = pd.read_csv("steal_tracking.txt", sep=",",
                 names=["datetime", "steal"],
                 #  names=["date", "hour", "minute", "steal"],
                 parse_dates=[0])

df["date"] = (df.datetime.dt.date)
df["hour"] = (df.datetime.dt.hour)

#  print(df.dtypes)
#  print(df)

filter_daily = df["datetime"] >= date_limit_daily
filter_hourly = df["datetime"] >= date_limit_hourly
filter_alert = df["datetime"] >= date_limit_alert

print("*** Daily analysis ***\n")
df.where(filter_daily, inplace=True)

#  print("- Total items:", df.steal.count())
print("- Average Steal:", df.steal.mean().round(2))
print("- Maximum Steal:", df.steal.max(), "\n")
#  print(df.groupby(["date"])["steal"].mean().round(2))
print(df.groupby(["date"])["steal"].agg(['mean', 'max']).round(2))


print("\n\n*** Hourly analysis ***\n")
df.where(filter_hourly, inplace=True)

#  print("- Total items:", df.steal.count())
print("- Average Steal:", df.steal.mean().round(2))
print("- Maximum Steal:", df.steal.max(), "\n")
print(df.groupby(["date", "hour"])["steal"].agg(['mean', 'max']).round(2))

print("\n\n*** Short term alert check ***\n")
df.where(filter_alert, inplace=True)

steal_alert_avg = df.steal.mean().round(2)
steal_alert_max = df.steal.max()

print("- Average Steal:", steal_alert_avg)
print("- Maximum Steal:", steal_alert_max, "\n")

if steal_alert_avg > LIMIT_ALERT_AVG or steal_alert_max > LIMIT_ALERT_MAX:
    print("*** STEAL IS TOO HIGH !!! ***")
