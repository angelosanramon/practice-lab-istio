{{/*
Expand the name of the chart.
*/}}
{{- define "bookinfo.name" -}}
{{- default $.Chart.Name $.Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "bookinfo.fullname" -}}
{{- $ := index . 0 }}
{{- $appName := index . 1 }}
{{- $appVersion := index . 2 }}
{{- if $.Values.fullnameOverride }}
{{- printf "%s-%s-%s" $.Values.fullnameOverride $appName $appVersion | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default $.Chart.Name $.Values.nameOverride }}
{{- if contains $name $.Release.Name }}
{{- printf "%s-%s-%s" $.Release.Name $appName $appVersion | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s-%s-%s" $.Release.Name $name $appName $appVersion | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "bookinfo.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "bookinfo.labels" -}}
{{- $ := index . 0 }}
{{- $appName := index . 1 }}
{{- $appVersion := index . 2 -}}
helm.sh/chart: {{ include "bookinfo.chart" $ }}
{{ include "bookinfo.selectorLabels" (list $ $appName $appVersion ) }}
{{- if $appVersion }}
app.kubernetes.io/version: {{ $appVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ $.Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "bookinfo.selectorLabels" -}}
{{- $ := index . 0 }}
{{- $appName := index . 1 }}
{{- $appVersion := index . 2 -}}
app.kubernetes.io/name: {{ printf "%s-%s" (include "bookinfo.name" $) $appName }}
app.kubernetes.io/instance: {{ printf "%s-%s" $.Release.Name $appName }}
app: {{ printf "%s-%s" (include "bookinfo.name" $) $appName }}
{{- if $appVersion }}
version: {{ $appVersion }}
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "bookinfo.serviceAccountName" -}}
{{- $ := index . 0 }}
{{- $appName := index . 1 }}
{{- if or (dig $appName "serviceAccount" "create" false ($.Values | merge dict)) $.Values.serviceAccount.create }}
{{- default (include "bookinfo.fullname" (list $ $appName "" )) (dig $appName "serviceAccount" "name" $.Values.serviceAccount.name ($.Values | merge dict)) }}
{{- else }}
{{- default "default" (dig $appName "serviceAccount" "name" $.Values.serviceAccount.name ($.Values | merge dict)) }}
{{- end }}
{{- end }}
