// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_azure_sql_database_suppression.dart';

const _tracerName = 'dartastic_otel_libs_azure_sql_database';

Tracer _tracer() => OTel.tracerProvider().getTracer(_tracerName);

class AzureSqlDatabaseResult {
  const AzureSqlDatabaseResult({
    this.server,
    this.database,
    this.deploymentKind,
    this.elasticPool,
    this.sku,
    this.tier,
    this.maxSizeGb,
    this.dtu,
    this.vcores,
    this.replicaKind,
    this.geoReplicationState,
    this.statementKind,
    this.rowCount,
    this.affectedRowCount,
    this.batchTextLength,
    this.cpuTimeMs,
    this.elapsedTimeMs,
    this.logicalReads,
    this.physicalReads,
    this.lockEscalations,
    this.connectionString,
    this.errorNumber,
    this.errorState,
    this.errorMessage,
    this.statusCode,
  });

  /// `<server>.database.windows.net`.
  final String? server;
  final String? database;

  /// `single_database`, `elastic_pool`, `managed_instance`,
  /// `serverless`, `hyperscale`.
  final String? deploymentKind;

  final String? elasticPool;

  /// SKU name (`GP_Gen5_2`, `BC_Gen5_8`, `HS_Gen5_16`, `S0`, `P1`, ...).
  final String? sku;

  /// `Basic`, `Standard`, `Premium`, `GeneralPurpose`, `BusinessCritical`,
  /// `Hyperscale`, `Serverless`.
  final String? tier;

  final int? maxSizeGb;
  final int? dtu;
  final int? vcores;

  /// `primary`, `readable_secondary`, `geo_secondary`.
  final String? replicaKind;

  /// `seeding`, `catch_up`, `suspended`, `pending`.
  final String? geoReplicationState;

  /// `query`, `insert`, `update`, `delete`, `merge`, `bulk_insert`,
  /// `stored_procedure`, `ddl`, `transaction`, `bulk_copy`.
  final String? statementKind;

  /// Rows returned.
  final int? rowCount;

  /// Rows affected (INSERT/UPDATE/DELETE).
  final int? affectedRowCount;

  final int? batchTextLength;

  /// `cpu_time` from SET STATISTICS TIME.
  final int? cpuTimeMs;
  final int? elapsedTimeMs;

  /// `logical_reads` / `physical_reads` from SET STATISTICS IO.
  final int? logicalReads;
  final int? physicalReads;

  final int? lockEscalations;

  /// Connection string flavor (`Active Directory Integrated`,
  /// `Active Directory Password`, `Active Directory Service Principal`,
  /// `Active Directory Managed Identity`, `SqlPassword`, `WindowsAuth`).
  final String? connectionString;

  /// SQL Server error number (e.g. `2627` PK violation, `547` FK,
  /// `40613` database unavailable, `49918` not enough resources,
  /// `8501` MSDTC, `1205` deadlock, `4060` cannot open database,
  /// `18456` login failed, `40552` session terminated due to log space).
  final int? errorNumber;
  final int? errorState;
  final String? errorMessage;

  final int? statusCode;
}

class AzureSqlDatabaseCallResult<T> {
  const AzureSqlDatabaseCallResult({required this.value, this.result});
  final T value;
  final AzureSqlDatabaseResult? result;
}

