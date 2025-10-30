We tag images three ways:
- latest               (moving)
- <SHA12>              (immutable)
- <YYYYMMDD>.<run>     (immutable, sortable)

Deployments use immutable tags:
- Staging: SHA12 (from latest commit)
- Prod:     same SHA12 once healthcheck passes

Rollbacks target a prior immutable tag.

