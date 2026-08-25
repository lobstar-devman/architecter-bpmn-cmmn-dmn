# Sources of Truth

Every diagram and every generated page in this documentation traces back
to exactly one editable source-of-truth file. Never edit a diagram or a
generated page directly — edit the source and let the CI pipeline
regenerate everything downstream.

| Domain | Format | Location convention | Rendered via |
|---|---|---|---|
| Business process | BPMN 2.0 XML | `processes/*.bpmn` | [bpmn.io](https://bpmn.io) tooling |
| Case management | CMMN 1.1 XML | `processes/*.cmmn` | [bpmn.io](https://bpmn.io) tooling |
| Decision logic | DMN XML | `decisions/*.dmn` | [bpmn.io](https://bpmn.io) tooling |
| System structure (C4) | Structurizr DSL | `architecture/workspace.dsl` | Structurizr CLI |
| API contracts | OpenAPI (YAML/JSON) | `apis/*.openapi.yaml` | Redoc |
| UML (class/sequence/state) | Mermaid text | `architecture/*.mmd` | Mermaid CLI |
| ERD / database design | Mermaid `erDiagram` or SQL DDL | `data-model/*.mmd` or `data-model/schema.sql` | Mermaid CLI |
| Bespoke config/data | JSON + JSON Schema | `data/*.json` + `data/*.schema.json` | validated only, not rendered |

See the following pages for detail on each format:

- [BPMN / CMMN / DMN](bpmn-cmmn-dmn.md)
- [Structurizr DSL (C4)](structurizr-dsl.md)
- [OpenAPI](openapi.md)
- [JSON Schema](json-schema.md)
- [Mermaid (UML/ERD)](mermaid.md)
