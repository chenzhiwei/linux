from iwx import create_app

from settings import PROD as DEV 
app = create_app(DEV)
if __name__ == "__main__":
    app.run()
