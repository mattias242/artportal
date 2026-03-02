# Fåglar vid Jordhammarsviken

Mobilanpassad webbsida som visar senaste fågelobservationer vid Jordhammarsviken, Stenungsund. Data hämtas från [Artportalen](https://www.artportalen.se) via [SOS API:et](https://github.com/biodiversitydata-se/SOS) (Species Observation System) från SLU Artdatabanken.

## Funktioner

- Visar senaste fågelobservationer med art, datum, observatör och antal
- Sök/filtrera på artnamn i realtid
- Sortera efter datum, art eller antal individer
- Mobilanpassad layout (responsiv)
- Server-side cache (5 min) för snabb laddning

## Kom igång

### 1. Installera beroenden

```bash
pip install -r requirements.txt
```

### 2. Konfigurera

Kopiera `.env.example` till `.env` och fyll i din API-nyckel:

```bash
cp .env.example .env
```

Du behöver en prenumerationsnyckel för **"Species Observations - multiple data resources"** från [api-portal.artdatabanken.se](https://api-portal.artdatabanken.se/).

### 3. Starta

```bash
python app.py
```

Öppna http://localhost:5000

### Testläge (utan API-nyckel)

Sätt `SOS_API_KEY=mock` i `.env` för att köra med exempeldata.

## Konfiguration

Alla inställningar görs i `.env`:

| Variabel | Beskrivning | Standard |
|----------|-------------|----------|
| `SOS_API_KEY` | API-nyckel från Artdatabanken | (obligatorisk) |
| `SITE_NAME` | Sidans rubrik | Fågelobservationer |
| `SITE_DESCRIPTION` | Sidans underrubrik | Senaste observationer |
| `SITE_LATITUDE` | Latitud för platsen | 58.073 |
| `SITE_LONGITUDE` | Longitud för platsen | 11.793 |
| `SITE_RADIUS_METERS` | Sökradie i meter | 2000 |
| `DAYS_BACK` | Antal dagar bakåt | 7 |
| `CACHE_TTL` | Cache-tid i sekunder | 300 |

## Teknikstack

- **Backend:** Python, Flask
- **Frontend:** Vanilla HTML/CSS/JS
- **API:** SOS API v1 (SLU Artdatabanken)
