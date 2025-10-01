# Veritas H.77

Centralni sustav za forenzički točan ingest, verifikaciju, konsolidaciju i meta-analitiku hrvatskih zakona (Narodne novine) uz strogu kontrolu integriteta (hash članka, Merkle, chain), patch workflow i digitalni ured asistiran agentima.

## Ključne značajke (roadmap)
- HTML/PDF/OCR ingest (deterministički parser članaka)
- Canonical JSON shema (v1.1.0 -> evolucija)
- Hash per članku + hash_law + Merkle stablo
- Patch workflow (proposed → approved → applied) + risk scoring
- Cross‑reference enrichment (internal / external canonical_id)
- Meta & semantic (embedding meta only – bez punog normativa)
- Forensic bundle export + GPG potpis + manifest
- Annotation overlay + revisions + diff
- URL-based auto ingest/update job queue ("paste URL" UX)
- Integrity dashboard + policy metrics (LLM guard, RBAC događaji)

## Struktura (inicijalna)
veritas_h77/
  veritas/
    api/
    core/
    agents/
    assistant/
    consolidation/
    services/
    annotations/
    logging/
  tests/
  scripts/

## Brzi start
```bash
python -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate
pip install -r requirements.txt
uvicorn veritas.api.server:app --reload
pytest -q
```

## Licence
MIT (privremeno – promijeni ako treba).