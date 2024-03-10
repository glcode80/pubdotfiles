#!/usr/bin/env python3

import pandas as pd
from datetime import datetime, timedelta

DAYS_BACK_DAILY = 10
DAYS_BACK_HOURLY = 1

print("\n***********************************************************")
print("* Loadavg(1min) checker - all values decimal (1.0 = 100%) *")
print("***********************************************************\n")

date_limit_daily = (datetime.now() - timedelta(days=DAYS_BACK_DAILY))
date_limit_hourly = (datetime.now() - timedelta(days=DAYS_BACK_HOURLY))

df = pd.read_csv("loadavg.csv", sep=",",
                 names=["datetime", "loadavg"],
                 parse_dates=[0])

df["date"] = (df.datetime.dt.date)
df["hour"] = (df.datetime.dt.hour)

filter_daily = df["datetime"] >= date_limit_daily
filter_hourly = df["datetime"] >= date_limit_hourly

print("*** Daily analysis ***\n")
df = df.where(filter_daily)

#  print("- Total items:", df.steal.count())
print("- Average Loadavg:", df.loadavg.mean().round(2))
print("- Maximum Loadavg:", df.loadavg.max(), "\n")
print(df.groupby(["date"])["loadavg"].agg(['mean', 'max']).round(2))


print("\n\n*** Hourly analysis ***\n")
df = df.where(filter_hourly)

print("- Average Loadavg:", df.loadavg.mean().round(2))
print("- Maximum Loadavg:", df.loadavg.max(), "\n")
print(df.groupby(["date", "hour"])["loadavg"].agg(['mean', 'max']).round(2))
