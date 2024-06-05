{{/*
Expand the name of the chart.
*/}}
{{- define "honeynet.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "honeynet.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "honeynet.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "honeynet.labels" -}}
helm.sh/chart: {{ include "honeynet.chart" . }}
{{ include "honeynet.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "honeynet.selectorLabels" -}}
app.kubernetes.io/name: {{ include "honeynet.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "honeynet.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "honeynet.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Compile all warnings into a single message, and call fail.
*/}}
{{- define "honeynet.validateValues" -}}
{{- $messages := list -}}
{{- $messages := append $messages (include "honeynet.validateValues.alertmanager" .) -}}
{{- $messages := append $messages (include "honeynet.validateValues.snapshotter" .) -}}
{{- $messages := append $messages (include "honeynet.validateValues.tracee" .) -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{-   printf "\nVALUES VALIDATION:\n%s" $message | fail -}}
{{- end -}}
{{- end -}}

{{/* Validate values of Honeynet - AlertManager Values  */}}
{{- define "honeynet.validateValues.alertmanager" -}}
{{- if not .Values.alertmanager.webhook_url -}}
Honeynet: Alertmanager
    Please set the Alertmanager webhook_url host through `alertmanager.webhook_url` to enable unused honeypot deletion
{{- end -}}
{{- end -}}

{{/* Validate values of Honeynet - Snapshotter Values  */}}
{{- define "honeynet.validateValues.snapshotter" -}}
{{- if not .Values.snapshotter.image.repository -}}
Honeynet: Snapshotter
    Please set the snapshotter image repository through `snapshotter.image.repository`
{{- end -}}
{{- if not (.Values.snapshotter.registry).url -}}
Honeynet: Snapshotter
    Please set the snapshotter registry url through `snapshotter.registry.url` to enable honeypot uploading by setting the snapshots private registry
{{- end -}}
{{- if not (.Values.snapshotter.registry).project -}}
Honeynet: Snapshotter
    Please set the snapshotter image repository through `snapshotter.registry.project` to enable honeypot uploading by setting the snapshots private registry
{{- end -}}
{{- if not (.Values.snapshotter.registry).credentials -}}
Honeynet: Snapshotter
    Please set the snapshotter image repository through `snapshotter.registry.credentials` to enable honeypot uploading by setting the snapshots private registry
{{- end -}}
{{- end -}}


{{/* Validate values of Honeynet - Tracee Values  */}}
{{- define "honeynet.validateValues.tracee" -}}
{{- if not .Values.tracee.image.repository -}}
Honeynet: Snapshotter
    Please set the tracee image repository through `tracee.image.repository`
{{- end -}}
{{- end -}}