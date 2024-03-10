#!/usr/bin/env python3
"""Tools Alert = Tools used for sending alerts via email, Telegram, Slack, etc.
Version 2021-01-07
added send_no_preview to send message without having a preview of the links
"""

from urllib.request import Request, urlopen
from urllib.parse import quote_plus, urlencode

import time
import json

import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText


class AlertTelegram:
    """Class to create a AlertTelegram object

    Steps to set up a new Telegram bot:
    ------------------------------------
    Go to Botfahter on Telegram
    Generate Bot / generate Token
    create group / add bot to a group
    https://api.telegram.org/bot<YourBOTToken>/getUpdates
    => get group id from this

    Example usage:
    from toolsalert import AlertTelegram
    telegram_alert = AlertTelegram("xxxxxxxxxxxxxxxxxx",xxxxxxx)
    telegram_alert.send("I send here a message\nwith two rows")

    Check if Telegram Alert properly went out:
    if telegram_alert.send_result is True:
        print("everything ok, update database")

    """

    API_URL = "https://api.telegram.org/bot{}/sendMessage?chat_id={}&text={}&parse_mode=html"
    API_URL_NO_PREVIEW = "https://api.telegram.org/bot{}/sendMessage?chat_id={}&text={}&parse_mode=html&disable_web_page_preview=True"
    API_URL_PHOTO = "https://api.telegram.org/bot{}/sendPhoto?chat_id={}&photo={}"

    def __init__(self, api_token, chat_id):
        self.api_token = api_token
        self.chat_id = chat_id
        self.send_result = False  # initialize as False initially

    def send(self, message):
        try:
            self.send_result = False
            api_message = quote_plus(message)  # to URL encode the message
            url = self.API_URL.format(
                self.api_token, self.chat_id, api_message)
            q = Request(url)
            # full contents in variable - added decode to get string instead of byte type
            dataapi = urlopen(q).read().decode('UTF-8')
            data = json.loads(dataapi)  # convert from json to data object
            print("Telegram send result:", data["ok"])
            self.send_result = data["ok"]
        except:
            self.send_result = False
            print("could not send Telegram message")

    def send_no_preview(self, message):
        try:
            self.send_result = False
            api_message = quote_plus(message)  # to URL encode the message
            url = self.API_URL_NO_PREVIEW.format(
                self.api_token, self.chat_id, api_message)
            q = Request(url)
            # full contents in variable - added decode to get string instead of byte type
            dataapi = urlopen(q).read().decode('UTF-8')
            data = json.loads(dataapi)  # convert from json to data object
            print("Telegram send result:", data["ok"])
            self.send_result = data["ok"]
        except:
            self.send_result = False
            print("could not send Telegram message")

    def send_photo(self, photo_url):
            # need to add timestamp to url to avoid cache
        try:
            url_timestamp = time.strftime('%Y-%m-%d-%H:%M:%S')
            photo_url_time = photo_url + "?a=" + url_timestamp
            self.send_result = False
            api_message = quote_plus(photo_url_time)  # to URL encode the message
            url = self.API_URL_PHOTO.format(
                self.api_token, self.chat_id, api_message)
            q = Request(url)
            # full contents in variable - added decode to get string instead of byte type
            dataapi = urlopen(q).read().decode('UTF-8')
            data = json.loads(dataapi)  # convert from json to data object
            print("Telegram send result:", data["ok"])
            self.send_result = data["ok"]
        except:
            self.send_result = False
            print("could not send Telegram message")


class AlertEmail:
    """Class to create an AlertEmail object

    Attention: need to be allowed to send email via Gmail -> G Suite emails work, if nothing else works

    Example usage:
    from toolsalert import AlertEmail
    email_alert= AlertEmail("smtp.gmail.com","xxxxx@xxxx.com", "xxxxxxxxxxxxxx",["xxxxx@xxxx.com"])
    email_alert.send("I send here a message\nwith two rows","Hello, this is the subject")

    """

    def __init__(self, server, fromaddr, password, toaddrlist):
        self.server = server
        self.fromaddr = fromaddr
        self.password = password
        self.toaddrlist = toaddrlist

    def send(self, message, subject="email alert"):  # default subject, if nothing is defined
        try:
            msg = MIMEMultipart()
            msg['From'] = self.fromaddr
            msg['To'] = ", ".join(self.toaddrlist)
            msg['Subject'] = subject

            msg.attach(MIMEText(message, 'plain'))

            server = smtplib.SMTP(self.server, 587)
            server.starttls()
            server.login(self.fromaddr, self.password)
            text = msg.as_string()
            server.sendmail(self.fromaddr, self.toaddrlist, text)
            server.quit()
            print("email sent")
        except:
            print("could not send Email message")


class AlertSlack:
    """Class to create an AlertSlack object

    Steps to set up a new Slack bot:
    2) Customize / get the API key

    Example usage:
    from toolsalert import AlertSlack
    slack_alert = AlertSlack("xxxxxxxxxxxxxxxxxx","xxxx","xxxx")
    slack_alert.send("I send here a message\nwith two rows")

    Check if Slack Alert properly went out:
    if slack_alert.send_result is True:
        print("everything ok, update database")

    """

    API_URL = "https://slack.com/api/chat.postMessage"

    def __init__(self, api_key, channel_name, bot_name="bot", emoji_name=None, as_user=False):
        self.api_token = api_key
        self.channel_name = channel_name
        self.bot_name = bot_name
        self.emoji_name = emoji_name
        self.as_user = as_user  # sends it as the bot username, using bot emoji
        self.send_result = False  # initialize as False initially

    def send(self, message):
        try:
            self.send_result = False
            data = urlencode({
                'token': self.api_token,
                'channel': self.channel_name,
                'username': self.bot_name,
                'as_user': self.as_user,
                'text': message,
                'icon_emoji': self.emoji_name
            }).encode()
            # this will make the method "POST"
            req = Request(self.API_URL, data)
    #             print(data)
            resp = urlopen(req).read().decode('UTF-8')
    #             print(resp)
            api_result = json.loads(resp)  # convert from json to data object
            print("Slack send result:", api_result["ok"])
            self.send_result = api_result["ok"]
        except:
            self.send_result = False
            print("Could not send Slack message")
