from flask import Flask, request
from werkzeug.middleware.dispatcher import DispatcherMiddleware
#from prometheus_client import make_wsgi_app
import settings
import topiccontrol
import producer
import consumer



PORT = 8000
MESSAGE = "Hello, world!\n"

serv=""
name=""
parts=""
reps=""

app = Flask(__name__)

@app.route("/")
def root():
    result = MESSAGE.encode("utf-8")
    return result

@app.route("/api/<serv>/<name>/<parts>/<reps>/topic/create")
def create(serv, name, parts, reps):
    t=topiccontrol.TOPIC(serv,name,parts,reps)
    print (t.name)
    return t.create()

@app.route("/api/<serv>/<name>/<parts>/<reps>/topic/listit")
def listit(serv, name, parts, reps):
    t=topiccontrol.TOPIC(serv,name,parts,reps)
    return t.list_my_topic()

@app.route("/api/<serv>/<name>/<parts>/<reps>/topic/delete")
def delete(serv, name, parts, reps):
    t=topiccontrol.TOPIC(serv,name,parts,reps)
    return t.delete_my_topic()

@app.route("/api/<serv>/<name>/<parts>/<reps>/topic/describe")
def describe(serv, name, parts, reps):
    t=topiccontrol.TOPIC(serv,name,parts,reps)
    return t.describe_my_topic()

@app.route("/api/<serv>/<name>/<parts>/<reps>/data/produce")
def produce(serv, name, parts, reps):
    p=producer.PROD(serv,name,parts,reps)
    return p.my_producer()

@app.route("/api/<serv>/<name>/<parts>/<reps>/data/consume")
def status(serv, name, parts, reps):
    c=consumer.CONS(serv,name,parts,reps)
    #def consume(self):
    #    yield c.my_consumer.my
    #    yield c.my_consumer()
    #return Response(consume(), mimetype='text/plain')
    return c.my_consumer()

#app_dispatch = DispatcherMiddleware(app, {
#    '/metrics': make_wsgi_app()
#})
    
if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=PORT)
