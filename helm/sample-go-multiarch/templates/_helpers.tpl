{{/*
Expand the name of the chart.
*/}}
{{- define "sample-go-multiarch.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "sample-go-multiarch.fullname" -}}
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
{{- define "sample-go-multiarch.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "sample-go-multiarch.labels" -}}
helm.sh/chart: {{ include "sample-go-multiarch.chart" . }}
{{ include "sample-go-multiarch.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "sample-go-multiarch.selectorLabels" -}}
app.kubernetes.io/name: {{ include "sample-go-multiarch.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "sample-go-multiarch.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "sample-go-multiarch.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Image reference for deployment
*/}}
{{- define "sample-go-multiarch.containerImage" -}}
{{- if .Values.image.fullRef }}
{{- .Values.image.fullRef }}
{{- else }}
{{- default .Chart.AppVersion .Values.image.tag | printf "%s:%s" .Values.image.repository }}
{{- end }}
{{- end }}

{{/*
Pod affinity. Default to node anti-affinity
*/}}
{{- define "sample-go-multiarch.affinity" -}}
{{- if .Values.affinity }}
{{- toYaml .Values.affinity }}
{{- else -}}
podAntiAffinity:
  preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 100
      podAffinityTerm:
        topologyKey: kubernetes.io/hostname
        labelSelector:
          matchLabels:
            {{- include "sample-go-multiarch.selectorLabels" . | nindent 12 }}
{{- end }}
{{- end }}
