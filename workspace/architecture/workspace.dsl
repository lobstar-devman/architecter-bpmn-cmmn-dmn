workspace "BPM Engine" "System structure (C4) for the BPM Engine, a BPMN/CMMN/DMN model engine." {

    model {
        modelAuthor = person "Model Author" "Authors BPMN, CMMN, and DMN model definitions using external tooling (e.g. bpmn.io)."
        endUser = person "End User" "Triggers state transitions indirectly through the host application's own UI/API."

        bpmEngine = softwareSystem "BPM Engine" "Holds and drives BPMN, CMMN, and DMN models as a drop-in Laravel Model, enabling revisioned entities to transition and roll back between model versions." "ThisSystem" {

            bpmPackage = container "BPM Engine Package" "The Composer package installed into the host application; contains all model engine logic and is deployed in-process (no separate runtime)." "Laravel Package" {

                modelRegistry = component "Model Registry" "Loads, validates, and stores BPMN/CMMN/DMN XML definitions and their revisions."
                revisionManager = component "Revision Manager" "Manages transitions between model revisions for active entities, including rollback."
                eventStore = component "Event Store" "Persists the event-sourced log of state transitions."
                queueDispatcher = component "Queue Dispatcher" "Groups entities sharing the same triggering event and model revision into fixed-size batches, and dispatches one Laravel queue job per batch for horizontal scale-out."

                bpmnParser = component "BPMN Parser" "Parses BPMN 2.0 XML into the internal process representation."
                bpmnInterpreter = component "BPMN Interpreter" "Drives entities through a parsed BPMN process model."

                cmmnParser = component "CMMN Parser" "Parses CMMN 1.1 XML into the internal case representation."
                cmmnInterpreter = component "CMMN Interpreter" "Drives entities through a parsed CMMN case model."

                dmnParser = component "DMN Parser" "Parses DMN XML into the internal decision-table representation."
                dmnEvaluator = component "DMN Evaluator" "Evaluates a parsed DMN decision model against input data."

                modelRegistry -> bpmnParser "Hands loaded BPMN XML to"
                modelRegistry -> cmmnParser "Hands loaded CMMN XML to"
                modelRegistry -> dmnParser "Hands loaded DMN XML to"

                revisionManager -> bpmnInterpreter "Drives transitions via"
                revisionManager -> cmmnInterpreter "Drives transitions via"
                revisionManager -> dmnEvaluator "Requests decision evaluation via"
                revisionManager -> eventStore "Persists transition events to"
                revisionManager -> modelRegistry "Resolves target model revision via"

                queueDispatcher -> revisionManager "Dispatches queued bulk transitions to"
            }
        }

        hostApp = softwareSystem "Consuming Laravel Application" "A Laravel application that installs the BPM Engine package and uses it within its own DDD Business Layer."

        modelAuthor -> modelRegistry "Provides BPMN/CMMN/DMN XML model definitions to"
        endUser -> hostApp "Triggers state transitions through"
        hostApp -> bpmPackage "Uses in-process (PHP API); reads/writes state to shared Postgres database; subscribes to Laravel events from"

        deploymentEnvironment "Generic" {
            deploymentNode "Host Application Infrastructure" "Whatever infrastructure the consuming Laravel application runs on — deployment is entirely inherited from the host app, not prescribed by this package." {
                deploymentNode "Web / App Servers" "Handles synchronous, single-entity transitions." {
                    containerInstance bpmPackage
                }
                deploymentNode "Queue Workers" "Runs `php artisan queue:work`; consumes bulk-transition jobs dispatched by the Queue Dispatcher." {
                    containerInstance bpmPackage
                }
                deploymentNode "PostgreSQL" "Shared database instance holding this package's tables (model registry, event store)."
            }
        }
    }

    views {
        systemContext bpmEngine "SystemContext" {
            include *
            autoLayout
        }

        container bpmEngine "Containers" {
            include *
            autoLayout
        }

        component bpmPackage "Components" {
            include *
            autoLayout
        }

        deployment bpmEngine "Generic" "Deployment" {
            include *
            autoLayout
        }

        styles {
            element "Software System" {
                background #1168bd
                color #ffffff
            }
            element "ThisSystem" {
                background #0b4884
            }
            element "Person" {
                shape person
                background #08427b
                color #ffffff
            }
            element "Container" {
                background #438dd5
                color #ffffff
            }
            element "Component" {
                background #85bbf0
                color #000000
            }
        }
    }
}
