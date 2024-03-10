#!/usr/bin/env python3

import time
import pandas as pd
from datetime import datetime, timedelta
from toolsalert import AlertTelegram

HOURS_BACK_ALERT = 1
LIMIT_ALERT_AVG = 2.0
LIMIT_ALERT_MAX = 20.0

SERVER_NAME = "SERVER"

TELEGRAM_API_KEY = "xxxxx"
TELEGRAM_CHAT_ID = 999999999

print("{} - Start of Alert to check for high steal".format(time.strftime('%Y-%m-%d %H:%M:%S')))

telegram_alert = AlertTelegram(TELEGRAM_API_KEY, TELEGRAM_CHAT_ID)
result_msg = ""

date_limit_alert = (datetime.now() - timedelta(hours=HOURS_BACK_ALERT))

df = pd.read_csv("/home/moon/steal/steal.csv", sep=",",
                 names=["datetime", "steal"],
                 parse_dates=[0])

df["date"] = (df.datetime.dt.date)
df["hour"] = (df.datetime.dt.hour)

filter_alert = df["datetime"] >= date_limit_alert

df = df.where(filter_alert)

steal_alert_avg = df.steal.mean().round(2)
steal_alert_max = df.steal.max()

print("- Average Steal:", steal_alert_avg)
print("- Maximum Steal:", steal_alert_max, "\n")

if steal_alert_avg > LIMIT_ALERT_AVG or steal_alert_max > LIMIT_ALERT_MAX:
    result_msg = "{} - <b>{}%</b> avg steal, <b>{}%</b> max steal over {} hour".format(
        SERVER_NAME,
        steal_alert_avg,
        steal_alert_max,
        HOURS_BACK_ALERT
    )
    print(result_msg)
    telegram_alert.send(result_msg)
print("{} - End of Alert to check for high steal".format(time.strftime('%Y-%m-%d %H:%M:%S')))
