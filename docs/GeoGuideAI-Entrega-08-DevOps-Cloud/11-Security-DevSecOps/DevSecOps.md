# DevSecOps

## Pipeline
- secret scanning;
- dependency scanning;
- SAST;
- container scanning;
- IaC/config review;
- SBOM como evolución.

## Herramientas open source posibles
- Trivy
- Gitleaks
- Semgrep Community
- OWASP Dependency-Check

## Política
Critical/High deben evaluarse antes de liberar. Las excepciones se documentan con
riesgo, responsable y fecha de revisión.

Nunca imprimir secretos en logs de CI.
