# Jamii Savings - WSO2 Integration

This repository contains the Micro Integrator (MI) services, API Manager (APIM) definitions, and CI/CD Jenkins pipeline for Jamii Savings Bank.

## Architecture Decisions & Trade-offs
*   **Database:** An embedded H2 database enables the MI Data Service to run self-contained in any environment without external dependencies.
*   **Mock Backends:**
    *   *(Proxy):* Uses `jsonplaceholder.typicode.com/users` to simulate a customer profile backend for reliable REST/JSON responses.
    *   *(SOAP-to-REST):* Uses the public `http://www.dneonline.com/calculator.asmx` SOAP service. Applicant income and debt are passed to the `Add` operation to simulate an eligibility score calculation.
*   **Error Handling:** A global fault sequence intercepts all transport, timeout, and SOAP faults, transforming them into a standard `{"error": {"code": "...", "message": "..."}}` JSON schema to prevent internal system leaks.
*   **API Product Grouping:** All three APIs are grouped into `JamiiBank_Core_Product`. Consumers subscribe once and access Accounts, Customers, and Loans APIs via a single application token.

## What I'd Do Differently With More Time
1.  **Security:** Implement HashiCorp Vault integration in MI for database credentials instead of plain text/secure vault properties.
2.  **Observability:** Integrate Jaeger/Zipkin via WSO2 OpenTelemetry extensions for distributed tracing across APIM, MI, and backend services.
3.  **Testing:** Add automated Postman/Newman collections into the Jenkins pipeline to validate integration health prior to APIM deployment.

## Assumptions
*   Jenkins has the WSO2 `apictl` CLI installed and configured with target environment credentials.
*   WSO2 MI and APIM run locally via Docker Compose on standard ports (8290, 9443).
*   The Data Service relies on inline queries rather than separate nested queries to minimize artifact count.

## Local Environment Setup
1.  **Build MI Artifacts:**
    Use the modern WSO2 code-first Maven plugin to build the Composite Application.
    ```bash
    cd wso2-mi
    mvn clean install
    cd ..
    ```
2.  **Start Infrastructure:**
    Run Docker Compose. The generated `.car` artifact and H2 database script map automatically via volumes.
    ```bash
    docker-compose up -d --force-recreate
    ```
3.  **Deploy APIM Artifacts:**
    Configure the local environment and deploy via the WSO2 API Controller (`apictl`).
    ```bash
    apictl add-env dev --apim https://localhost:9443
    apictl login dev -u admin -p admin -k
    
    apictl import-api -f ./apim-artifacts/AccountsAPI -e dev -k
    apictl import-api -f ./apim-artifacts/CustomersAPI -e dev -k
    apictl import-api -f ./apim-artifacts/LoansAPI -e dev -k
    apictl import-api-product -f ./apim-artifacts/JamiiBankProduct -e dev -k
    ```
4.  **Test via Developer Portal:**
    Navigate to `https://localhost:9443/devportal`. Under **API Products**, select **JamiiBank Core**, subscribe, generate a Production OAuth2 token, and execute requests.

## Enterprise Integration Patterns

### Aggregation API
When aggregating a Customer Profile and Account Balance in parallel (using `<clone>` or `<call>` mediators in MI), a timeout in one backend should return partial data (e.g., `{"customer": {...}, "account": null, "warnings": ["Account service degraded"]}`). Failing the entire request outright negates the resilience benefits of microservice architecture.

### Message Queue Integration
Message Queue integrations are strictly asynchronous. Unlike HTTP REST APIs that can immediately return 4xx/5xx status codes, a malformed JMS/Kafka message cannot return an error to the producer. It must be routed to a Dead Letter Channel (DLC) for manual intervention while the consumer acknowledges the initial message to prevent infinite poison-pill retry loops.