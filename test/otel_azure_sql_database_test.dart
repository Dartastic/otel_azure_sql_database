// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_azure_sql_database/otel_azure_sql_database.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_azure_sql_database-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('executeQuery records tier + rows + cpu time', () async {
    await tracedAzureSqlDatabase<String>(
      operation: 'executeQuery',
      invoke: () async => const AzureSqlDatabaseCallResult(
        value: 'ok',
        result: AzureSqlDatabaseResult(
          server: 'mysrv.database.windows.net',
          database: 'app',
          deploymentKind: 'serverless',
          tier: 'GeneralPurpose',
          vcores: 2,
          statementKind: 'query',
          rowCount: 1240,
          cpuTimeMs: 18,
          elapsedTimeMs: 42,
          logicalReads: 320,
          connectionString: 'Active Directory Managed Identity',
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('azure_sql_database executeQuery')!);
    expect(a['azure_sql_database.tier'], 'GeneralPurpose');
    expect(a['azure_sql_database.row_count'], 1240);
    expect(a['azure_sql_database.logical_reads'], 320);
  });

  test('PK violation 2627 sets span error', () async {
    await tracedAzureSqlDatabase<String>(
      operation: 'executeNonQuery',
      invoke: () async => const AzureSqlDatabaseCallResult(
        value: 'ok',
        result: AzureSqlDatabaseResult(
          errorNumber: 2627,
          errorMessage: 'Violation of PRIMARY KEY constraint',
        ),
      ),
    );
    expect(
      spans.findSpanByName('azure_sql_database executeNonQuery')!.status,
      SpanStatusCode.Error,
    );
  });

  test('deadlock 1205', () async {
    await tracedAzureSqlDatabase<String>(
      operation: 'executeNonQuery',
      invoke: () async => const AzureSqlDatabaseCallResult(
        value: 'ok',
        result: AzureSqlDatabaseResult(errorNumber: 1205),
      ),
    );
    final s = spans.findSpanByName('azure_sql_database executeNonQuery')!;
    expect(s.status, SpanStatusCode.Error);
    expect(attrsOf(s)['azure_sql_database.error.number'], 1205);
  });

  test('suppression skips spans', () async {
    await runWithoutAzureSqlDatabaseInstrumentationAsync(() async {
      await tracedAzureSqlDatabase<String>(
        operation: 'connect',
        invoke: () async => const AzureSqlDatabaseCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('azure_sql_database '), isEmpty);
  });
}
