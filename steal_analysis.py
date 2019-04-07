#!/usr/bin/env python3

import pandas as pd
df1 = pd.read_csv("steal_tracking.txt", sep=",",
                  names=["date", "hour", "minute", "steal"])
#  print(df1)
print("hourly steal averages in %:")
print(df1.groupby(["date", "hour"])["steal"].mean())
