import time

from flask import Flask, jsonify, render_template
from config import Config
from sos_client import SOSClient

app = Flask(__name__)
client = SOSClient()

_cache = {"data": None, "timestamp": 0}


def transform_observations(raw_records):
    results = []
    for obs in raw_records:
        taxon = obs.get("taxon", {})
        event = obs.get("event", {})
        occurrence = obs.get("occurrence", {})
        location = obs.get("location", {})

        # Parse ISO date "2026-03-01T09:00:00+01:00" into date and time
        start_date_str = event.get("startDate", "")
        obs_date = ""
        obs_time = ""
        if start_date_str:
            if "T" in start_date_str:
                date_part, time_part = start_date_str.split("T", 1)
                obs_date = date_part
                obs_time = time_part[:5]  # "09:00"
            else:
                obs_date = start_date_str[:10]

        results.append(
            {
                "taxonId": taxon.get("id"),
                "taxonVernacular": (taxon.get("vernacularName", "") or "").capitalize(),
                "taxonScientific": taxon.get("scientificName", ""),
                "date": obs_date,
                "time": obs_time,
                "count": occurrence.get("organismQuantityInt"),
                "recordedBy": occurrence.get("recordedBy", ""),
                "locality": location.get("locality", ""),
                "municipality": location.get("municipality", {}).get("name", ""),
            }
        )
    return results


def get_cached_observations():
    now = time.time()
    if _cache["data"] is None or (now - _cache["timestamp"]) > Config.CACHE_TTL:
        raw = client.search_observations()
        _cache["data"] = transform_observations(raw)
        _cache["timestamp"] = now
    return _cache["data"]


@app.route("/")
def index():
    return render_template(
        "index.html",
        site_name=Config.SITE_NAME,
        site_description=Config.SITE_DESCRIPTION,
        days_back=Config.DAYS_BACK,
    )


@app.route("/api/observations")
def api_observations():
    try:
        observations = get_cached_observations()
        return jsonify({"observations": observations, "count": len(observations)})
    except Exception as e:
        return jsonify({"error": str(e)}), 502


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=Config.FLASK_PORT)
