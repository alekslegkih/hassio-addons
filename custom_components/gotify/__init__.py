from homeassistant.components.notify import DOMAIN as NOTIFY_DOMAIN
from homeassistant.helpers.discovery import async_load_platform

from .const import DOMAIN, CONF_NAME


async def async_setup_entry(hass, entry):
    hass.async_create_task(
        async_load_platform(
            hass,
            NOTIFY_DOMAIN,
            DOMAIN,
            entry.data,
            entry,
        )
    )
    return True
