// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_azure_sql_database/otel_azure_sql_database.dart';

/// Traces Azure SQL Database calls with OpenTelemetry.
///
/// `otel_azure_sql_database` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Azure SQL Database call in
/// [tracedAzureSqlDatabase]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'azure-sql-database-example');

  // Wraps an Azure SQL Database call in a CLIENT span.
  final azureSqlDatabaseId = await tracedAzureSqlDatabase<String>(
    operation: 'manage.database.create',
    invoke: () async {
      // Make the Azure SQL Database call here, then report what it returned.
      const id = 'azure_sql_database_8f3a2c';
      return const AzureSqlDatabaseCallResult(
          value: id,
          result: AzureSqlDatabaseResult(
              server: '<server>.database.windows.net',
              database: 'example',
              deploymentKind: 'single_database',
              elasticPool: 'example',
              sku: 'GP_Gen5_2',
              tier: 'Basic',
              maxSizeGb: 512,
              dtu: 1,
              vcores: 1,
              replicaKind: 'primary',
              geoReplicationState: 'seeding',
              statementKind: 'query',
              rowCount: 3,
              affectedRowCount: 3,
              batchTextLength: 1,
              cpuTimeMs: 120,
              elapsedTimeMs: 120,
              logicalReads: 1,
              physicalReads: 1,
              lockEscalations: 1,
              connectionString: 'SqlPassword',
              errorNumber: 1,
              errorState: 1,
              errorMessage: 'example',
              statusCode: 201));
    },
  );
  OTelLog.info(
      'tracedAzureSqlDatabase manage.database.create returned $azureSqlDatabaseId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutAzureSqlDatabaseInstrumentationAsync.
  await runWithoutAzureSqlDatabaseInstrumentationAsync(
    () => tracedAzureSqlDatabase<String>(
      operation: 'manage.database.create',
      invoke: () async {
        const id = 'azure_sql_database_8f3a2c';
        return const AzureSqlDatabaseCallResult(
            value: id,
            result: AzureSqlDatabaseResult(
                server: '<server>.database.windows.net',
                database: 'example',
                deploymentKind: 'single_database',
                elasticPool: 'example',
                sku: 'GP_Gen5_2',
                tier: 'Basic',
                maxSizeGb: 512,
                dtu: 1,
                vcores: 1,
                replicaKind: 'primary',
                geoReplicationState: 'seeding',
                statementKind: 'query',
                rowCount: 3,
                affectedRowCount: 3,
                batchTextLength: 1,
                cpuTimeMs: 120,
                elapsedTimeMs: 120,
                logicalReads: 1,
                physicalReads: 1,
                lockEscalations: 1,
                connectionString: 'SqlPassword',
                errorNumber: 1,
                errorState: 1,
                errorMessage: 'example',
                statusCode: 201));
      },
    ),
  );

  await OTel.shutdown();
}
