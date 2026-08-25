# 1. Introduction & Goals

BPMN, CMMN and DMN are business domain modeling languages defined by the Object Management Group (OMG) that should form the basis for DDD (Domain Driven Design) in the Business Layer.
The goal is to implement these models into an application engine so that the process of driving these models and modelling their states is not the purview of the DDD Business Layer.

## 1.1 Requirements Overview

1.1.1 To implement a structure for holding and driving BPMN, CMMN and DMN models.

1.1.2 To enable revisions of OMG models and the transition/rollback between them for active entities.

1.1.3 To develop the solution as a drop in Laravel Model

## 1.2 Quality Goals

| Priority | Quality Goal | Explanation |
| 1 | Correctness | The models implemented by the system should meet the specifications of the BPMN, CMMN and DMN models as defined by the Object Management Group (https://www.omg.org/) |
| 1 | Auditable | The system should be independantly verifiable |
| 2 | Simplicity | The system will form the bedrock of any DDD Business Layer. Unnecessary complications will make errors more likely |
| 3 | Performance | The system will need to be able to process 10,000 state transistions in < second. |

## Stakeholders

| Role/Name | Contact | Expectations |
|---|---|---|
| LOBStar | - | To have a functional system that meets the Quality Goals |

## References

[OMG](https://www.omg.org/)