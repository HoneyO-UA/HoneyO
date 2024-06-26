{{/*
Expand the name of the chart.
*/}}
{{- define "emk.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "emk.fullname" -}}
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
{{- define "emk.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "emk.labels" -}}
helm.sh/chart: {{ include "emk.chart" . }}
{{ include "emk.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "emk.selectorLabels" -}}
app.kubernetes.io/name: {{ include "emk.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "emk.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "emk.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Compile all warnings into a single message, and call fail.
*/}}
{{- define "emk.validateValues" -}}
{{- $messages := list -}}
{{- $messages := append $messages (include "emk.validateValues.mapData" .) -}}
{{- $messages := append $messages (include "emk.validateValues.mapWeb" .) -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{-   printf "\nVALUES VALIDATION:\n%s" $message | fail -}}
{{- end -}}
{{- end -}}

{{/* Validate values of EMK - Map Data Values  */}}
{{- define "emk.validateValues.mapData" -}}
{{- if not .Values.map.data.image.repository -}}
EMK: Map Data
    Please set the Map Data image repository through `map.data.image.repository`
{{- end -}}
{{- end -}}


{{/* Validate values of EMK - Map Web Values  */}}
{{- define "emk.validateValues.mapWeb" -}}
{{- if not .Values.map.web.image.repository -}}
EMK: Map Web
    Please set the Map Web image repository through `map.web.image.repository`
{{- end -}}
{{- end -}}
