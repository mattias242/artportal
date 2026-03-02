import requests
from datetime import datetime, timedelta
from config import Config

MOCK_DATA = [
    {
        "taxon": {"id": 100045, "vernacularName": "Knölsvan", "scientificName": "Cygnus olor"},
        "event": {"plainStartDate": "2026-03-01", "plainStartTime": "08:15"},
        "occurrence": {"organismQuantityInt": 4, "organismQuantityUnit": "individer", "recordedBy": "Anna Svensson"},
        "location": {"locality": "Jordhammarsviken", "municipality": {"name": "Stenungsund"}},
    },
    {
        "taxon": {"id": 100067, "vernacularName": "Vigg", "scientificName": "Aythya fuligula"},
        "event": {"plainStartDate": "2026-03-01", "plainStartTime": "08:15"},
        "occurrence": {"organismQuantityInt": 12, "organismQuantityUnit": "individer", "recordedBy": "Anna Svensson"},
        "location": {"locality": "Jordhammarsviken", "municipality": {"name": "Stenungsund"}},
    },
    {
        "taxon": {"id": 100096, "vernacularName": "Storskrake", "scientificName": "Mergus merganser"},
        "event": {"plainStartDate": "2026-02-28", "plainStartTime": "10:30"},
        "occurrence": {"organismQuantityInt": 6, "organismQuantityUnit": "individer", "recordedBy": "Erik Johansson"},
        "location": {"locality": "Jordhammarsviken", "municipality": {"name": "Stenungsund"}},
    },
    {
        "taxon": {"id": 100550, "vernacularName": "Havsörn", "scientificName": "Haliaeetus albicilla"},
        "event": {"plainStartDate": "2026-02-28", "plainStartTime": "11:45"},
        "occurrence": {"organismQuantityInt": 1, "organismQuantityUnit": "individer", "recordedBy": "Lars Nilsson"},
        "location": {"locality": "Jordhammarsviken", "municipality": {"name": "Stenungsund"}},
    },
    {
        "taxon": {"id": 102956, "vernacularName": "Talgoxe", "scientificName": "Parus major"},
        "event": {"plainStartDate": "2026-02-27", "plainStartTime": "09:00"},
        "occurrence": {"organismQuantityInt": 3, "organismQuantityUnit": "individer", "recordedBy": "Maria Karlsson"},
        "location": {"locality": "Jordhammarsviken", "municipality": {"name": "Stenungsund"}},
    },
    {
        "taxon": {"id": 100376, "vernacularName": "Gråhäger", "scientificName": "Ardea cinerea"},
        "event": {"plainStartDate": "2026-02-27", "plainStartTime": "07:30"},
        "occurrence": {"organismQuantityInt": 2, "organismQuantityUnit": "individer", "recordedBy": "Erik Johansson"},
        "location": {"locality": "Jordhammarsviken", "municipality": {"name": "Stenungsund"}},
    },
    {
        "taxon": {"id": 100179, "vernacularName": "Sothöna", "scientificName": "Fulica atra"},
        "event": {"plainStartDate": "2026-02-26", "plainStartTime": "14:20"},
        "occurrence": {"organismQuantityInt": 8, "organismQuantityUnit": "individer", "recordedBy": "Anna Svensson"},
        "location": {"locality": "Jordhammarsviken", "municipality": {"name": "Stenungsund"}},
    },
    {
        "taxon": {"id": 102954, "vernacularName": "Blåmes", "scientificName": "Cyanistes caeruleus"},
        "event": {"plainStartDate": "2026-02-25", "plainStartTime": "08:45"},
        "occurrence": {"organismQuantityInt": 5, "organismQuantityUnit": "individer", "recordedBy": "Maria Karlsson"},
        "location": {"locality": "Jordhammarsviken", "municipality": {"name": "Stenungsund"}},
    },
]


class SOSClient:
    def __init__(self):
        self.base_url = Config.SOS_BASE_URL
        self.headers = {
            "Ocp-Apim-Subscription-Key": Config.SOS_API_KEY,
            "Content-Type": "application/json",
        }

    def _build_search_filter(self):
        start_date = (datetime.now() - timedelta(days=Config.DAYS_BACK)).strftime("%Y-%m-%d")
        end_date = datetime.now().strftime("%Y-%m-%d")

        return {
            "dataProvider": {"ids": [1]},
            "taxon": {
                "ids": [Config.TAXON_ID],
                "includeUnderlyingTaxa": True,
            },
            "date": {
                "startDate": start_date,
                "endDate": end_date,
                "dateFilterType": "OverlappingStartDateAndEndDate",
            },
            "geographics": {
                "geometries": [
                    {
                        "type": "Point",
                        "coordinates": [Config.SITE_LONGITUDE, Config.SITE_LATITUDE],
                    }
                ],
                "maxDistanceFromPoint": Config.SITE_RADIUS_METERS,
                "considerObservationAccuracy": True,
            },
            "output": {"fieldSet": "Minimum"},
        }

    def search_observations(self, skip=0, take=200):
        if Config.SOS_API_KEY == "mock":
            return MOCK_DATA

        url = f"{self.base_url}/Observations/Search"
        params = {
            "skip": skip,
            "take": take,
            "sortBy": "event.startDate",
            "sortOrder": "Desc",
        }
        body = self._build_search_filter()
        response = requests.post(
            url, headers=self.headers, json=body, params=params, timeout=15
        )
        response.raise_for_status()
        data = response.json()
        return data.get("records", data) if isinstance(data, dict) else data
