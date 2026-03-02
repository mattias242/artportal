# Project: Artportal

Mobile-friendly bird observation viewer. Configurable for any location via `.env`. Defaults to Jordhammarsviken, Stenungsund.

## Git workflow

- **Trunk-based development**: commit directly to `master`. No feature branches or PRs.

## Tech stack

- Python 3, Flask, vanilla HTML/CSS/JS
- SOS API (SLU Artdatabanken) for species observation data
- No build tools, no bundlers, no npm

## Running locally

```bash
pip install -r requirements.txt
python app.py
```

Requires `.env` with `SOS_API_KEY`. Use `SOS_API_KEY=mock` for dev without a key.

## Key files

- `app.py` - Flask routes, caching, response transformation
- `sos_client.py` - SOS API client with search filter builder
- `config.py` - Configuration from environment variables
- `templates/index.html` - Jinja2 template (Swedish)
- `static/css/style.css` - Mobile-first responsive CSS
- `static/js/app.js` - Frontend fetch, render, filter, sort, bird info modal (Wikipedia API)
