{{/*
Expand the name of the chart.
*/}}
{{- define "management-system.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "management-system.fullname" -}}
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
{{- define "management-system.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "management-system.labels" -}}
helm.sh/chart: {{ include "management-system.chart" . }}
{{ include "management-system.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "management-system.selectorLabels" -}}
app.kubernetes.io/name: {{ include "management-system.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "management-system.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "management-system.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "management-system.api" -}}
  {{- printf "%s-api" (include "management-system.fullname" .) -}}
{{- end -}}


{{/*
Compile all warnings into a single message, and call fail.
*/}}
{{- define "ms.validateValues" -}}
{{- $messages := list -}}
{{- $messages := append $messages (include "ms.validateValues.honeynet" .) -}}
{{- $messages := append $messages (include "ms.validateValues.snapshotter" .) -}}
{{- $messages := append $messages (include "ms.validateValues.api" .) -}}
{{- $messages := append $messages (include "ms.validateValues.k8sWorker" .) -}}
{{- $messages := append $messages (include "ms.validateValues.spoa" .) -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{-   printf "\nVALUES VALIDATION:\n%s" $message | fail -}}
{{- end -}}
{{- end -}}
