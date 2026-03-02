let allObservations = [];

function escapeHtml(text) {
    const div = document.createElement("div");
    div.textContent = text;
    return div.innerHTML;
}

function renderObservations() {
    const container = document.getElementById("observations");
    const filterText = document.getElementById("filter-input").value.toLowerCase();
    const sortKey = document.getElementById("sort-select").value;

    let filtered = allObservations.filter(
        (obs) =>
            obs.taxonVernacular.toLowerCase().includes(filterText) ||
            obs.taxonScientific.toLowerCase().includes(filterText)
    );

    filtered.sort((a, b) => {
        switch (sortKey) {
            case "date-desc":
                return (b.date + (b.time || "")).localeCompare(a.date + (a.time || ""));
            case "date-asc":
                return (a.date + (a.time || "")).localeCompare(b.date + (b.time || ""));
            case "species-asc":
                return a.taxonVernacular.localeCompare(b.taxonVernacular, "sv");
            case "count-desc":
                return (b.count || 0) - (a.count || 0);
            default:
                return 0;
        }
    });

    if (filtered.length === 0) {
        container.innerHTML =
            '<div class="no-results">Inga observationer hittades.</div>';
        return;
    }

    container.innerHTML = filtered
        .map(
            (obs) => `
        <div class="observation-card">
            <div class="species-name">${escapeHtml(obs.taxonVernacular)}</div>
            <div class="scientific-name">${escapeHtml(obs.taxonScientific)}</div>
            <div class="meta">
                <span>${escapeHtml(obs.date)}${obs.time ? " " + escapeHtml(obs.time) : ""}</span>
                <span>${escapeHtml(obs.recordedBy || "Okänd observatör")}</span>
                ${obs.count ? `<span>${obs.count} ind.</span>` : ""}
                ${obs.locality ? `<span>${escapeHtml(obs.locality)}</span>` : ""}
            </div>
        </div>
    `
        )
        .join("");
}

function updateSummary(total, filtered) {
    const days = window.__daysBack || 7;
    const summary = document.getElementById("summary");
    if (filtered !== undefined && filtered !== total) {
        summary.textContent = `Visar ${filtered} av ${total} observationer (senaste ${days} dagarna)`;
    } else {
        summary.textContent = `${total} observationer de senaste ${days} dagarna`;
    }
}

async function loadObservations() {
    const loading = document.getElementById("loading");
    const errorEl = document.getElementById("error");
    loading.hidden = false;
    errorEl.hidden = true;

    try {
        const res = await fetch("/api/observations");
        if (!res.ok) throw new Error(`Serverfel (${res.status})`);
        const data = await res.json();

        if (data.error) throw new Error(data.error);

        allObservations = data.observations;
        renderObservations();
        updateSummary(data.count);
    } catch (err) {
        errorEl.textContent = `Kunde inte ladda observationer: ${err.message}`;
        errorEl.hidden = false;
    } finally {
        loading.hidden = true;
    }
}

document.getElementById("filter-input").addEventListener("input", () => {
    renderObservations();
    const filterText = document.getElementById("filter-input").value.toLowerCase();
    const filtered = allObservations.filter(
        (obs) =>
            obs.taxonVernacular.toLowerCase().includes(filterText) ||
            obs.taxonScientific.toLowerCase().includes(filterText)
    );
    updateSummary(allObservations.length, filtered.length);
});

document.getElementById("sort-select").addEventListener("change", renderObservations);

loadObservations();
