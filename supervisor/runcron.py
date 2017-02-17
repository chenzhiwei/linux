from iwx import create_app,sched

from settings import PROD as DEV 
app = create_app(DEV)
if __name__ == "__main__":
    sched.start()
    app.run(use_reloader=False)
