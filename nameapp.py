import os, datetime
from flask import Flask

app=Flask(__name__)

@app.route('/name')
def print_info():
    name = os.environ['NAME']
    password = os.environ['PASSWORD']
    dt = datetime.datetime.now().strftime("%d/%m/%Y %H:%M")
    msg = "{} Hello {}, your password is {}".format(dt, name, password) # "30/07/2021 12:00 Hello TG, your password is 1234”
    return msg

if __name__ == "__main__":
    app.run(host = '0.0.0.0',port = 5000, debug = False)