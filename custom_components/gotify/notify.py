import requests
from homeassistant.components.notify import BaseNotificationService
from homeassistant.const import ATTR_TITLE

class GotifyNotificationService(BaseNotificationService):
    def __init__(self, host, port, token, name):
        self._name = name
        self._url = f"http://{host}:{port}/message?token={token}"

    def send_message(self, message, **kwargs):
        payload = {
            "message": message,
            "title": kwargs.get(ATTR_TITLE, "Home Assistant"),
        }

        requests.post(
            self._url,
            json=payload,
            timeout=10,
        )
