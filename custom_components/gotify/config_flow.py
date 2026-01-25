import voluptuous as vol
from homeassistant import config_entries

from .const import (
    DOMAIN,
    CONF_NAME,
    CONF_HOST,
    CONF_PORT,
    CONF_TOKEN,
    DEFAULT_NAME,
    DEFAULT_HOST,
    DEFAULT_PORT,
)


class GotifyConfigFlow(config_entries.ConfigFlow, domain=DOMAIN):
    VERSION = 1

    async def async_step_user(self, user_input=None):
        if user_input is not None:
            return self.async_create_entry(
                title=user_input[CONF_NAME],
                data=user_input,
            )

        schema = vol.Schema(
            {
                vol.Required(CONF_NAME, default=DEFAULT_NAME): str,
                vol.Required(CONF_HOST, default=DEFAULT_HOST): str,
                vol.Required(CONF_PORT, default=DEFAULT_PORT): int,
                vol.Required(CONF_TOKEN): str,
            }
        )

        return self.async_show_form(
            step_id="user",
            data_schema=schema,
        )