/// Wraps an Azure SQL Database call in a CLIENT span. [operation] is one of
/// `connect`, `executeQuery`, `executeNonQuery`, `executeScalar`,
/// `executeBatch`, `executeReader`, `bulkCopy`, `transaction.begin`,
/// `transaction.commit`, `transaction.rollback`, `transaction.savepoint`,
/// `parameter.send`, `parameter.receive`, `manage.database.create`,
/// `manage.database.delete`, `manage.database.update`,
/// `manage.elasticPool.create`, `manage.elasticPool.delete`,
/// `manage.failoverGroup.failover`, `manage.failoverGroup.forceFailover`,
/// `manage.geoReplica.create`, `manage.geoReplica.delete`,
/// `manage.maintenance.window`, `auditing.set`, `tde.encrypt`,
/// `query_store.queryPlan`.
Future<T> tracedAzureSqlDatabase<T>({
  required String operation,
  required Future<AzureSqlDatabaseCallResult<T>> Function() invoke,
}) async {
  if (azureSqlDatabaseInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'azure_sql_database',
    'rpc.method': operation,
    'azure_sql_database.operation': operation,
  };

  final span = _tracer().startSpan(
    'azure_sql_database $operation',
    kind: SpanKind.client,
    attributes: OTel.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final res = r.result!;
      final extras = <Attribute<Object>>[];
      if (res.server != null) {
        extras.add(OTel.attributeString(
          'azure_sql_database.server',
          res.server!,
        ));
      }
      if (res.database != null) {
        extras.add(OTel.attributeString(
          'azure_sql_database.database',
          res.database!,
        ));
      }
      if (res.deploymentKind != null) {
        extras.add(OTel.attributeString(
          'azure_sql_database.deployment.kind',
          res.deploymentKind!,
        ));
      }
      if (res.elasticPool != null) {
        extras.add(OTel.attributeString(
          'azure_sql_database.elastic_pool',
          res.elasticPool!,
        ));
      }
      if (res.sku != null) {
        extras.add(OTel.attributeString(
          'azure_sql_database.sku',
          res.sku!,
        ));
      }
      if (res.tier != null) {
        extras.add(OTel.attributeString(
          'azure_sql_database.tier',
          res.tier!,
        ));
      }
      if (res.maxSizeGb != null) {
        extras.add(OTel.attributeInt(
          'azure_sql_database.max_size_gb',
          res.maxSizeGb!,
        ));
      }
      if (res.dtu != null) {
        extras.add(OTel.attributeInt('azure_sql_database.dtu', res.dtu!));
      }
      if (res.vcores != null) {
        extras.add(OTel.attributeInt(
          'azure_sql_database.vcores',
          res.vcores!,
        ));
      }
      if (res.replicaKind != null) {
        extras.add(OTel.attributeString(
          'azure_sql_database.replica.kind',
          res.replicaKind!,
        ));
      }
      if (res.geoReplicationState != null) {
        extras.add(OTel.attributeString(
          'azure_sql_database.geo_replication.state',
          res.geoReplicationState!,
        ));
      }
      if (res.statementKind != null) {
        extras.add(OTel.attributeString(
          'azure_sql_database.statement.kind',
          res.statementKind!,
        ));
      }
      if (res.rowCount != null) {
        extras.add(OTel.attributeInt(
          'azure_sql_database.row_count',
          res.rowCount!,
        ));
      }
      if (res.affectedRowCount != null) {
        extras.add(OTel.attributeInt(
          'azure_sql_database.affected_row_count',
          res.affectedRowCount!,
        ));
      }
      if (res.batchTextLength != null) {
        extras.add(OTel.attributeInt(
          'azure_sql_database.batch_text_length',
          res.batchTextLength!,
        ));
      }
      if (res.cpuTimeMs != null) {
        extras.add(OTel.attributeInt(
          'azure_sql_database.cpu_time_ms',
          res.cpuTimeMs!,
        ));
      }
      if (res.elapsedTimeMs != null) {
        extras.add(OTel.attributeInt(
          'azure_sql_database.elapsed_time_ms',
          res.elapsedTimeMs!,
        ));
      }
      if (res.logicalReads != null) {
        extras.add(OTel.attributeInt(
          'azure_sql_database.logical_reads',
          res.logicalReads!,
        ));
      }
      if (res.physicalReads != null) {
        extras.add(OTel.attributeInt(
          'azure_sql_database.physical_reads',
          res.physicalReads!,
        ));
      }
      if (res.lockEscalations != null) {
        extras.add(OTel.attributeInt(
          'azure_sql_database.lock_escalations',
          res.lockEscalations!,
        ));
      }
      if (res.connectionString != null) {
        extras.add(OTel.attributeString(
          'azure_sql_database.auth',
          res.connectionString!,
        ));
      }
      if (res.errorNumber != null) {
        extras.add(OTel.attributeInt(
          'azure_sql_database.error.number',
          res.errorNumber!,
        ));
        span.setStatus(
          SpanStatusCode.Error,
          'Azure SQL error ${res.errorNumber}',
        );
      }
      if (res.errorState != null) {
        extras.add(OTel.attributeInt(
          'azure_sql_database.error.state',
          res.errorState!,
        ));
      }
      if (res.errorMessage != null) {
        extras.add(OTel.attributeString(
          'azure_sql_database.error.message',
          res.errorMessage!,
        ));
      }
      if (res.statusCode != null) {
        extras.add(OTel.attributeInt(
          'http.response.status_code',
          res.statusCode!,
        ));
        if (res.statusCode! >= 400) {
          span.setStatus(
            SpanStatusCode.Error,
            'Azure SQL HTTP ${res.statusCode}',
          );
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTel.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTel.attributes([
      OTel.attributeString(
        ErrorResource.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
