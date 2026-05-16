// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'dart:async';

const _key = #dartastic_otel_libs_azure_sql_database_suppress;

bool azureSqlDatabaseInstrumentationSuppressed() => Zone.current[_key] == true;

T runWithoutAzureSqlDatabaseInstrumentation<T>(T Function() body) =>
    runZoned(body, zoneValues: {_key: true});

Future<T> runWithoutAzureSqlDatabaseInstrumentationAsync<T>(
  Future<T> Function() body,
) =>
    runZoned(body, zoneValues: {_key: true});
