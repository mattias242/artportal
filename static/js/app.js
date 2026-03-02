let allObservations = [];
const wikiCache = {};

async function fetchBirdInfo(scientificName) {
    if (wikiCache[scientificName]) return wikiCache[scientificName];

    for (const lang of ["sv", "en"]) {
        try {
            const url = `https://${lang}.wikipedia.org/api/rest_v1/page/summary/${encodeURIComponent(scientificName)}`;
            const res = await fetch(url);
            if (!res.ok) continue;
            const data = await res.json();
            if (data.type === "disambiguation") continue;
            const info = {
                imageUrl: data.thumbnail ? data.thumbnail.source : null,
                description: data.extract || "",
                wikiUrl: data.content_urls ? data.content_urls.desktop.page : null,
            };
            wikiCache[scientificName] = info;
            return info;
        } catch {
            continue;
        }
    }

    const fallback = { imageUrl: null, description: "", wikiUrl: null };
    wikiCache[scientificName] = fallback;
    return fallback;
}

function openModal(vernacular, scientific, taxonId) {
    const modal = document.getElementById("bird-modal");
    const img = modal.querySelector(".modal-image");
    const loading = modal.querySelector(".modal-loading");
    const noImage = modal.querySelector(".modal-no-image");
    const descEl = modal.querySelector(".modal-description");

    modal.querySelector(".modal-vernacular").textContent = vernacular;
    modal.querySelector(".modal-scientific").textContent = scientific;
    descEl.textContent = "";
    img.hidden = true;
    noImage.hidden = true;
    loading.hidden = false;

    if (taxonId) {
        const link = modal.querySelector(".modal-link");
        link.href = `https://artfakta.se/taxa/${taxonId}`;
        link.hidden = false;
    }

    modal.hidden = false;
    document.body.style.overflow = "hidden";

    fetchBirdInfo(scientific).then((info) => {
        loading.hidden = true;
        if (info.imageUrl) {
            img.src = info.imageUrl;
            img.alt = vernacular;
            img.hidden = false;
        } else {
            noImage.hidden = false;
        }
        if (info.description) {
            descEl.textContent = info.description;
        }
    });
}

function closeModal() {
    const modal = document.getElementById("bird-modal");
    modal.hidden = true;
    document.body.style.overflow = "";
}

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
        <div class="observation-card"
             data-vernacular="${escapeHtml(obs.taxonVernacular)}"
             data-scientific="${escapeHtml(obs.taxonScientific)}"
             data-taxon-id="${obs.taxonId || ""}">
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

document.getElementById("observations").addEventListener("click", (e) => {
    const card = e.target.closest(".observation-card");
    if (!card) return;
    openModal(
        card.dataset.vernacular,
        card.dataset.scientific,
        card.dataset.taxonId
    );
});

document.querySelector(".modal-backdrop").addEventListener("click", closeModal);
document.querySelector(".modal-close").addEventListener("click", closeModal);
document.addEventListener("keydown", (e) => {
    if (e.key === "Escape") closeModal();
});

loadObservations();
