# Jamii Savings — WSO2 MI 4.4 integration assignment

## Architecture
Three MI APIs are packaged in one CAR: H2-backed accounts, JSONPlaceholder customer proxy, and JSON-to-SOAP calculator adapter. API Manager is the intended OAuth2 gateway. H2 is embedded and initialized from `database/init.sql` using parameterized queries. This is **demonstration code**, not banking production software.

## Run locally
1. Install JDK and Maven compatible with MI 4.4; install WSO2 MI 4.4 and the H2 JDBC driver in `<MI_HOME>/lib`.
2. Copy  `init.sql` to `<MI_HOME>/repository/database/`; the file-based JDBC URL is relative to MI's working directory.
3. Run `cd wso2-mi && mvn clean install`. Confirm the `.car` file is a valid ZIP and contains the three APIs, data service and shared fault sequence.
4. Copy the generated `.car` to `<MI_HOME>/repository/deployment/server/carbonapps/`, start MI, and verify startup logs.
5. Run `python3 -m unittest discover -s tests -v` and `bash tests/smoke.sh` (requires curl and a running MI).
6. In API Manager, create/publish APIs from the OpenAPI files and configure MI endpoint URLs, OAuth2 security, and distinct throttling policies; use API Controller exports for CI-managed imports.

## Mapping and trade-offs
JSONPlaceholder `/users/{id}` supplies public mock customer profiles; only numeric IDs are accepted. DNE Online SOAP Calculator `Subtract(income,debt)` yields disposable-income proxy; decision is `ELIGIBLE` when result >= 10,000, otherwise `NOT_ELIGIBLE`.
**This is not a real creditworthiness assessment.** SOAP service availability is not guaranteed. H2 embedded mode is simple but not suitable for clustered production workloads.

## Error policy
All APIs use a shared `error.code`, `error.message`, `requestId`, `timestamp` structure. Accounts: 400 invalid numbers, 404 unknown accounts, 503 DB failures. Customers: 400 invalid ID, 404 unknown customers, 502/503 backend errors. Loans: 400 invalid fields, 502 SOAP fault, 503 unavailable. Logging records event names and IDs without account/customer PII.

## Outstanding integration checks
**Not runtime-verified:
** Confirm MI 4.4 artifact packaging, DataServiceCall schema, H2 URL/driver, timestamp ISO formatting, MessageID UUID semantics, SOAP wire format and public backend connectivity. Validate APIM project metadata against an actual `apictl export-api` before CI import. The repository does not yet contain an exported API Product or deployable custom gateway mediation policy. The Docker image tag and deployment paths must be checked for your MI distribution. Jenkins production gate is conceptual; production deployment and automatic rollback are not implemented.

## More time
Add real CI integration containers, schema/OpenAPI contract tests, idempotent APIM API Product export, custom gateway policy, deployment rollback, real OAuth2 tests, and secured secret management. API consumers discover the published APIs in the APIM Developer Portal, create an application, subscribe, and generate OAuth2 credentials.
