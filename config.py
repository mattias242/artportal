import os
from dotenv import load_dotenv

load_dotenv()


class Config:
    SOS_API_KEY = os.getenv("SOS_API_KEY", "mock")
    SOS_BASE_URL = "https://api.artdatabanken.se/species-observation-system/v1"

    SITE_NAME = os.getenv("SITE_NAME", "Fågelobservationer")
    SITE_DESCRIPTION = os.getenv("SITE_DESCRIPTION", "Senaste observationer")

    SITE_LATITUDE = float(os.getenv("SITE_LATITUDE", "58.073"))
    SITE_LONGITUDE = float(os.getenv("SITE_LONGITUDE", "11.793"))
    SITE_RADIUS_METERS = int(os.getenv("SITE_RADIUS_METERS", "2000"))

    DAYS_BACK = int(os.getenv("DAYS_BACK", "7"))
    TAXON_ID = 4000104  # Aves (alla fåglar)
    CACHE_TTL = int(os.getenv("CACHE_TTL", "300"))
    FLASK_PORT = int(os.getenv("FLASK_PORT", "5000"))
