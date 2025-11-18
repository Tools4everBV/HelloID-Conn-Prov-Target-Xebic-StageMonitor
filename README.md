# HelloID-Conn-Prov-Target-Xebic-StageMonitor

<!--
** for extra information about alert syntax please refer to [Alerts](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax#alerts)
-->

> [!IMPORTANT]
> This repository contains the connector and configuration code only. The implementer is responsible to acquire the connection details such as username, password, certificate, etc. You might even need to sign a contract or agreement with the supplier before implementing this connector. Please contact the client's application manager to coordinate the connector requirements.

<p align="center">
  <img src="">
</p>

## Table of contents

- [HelloID-Conn-Prov-Target-Xebic-StageMonitor](#helloid-conn-prov-target-xebic-stagemonitor)
  - [Table of contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Supported  features](#supported--features)
  - [Getting started](#getting-started)
    - [Prerequisites](#prerequisites)
    - [Connection settings](#connection-settings)
    - [Correlation configuration](#correlation-configuration)
    - [Field mapping](#field-mapping)
    - [Account Reference](#account-reference)
  - [Remarks](#remarks)
    - [No correlation](#no-correlation)
    - [Create new accounts only](#create-new-accounts-only)
    - [No enddate](#no-enddate)
    - [Email](#email)
    - [Bron](#bron)
  - [Development resources](#development-resources)
    - [API endpoints](#api-endpoints)
    - [API documentation](#api-documentation)
  - [Getting help](#getting-help)
  - [HelloID docs](#helloid-docs)

## Introduction

_HelloID-Conn-Prov-Target-Xebic-StageMonitor_ is a _target_ connector. _Xebic-StageMonitor_ provides a set of REST API's that allow you to programmatically interact with its data.

## Supported  features

The following features are available:

| Feature                                   | Supported | Actions | Remarks |
| ----------------------------------------- | --------- | ------- | ------- |
| **Account Lifecycle**                     | ✅         | Create  |         |
| **Permissions**                           | ❌         | -       |         |
| **Resources**                             | ❌         | -       |         |
| **Entitlement Import: Accounts**          | ❌         | -       |         |
| **Entitlement Import: Permissions**       | ❌         | -       |         |
| **Governance Reconciliation Resolutions** | ❌         | -       |         |

## Getting started

### Prerequisites

### Connection settings

The following settings are required to connect to the API.

| Setting      | Description                             | Mandatory | Example Value                     |
| ------------ | --------------------------------------- | --------- | --------------------------------- |
| UserName     | The UserName to connect to the API      | Yes       |                                   |
| Password     | The Password to connect to the API      | Yes       |                                   |
| ClientId     | The ClientId to connect to the API      | Yes       |                                   |
| ClientSecret | The ClientSecret to connect to the API  | Yes       |                                   |
| BaseUrl      | The URL to the API                      | Yes       | https://api.stagemonitor.com      |
| TokenBaseUrl | The BaseUrl to retrieve the accessToken | Yes       | https://identity.stagemonitor.com |


### Correlation configuration

Correlation is not possible because no `GET` calls are available on the `/orm/medewerker` endpoint

### Field mapping

The field mapping can be imported by using the _fieldMapping.json_ file.

### Account Reference

Since correlation is not possible, the account reference will remain empty.

## Remarks

### No correlation

Correlation is not possible because no `GET` calls are available on the `/orm/medewerker` endpoint

### Create new accounts only

Only new accounts can be created on the `/orm/medewerker` endpoint. The API call is a _fire and forget_ since the API only returns a _200 OK_ if the API call succeeded.
In addition it seems that there's no validation within StageMonitor that prevents creating the same student multiple times. Meaning, if you execute the _create_ lifecycle action twice for the same person, it will result in two StageMonitor accounts being created.

### No enddate

The endDate will not be populated by HelloID due to complications when an intern-ship is temporary on hold or resumed.

### Email

The `email address` contains the private email address of a student. Therefore, the email address will not be populated by _HelloID_. Instead, a CSV import is used within _Xebic-StageMonitor_.

### Bron

The `Bron` property is required when creating a new student. Its value can be set to anything but is harcoded to _HelloID_.

## Development resources

### API endpoints

The following endpoints are used by the connector

| Endpoint        | Description          |
| --------------- | -------------------- |
| /connect/token  | Retrieve oAuth token |
| /orm/medewerker | Create student       |

### API documentation

API documentation is not available publicly.

## Getting help

> [!TIP]
> _For more information on how to configure a HelloID PowerShell connector, please refer to our [documentation](https://docs.helloid.com/en/provisioning/target-systems/powershell-v2-target-systems.html) pages_.

> [!TIP]
>  _If you need help, feel free to ask questions on our [forum](https://forum.helloid.com)_.

## HelloID docs

The official HelloID documentation can be found at: https://docs.helloid.com/
